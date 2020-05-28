output "bastion_role_arn" {
  description = "The Bastion's EC2 IAM role ARN"
  value       = "${element(concat(aws_iam_role.bastion_role.*.arn, list("")), 0)}"
}

output "bastion_instance_profile_arn" {
  description = "The Bastion's EC2 instance profile ARN"
  value       = "${element(concat(aws_iam_instance_profile.bastion_instance_profile.*.arn, list("")), 0)}"
}

output "bastion_instance_profile_name" {
  description = "The Bastion's EC2 instance profile name"
  value       = "${element(concat(aws_iam_instance_profile.bastion_instance_profile.*.name, list("")), 0)}"
}

# an example for bastion pub key
#output "pubkey" {
#  value = "${data.template_file.public_key.rendered}"
#}

