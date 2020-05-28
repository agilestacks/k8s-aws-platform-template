resource "aws_sns_topic" "main" {
  name = "${var.name}"
  display_name = "${var.name}"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = "${data.aws_caller_identity.current.account_id}"
}

# resource "aws_cloudwatch_log_group" "main" {
#   name = "${var.name}"
#   retention_in_days = 1
# }

# resource "aws_cloudwatch_log_stream" "main" {
#   name           = "${var.name}"
#   log_group_name = "${aws_cloudwatch_log_group.main.name}"
# }

# resource "aws_sns_topic_subscription" "subs" {
#     topic_arn = "${aws_sns_topic.main.arn}"
#     protocol  = "application"
#     endpoint  = "${aws_cloudwatch_log_group.main.name}"
#     endpoint_auto_confirms = true
# }

data "aws_iam_policy_document" "sns_publish_policy" {
  statement {
    sid = "default"
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:Publish"
    ]
    resources = [
      "${aws_sns_topic.main.arn}"
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        "${local.account_id}",
      ]
    }
    principals {
      type        = "AWS"
      identifiers = ["${local.account_id}"]
    }
  }
}

resource "aws_sns_topic_policy" "custom" {
  arn    = "${aws_sns_topic.main.arn}"
  policy = "${data.aws_iam_policy_document.sns_publish_policy.json}"
}
