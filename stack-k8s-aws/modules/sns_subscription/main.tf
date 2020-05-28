resource "aws_lambda_permission" "with_sns" {
    statement_id = "SNS-${var.lambda_name}" # max length is 100
    action = "lambda:InvokeFunction"
    function_name = "${var.lambda_arn}"
    principal = "sns.amazonaws.com"
    source_arn = "${var.sns_arn}"
}

resource "aws_sns_topic_subscription" "subs" {
    topic_arn              = "${var.sns_arn}"
    protocol               = "lambda"
    endpoint               = "${var.lambda_arn}"
    endpoint_auto_confirms = true
    raw_message_delivery   = false
}

# resource "random_string" "statement" {
#   length  = 16
#   special = false
#   uppper  = false
#   lower   = true
#   keepers = ["${var.lambda_arn}"]
# }

# resource "aws_lambda_event_source_mapping" "event_source_mapping" {
#     batch_size = 1
#     event_source_arn = "${aws_sns_topic_subscription.subs.arn}"
#     enabled = true
#     function_name = "${var.lambda_arn}"
#     starting_position = "TRIM_HORIZON"
# }
