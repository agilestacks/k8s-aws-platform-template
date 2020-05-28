data "aws_ami" "bastion_ami" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
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

data "template_file" "bastion_user_data" {
  template = "${file("${path.module}/resources/bastion_userdata.sh")}"

  vars {
    eip_id             = "${var.bastion_eip_id}"
    keys_bucket_name   = "${var.bastion_keys_bucket}"
    keys_bucket_region = "${var.bastion_keys_bucket_region}"
    keys_bucket_prefix = "${var.bastion_keys_bucket_prefix}"
    logs_bucket_name   = "${var.bastion_logs_bucket}"
    logs_bucket_prefix = "${var.bastion_logs_bucket_prefix}"
    logs_bucket_region = "${var.bastion_keys_bucket_region}"
  }
}

resource "aws_launch_configuration" "bastion_launch_configuration" {
  count                = "${var.bastion_enabled ? 1 : 0}"
  name_prefix          = "bastion-${var.cluster_name}-${var.base_domain}"
  image_id             = "${data.aws_ami.bastion_ami.image_id}"
  instance_type        = "${var.bastion_instance_type}"
  key_name             = "${var.bastion_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.bastion_instance_profile.name}"
  security_groups      = ["${var.bastion_sg}"]
  user_data            = "${data.template_file.bastion_user_data.rendered}"
  ebs_optimized        = "${var.bastion_ebs_optimized}"
  enable_monitoring    = "${var.bastion_enable_monitoring}"

  # Needed for eip association to work
  associate_public_ip_address = "true"

  root_block_device {
    volume_type = "${var.bastion_volume_type}"
    volume_size = "${var.bastion_volume_size}"
  }

  lifecycle {
    create_before_destroy = "true"
  }
}

resource "aws_autoscaling_group" "bastion_asg" {
  count                = "${var.bastion_enabled ? 1 : 0}"
  name                 = "bastion-${var.cluster_name}-${var.base_domain}"
  max_size             = "${var.bastion_max_size}"
  min_size             = "${var.bastion_min_size}"
  desired_capacity     = "${var.bastion_desired_capacity}"
  launch_configuration = "${aws_launch_configuration.bastion_launch_configuration.name}"
  vpc_zone_identifier  = ["${var.bastion_asg_subnets}"]

  tags = [
    {
      key                 = "Name"
      value               = "bastion-${var.cluster_name}-${var.base_domain}"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}"
      value               = "owned"
      propagate_at_launch = true
    },

    {
      key                 = "superhub.io/stack/${var.cluster_name}.${var.base_domain}"
      value               = "owned"
      propagate_at_launch = true
    },
  ]
}

resource "aws_iam_role" "bastion_role" {
  count = "${var.bastion_enabled ? 1 : 0}"
  name  = "bastion-role-${var.cluster_name}-${var.base_domain}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "bastion_ec2_policy" {
  count       = "${var.bastion_enabled ? 1 : 0}"
  name        = "bastion-ec2-policy-${var.cluster_name}-${var.base_domain}"
  path        = "/"
  description = "Bastion EC2 Policy ${var.cluster_name}.${var.base_domain}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1477071439000",
      "Effect": "Allow",
      "Action": [
        "ec2:AssociateAddress"
      ],
      "Resource": [
        "*"
      ]
    }

  ]
}
EOF
}

resource "aws_iam_policy" "bastion_s3_policy" {
  count       = "${var.bastion_enabled ? 1 : 0}"
  name        = "bastion-s3-policy-${var.cluster_name}-${var.base_domain}"
  path        = "/"
  description = "Bastion S3 Policy ${var.cluster_name}.${var.base_domain}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": ["arn:aws:s3:::${var.bastion_logs_bucket}/${var.bastion_logs_bucket_prefix}/*"]
    },
    {
     "Effect": "Allow",
     "Action": ["s3:GetObject"],
     "Resource": ["arn:aws:s3:::${var.bastion_keys_bucket}/${var.bastion_keys_bucket_prefix}/*"]
    },
    {
     "Effect": "Allow",
     "Action": ["s3:ListBucket"],
     "Resource": ["arn:aws:s3:::${var.bastion_keys_bucket}"],
     "Condition": {
        "StringEquals": {
          "s3:prefix": "public-keys/"
         }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "bastion_attach_ec2_policy" {
  count      = "${var.bastion_enabled ? 1 : 0}"
  role       = "${aws_iam_role.bastion_role.name}"
  policy_arn = "${aws_iam_policy.bastion_ec2_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "bastion_attach_s3_policy" {
  count      = "${var.bastion_enabled ? 1 : 0}"
  role       = "${aws_iam_role.bastion_role.name}"
  policy_arn = "${aws_iam_policy.bastion_s3_policy.arn}"
}

resource "aws_iam_policy" "bastion_logs_policy" {
  count       = "${var.bastion_enabled ? 1 : 0}"
  name        = "bastion-logs-policy-${var.cluster_name}-${var.base_domain}"
  path        = "/"
  description = "Bastion Logs Policy for ${var.cluster_name}.${var.base_domain}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "bastion_attach_logs_policy" {
  count      = "${var.bastion_enabled ? 1 : 0}"
  role       = "${aws_iam_role.bastion_role.name}"
  policy_arn = "${aws_iam_policy.bastion_logs_policy.arn}"
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  count = "${var.bastion_enabled ? 1 : 0}"
  name  = "bastion-profile-${var.cluster_name}-${var.base_domain}"
  role  = "${aws_iam_role.bastion_role.name}"
}

# an example for bastion pub key
#data "template_file" "public_key" {
#  template = "${file("${path.module}/resources/user.pub")}"
#}
