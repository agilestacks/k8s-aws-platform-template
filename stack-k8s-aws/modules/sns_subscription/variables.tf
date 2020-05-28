variable "lambda_arn" {
  type = "string"
  description = "ARN of the Lambda to add permission to"
}

variable "lambda_name" {
  type = "string"
  description = "Name of the Lambda to add permission to"
}

variable "sns_arn" {
  type = "string"
  description = "ARN of SNS to subscribe to"
}
