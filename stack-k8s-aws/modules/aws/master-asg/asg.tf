locals {
  fqdn_cluster_name    = "${var.cluster_name}.${var.base_domain}"
  cluster_name      = "${replace("${var.cluster_name}-${var.base_domain}", ".", "-")}"
  asg_name          = "master-${local.cluster_name}"

  # must not be longer 32 symbols
  name_prefix     = "${substr(replace(local.asg_name, ".", "-"), 0, min(24, length(local.asg_name)-1))}"

  metadata_json_ext_r53 = <<EOF
{
  "HostedZoneId": "${var.lifecycle_hook_ext_zone_id}",
  "Changes": [
    {
      "Action": "UPSERT",
      "Name": "${var.lifecycle_hook_ext_r53_name}",
      "Type": "${var.lifecycle_hook_ext_r53_type}",
      "TTL": "30",
      "Template": "{{PublicIpAddress}}"
    }
  ]
}
EOF

metadata_json_int_r53 = <<EOF
{
  "HostedZoneId": "${var.lifecycle_hook_int_zone_id}",
  "Changes": [
    {
      "Action": "UPSERT",
      "Name": "${var.lifecycle_hook_int_r53_name}",
      "Type": "${var.lifecycle_hook_int_r53_type}",
      "TTL": "30",
      "Template": "{{PrivateIpAddress}}"
    }
  ]
}
EOF
}

resource "aws_autoscaling_group" "with_hook" {
  depends_on           = ["aws_s3_bucket_object.ignition_master"]
  name                 = "${local.asg_name}"
  desired_capacity     = "${var.instance_count}"
  max_size             = "${var.instance_count}"
  min_size             = "${var.instance_count}"
  launch_configuration = "${aws_launch_configuration.master_conf.id}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  termination_policies = ["ClosestToNextInstanceHour", "default"]
  target_group_arns    = ["${var.aws_lb_target_groups_arns}"]

  wait_for_capacity_timeout = "0"

  initial_lifecycle_hook {
    name                    = "${local.asg_name}-ext-launching"
    default_result          = "CONTINUE"
    heartbeat_timeout       = 100
    lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
    notification_metadata   = "${local.metadata_json_ext_r53}"
    notification_target_arn = "${var.lifecycle_hook_target_arn}"
    role_arn                = "${aws_iam_role.publisher.arn}"
  }

  initial_lifecycle_hook {
    name                    = "${local.asg_name}-int-launching"
    default_result          = "CONTINUE"
    heartbeat_timeout       = 100
    lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
    notification_metadata   = "${local.metadata_json_int_r53}"
    notification_target_arn = "${var.lifecycle_hook_target_arn}"
    role_arn                = "${aws_iam_role.publisher.arn}"
  }

  tags = [
    {
      key                 = "Name"
      value               = "${local.asg_name}"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "superhub.io/stack/${var.cluster_name}.${var.base_domain}"
      value               = "owned",
      propagate_at_launch = true
    },
    {
      key                 = "InitialCapacity"
      value               = "0"
      propagate_at_launch = false
    },
    {
      key                 = "DesiredCapacity"
      value               = "${var.instance_count}"
      propagate_at_launch = false
    },
    {
      key                 = "MinSize"
      value               = "${var.instance_count}"
      propagate_at_launch = false
    },
    {
      key                 = "MaxSize"
      value               = "${var.instance_count * 3}"
      propagate_at_launch = false
    },
    {
      key                 = "k8s.io/node-pool/${local.fqdn_cluster_name}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/node-pool/name"
      value               = "${local.asg_name}"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/node-pool/kind"
      value               = "master"
      propagate_at_launch = true
    },
    "${var.autoscaling_group_extra_tags}",
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["min_size", "max_size", "desired_capacity", "tag"]
  }
}

resource "aws_autoscaling_lifecycle_hook" "master_ext_terminating" {
  name                    = "${local.asg_name}-ext-terminating"
  count                   = "${var.k8s_api_fqdn == "" ? 0 : 1}"
  autoscaling_group_name  = "${aws_autoscaling_group.with_hook.name}"
  default_result          = "CONTINUE"
  heartbeat_timeout       = 100
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_metadata   = "${local.metadata_json_ext_r53}"
  notification_target_arn = "${var.lifecycle_hook_target_arn}"
  role_arn                = "${aws_iam_role.publisher.arn}"
}

resource "aws_autoscaling_lifecycle_hook" "master_int_terminating" {
  name                    = "${local.asg_name}-int-terminating"
  autoscaling_group_name  = "${aws_autoscaling_group.with_hook.name}"
  default_result          = "CONTINUE"
  heartbeat_timeout       = 100
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_metadata   = "${local.metadata_json_int_r53}"
  notification_target_arn = "${var.lifecycle_hook_target_arn}"
  role_arn                = "${aws_iam_role.publisher.arn}"
}

resource "aws_iam_role" "publisher" {
  name_prefix = "${local.name_prefix}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [ {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "autoscaling.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
  } ]
}
EOF
}

resource "aws_iam_role_policy" "allow_publish" {
  name  = "${local.asg_name}-publish"
  role  = "${aws_iam_role.publisher.id}"

  # TODO add restriciton on resources
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [ {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "sns:Publish",
        "sqs:GetQueueUrl",
        "sqs:SendMessage"
      ]
  } ]
}
EOF
}
