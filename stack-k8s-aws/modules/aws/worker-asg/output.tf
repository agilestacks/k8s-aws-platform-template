output "worker_role_name" {
  value = "${coalesce(element(concat(aws_iam_role.worker_role.*.name, list("")), 0),(element(concat(data.aws_iam_role.worker_role.*.name, list("")), 0)))}"
}

output "worker_iam_instance_profile_name" {
  value = "${join("", aws_iam_instance_profile.worker_profile.*.name)}"
}

output "ignition_s3" {
  value = "s3://${data.aws_s3_bucket.backend_bucket.id}/${aws_s3_bucket_object.ignition_worker.key}"
}
