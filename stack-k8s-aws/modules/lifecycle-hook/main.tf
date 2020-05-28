resource "aws_autoscaling_lifecycle_hook" "launching" {
  count                   = "${var.hook_enabled}"
  name                    = "${var.name}-launching"
  autoscaling_group_name  = "${coalesce("${var.ag_name}" , "${var.name}")}"
  default_result          = "CONTINUE"
  heartbeat_timeout       = 2000
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
  notification_metadata   = "${var.metadata_json}"
  notification_target_arn = "${var.target_arn}"
  role_arn                = "${aws_iam_role.publisher.arn}"
}

resource "aws_autoscaling_lifecycle_hook" "terminating" {
  count                   = "${var.hook_enabled}"
  name                    = "${var.name}-terminating"
  autoscaling_group_name  = "${coalesce("${var.ag_name}" , "${var.name}")}"
  default_result          = "CONTINUE"
  heartbeat_timeout       = 2000
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_metadata   = "${var.metadata_json}"
  notification_target_arn = "${var.target_arn}"
  role_arn                = "${aws_iam_role.publisher.arn}"
}

resource "aws_iam_role" "publisher" {
  count       = "${var.hook_enabled}"
  name_prefix = "publisher-"

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
  count = "${var.hook_enabled}"
  name  = "${var.name}-sns-pub"
  role  = "${aws_iam_role.publisher.id}"

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
