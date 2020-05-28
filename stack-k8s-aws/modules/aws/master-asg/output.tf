output "master_role_name" {
  value = "${coalesce(element(concat(aws_iam_role.master_role.*.name, list("")), 0),(element(concat(data.aws_iam_role.master_role.*.name, list("")), 0)))}"
}

output "master_asg_name" {
  value = "${local.asg_name}"
}

output "ignition_s3" {
  value = "s3://${data.aws_s3_bucket.backend_bucket.id}/${aws_s3_bucket_object.ignition_master.key}"
}
