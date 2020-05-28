locals {
  asg_name        = "${var.cluster_name}-${var.base_domain}"
  iam_role_prefix = "pub-${substr(local.asg_name, 1, min(32, length(local.asg_name)-1))}"

  ami_id          = "${data.aws_ami.main.image_id}"
  recent          = "${var.linux_version == "*"}"

  owner_id   = "${replace(data.aws_region.current.name, "gov", "") == data.aws_region.current.name ? "075585003325" : "775307060209"}"
  aws_flavor = "${replace(data.aws_region.current.name, "gov", "") == data.aws_region.current.name ? "aws" : "aws-us-gov"}"

  ami_owners = "${map(
                "coreos", "595879546273",
                "flatcar", "${local.owner_id}",
              )}"

  ami_names = "${map(
                "coreos", "CoreOS-${var.linux_channel}-${var.linux_version}-*",
                "flatcar", "Flatcar-${var.linux_channel}-${var.linux_version}-*",
              )}"

  ami_owner = "${local.ami_owners[var.linux_distro]}"
  ami_name  = "${local.ami_names[var.linux_distro]}"
}

data "aws_ami" "main" {
  most_recent = "${local.recent}"
  owners      = ["${local.ami_owner}"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["${local.ami_name}"]
  }
}
data "aws_region" "current" {}

resource "aws_iam_instance_profile" "etcd" {
  count = "${var.internal_etcd ? 0 : 1}"
  name  = "etcd-profile-${local.asg_name}"

  role = "${var.etcd_iam_role == "" ?
    join("|", aws_iam_role.etcd_role.*.name) :
    join("|", data.aws_iam_role.etcd_role.*.name)
  }"
}

data "aws_iam_role" "etcd_role" {
  count = "${var.etcd_iam_role == "" ? 0 : 1}"
  name  = "${var.etcd_iam_role}"
}

resource "aws_iam_role" "etcd_role" {
  count = "${!var.internal_etcd && var.etcd_iam_role == "" ? 1 : 0}"
  name_prefix = ""
  # name  = "etcd-role-${var.cluster_name}-${var.base_domain}"
  path  = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

  tags = "${merge(map(
    "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "owned",
    "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
    "superhub.io/role/kind", "etcd",
  ), var.extra_tags)}"
}

resource "aws_iam_role_policy" "etcd" {
  count = "${!var.internal_etcd && var.etcd_iam_role == "" ? 1 : 0}"
  name  = "etcd_policy_${var.cluster_name}_${var.base_domain}"
  role  = "${aws_iam_role.etcd_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:AttachVolume",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:DetachVolume",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": "*"
    },
    {
      "Action" : [
        "s3:GetObject"
      ],
      "Resource": "arn:${local.aws_flavor}:s3:::*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_spot_instance_request" "etcd_node" {
  count = "${var.spot_price == "" ? 0 : var.instance_count}"
  ami   = "${local.ami_id}"

  iam_instance_profile            = "${aws_iam_instance_profile.etcd.name}"
  instance_type                   = "${var.ec2_type}"
  key_name                        = "${var.ssh_key}"
  subnet_id                       = "${element(var.subnets, count.index)}"
  user_data                       = "${data.ignition_config.s3.*.rendered[count.index]}"
  vpc_security_group_ids          = ["${var.sg_ids}"]
  spot_price                      = "${var.spot_price}"
  associate_public_ip_address     = "${var.nat_gw_workers ? false : true}"
  spot_type                       = "persistent"
  instance_interruption_behaviour = "terminate"
  wait_for_fulfillment            = true
  valid_until                     = "2025-03-22T10:11:22Z"

  lifecycle {
    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new CoreOS Release comes
    # out.
    ignore_changes = ["ami"]
  }

  tags = "${merge(map(
      "Name", "etcd-${count.index}-${local.asg_name}",
      "kubernetes.io/cluster/${local.asg_name}", "owned"
    ), var.extra_tags)}"

  root_block_device {
    volume_type = "${var.root_volume_type}"
    volume_size = "${var.root_volume_size}"
    iops        = "${var.root_volume_type == "io1" ? var.root_volume_iops : var.root_volume_type == "gp2" ? min(10000, max(100, 3 * var.root_volume_size)) : 0}"
  }

  volume_tags = "${merge(map(
    "Name", "etcd-${count.index}-vol-${local.asg_name}",
    "kubernetes.io/cluster/${local.asg_name}", "owned"
  ), var.extra_tags)}"
}

resource "aws_instance" "etcd_node" {
  depends_on = ["aws_s3_bucket_object.ignition_etcd"]

  count = "${var.spot_price == "" ? var.instance_count : 0}"
  ami   = "${local.ami_id}"

  iam_instance_profile        = "${aws_iam_instance_profile.etcd.name}"
  instance_type               = "${var.ec2_type}"
  key_name                    = "${var.ssh_key}"
  subnet_id                   = "${element(var.subnets, count.index)}"
  user_data                   = "${data.ignition_config.s3.*.rendered[count.index]}"
  associate_public_ip_address = "${var.nat_gw_workers ? false : true}"
  vpc_security_group_ids      = ["${var.sg_ids}"]

  lifecycle {
    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new CoreOS Release comes
    # out.
    ignore_changes = ["ami"]
  }

  tags = "${merge(map(
      "Name", "etcd-${count.index}-${local.asg_name}",
      "kubernetes.io/cluster/${local.asg_name}", "owned"
    ), var.extra_tags)}"

  root_block_device {
    volume_type = "${var.root_volume_type}"
    volume_size = "${var.root_volume_size}"
    iops        = "${var.root_volume_type == "io1" ? var.root_volume_iops : var.root_volume_type == "gp2" ? min(10000, max(100, 3 * var.root_volume_size)) : 0}"
  }

  volume_tags = "${merge(map(
    "Name", "etcd-${count.index}-vol-${local.asg_name}",
    "kubernetes.io/cluster/${local.asg_name}", "owned",
  ), var.extra_tags)}"
}
