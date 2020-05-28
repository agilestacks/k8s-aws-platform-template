output "vpc" {
  value = "${module.vpc.vpc_id}"
}

output "vpc_cidr_block" {
  value = "${var.asi_aws_vpc_cidr_block}"
}

output "master_subnet_id" {
  value = "${module.vpc.master_subnet_ids[0]}"
}

output "worker_subnet_id" {
  value = "${module.vpc.worker_subnet_ids[0]}"
}

output "worker_subnet_ids" {
  value = "${join(",", module.vpc.worker_subnet_ids)}"
}

output "master_sg_id" {
  value = "${module.vpc.master_sg_id}"
}

output "worker_sg_id" {
  value = "${module.vpc.worker_sg_id}"
}

output "master_role_name" {
  value = "${module.masters.master_role_name}"
}

output "worker_role_name" {
  value = "${module.workers.worker_role_name}"
}

output "worker_iam_instance_profile_name" {
  value = "${module.workers.worker_iam_instance_profile_name}"
}

output "base_domain" {
  value = "${var.name}.${var.base_domain}"
}

output "api_server_host" {
  value = "${coalesce(var.k8s_api_fqdn, module.vpc.aws_api_external_dns_name)}"
}

output "api_server_port" {
  value = "${var.k8s_api_fqdn == "" ? "443" : "6443"}"
}

output "cert_ca_pem" {
  value = "s3://${var.backend_bucket}/${aws_s3_bucket_object.ca_pem.key}"
}

output "cert_ca_key" {
  value = "s3://${var.backend_bucket}/${aws_s3_bucket_object.ca_key.key}"
}

output "cert_client_pem" {
  value = "s3://${var.backend_bucket}/${aws_s3_bucket_object.admin_pem.key}"
}

output "cert_client_key" {
  value = "s3://${var.backend_bucket}/${aws_s3_bucket_object.admin_key.key}"
}

output "api_ca_crt" {
  value = "file://${local_file.ca_cert.filename}"
}

output "api_ca_key" {
  value = "file://${local_file.ca_key.filename}"
}

output "api_client_crt" {
  value = "file://${local_file.admin_cert.filename}"
}

output "api_client_key" {
  value = "file://${local_file.admin_key.filename}"
}

output "master_ignition_s3" {
  value = "${module.masters.ignition_s3}"
}

output "worker_ignition_s3" {
  value = "${module.workers.ignition_s3}"
}

output "resource_group" {
  value = "${aws_resourcegroups_group.cluster.arn}"
}
