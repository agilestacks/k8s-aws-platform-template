data "aws_region" "current" {}

locals {
  ami_id          = "${coalesce(var.ec2_ami, data.aws_ami.main.image_id)}"
  recent          = "${var.linux_version == "*"}"

  owner_id   = "${replace(data.aws_region.current.name, "gov", "") == data.aws_region.current.name ? "075585003325" : "775307060209"}"

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
  owners = ["${local.ami_owner}"]
  most_recent = "${local.recent}"
  filter {
    name   = "name"
    values = ["${local.ami_name}"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_configuration" "master_conf" {
  instance_type               = "${var.ec2_type}"
  image_id                    = "${local.ami_id}"
  name_prefix                 = "${local.name_prefix}"
  key_name                    = "${var.ssh_key}"
  security_groups             = ["${var.master_sg_ids}"]
  iam_instance_profile        = "${aws_iam_instance_profile.master_profile.arn}"
  associate_public_ip_address = true
  user_data                   = "${data.ignition_config.s3.rendered}"
  spot_price                  = "${var.spot_price}"

  lifecycle {
    create_before_destroy = true

    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new CoreOS Release comes
    # out.
    ignore_changes = ["image_id"]
  }

  root_block_device {
    volume_type = "${var.root_volume_type}"
    volume_size = "${var.root_volume_size}"
    iops        = "${var.root_volume_type == "io1" ? var.root_volume_iops : 0}"
  }
}

resource "aws_iam_instance_profile" "master_profile" {
  name = "master-profile-${var.cluster_name}-${var.base_domain}"

  role = "${var.master_iam_role == "" ?
    join("|", aws_iam_role.master_role.*.name) :
    join("|", data.aws_iam_role.master_role.*.name)
  }"
}

data "aws_iam_role" "master_role" {
  count = "${var.master_iam_role == "" ? 0 : 1}"
  name  = "${var.master_iam_role}"
}

resource "aws_iam_role" "master_role" {
  count = "${var.master_iam_role == "" ? 1 : 0}"
  name_prefix  = "${local.name_prefix}"
  path  = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    },
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": { "Service": "ecs-tasks.amazonaws.com"}
    },
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": { "Service": "batch.amazonaws.com"}
    }
  ]
}
EOF

  tags = "${merge(map(
      "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "owned",
      "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
      "superhub.io/role/kind","master",
    ), var.extra_tags)}"
}

resource "aws_iam_role_policy" "master_policy" {
  count = "${var.master_iam_role == "" ? 1 : 0}"
  name_prefix  = "${local.name_prefix}"
  role  = "${aws_iam_role.master_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "elasticloadbalancing:*",
        "route53:*",
        "s3:*",
        "sts:*",
        "dynamodb:*"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:CompleteLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:InitiateLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:BatchGetImage",
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "sts:AssumeRole",
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action" : [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeTags",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action" : [
        "iam:CreateServiceLinkedRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
