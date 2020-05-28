output "role_arn" {
  value = "${element(concat(aws_iam_role.publisher.*.arn, list("")), 0)}"
}
