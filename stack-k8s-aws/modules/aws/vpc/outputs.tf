output "vpc_id" {
  value = "${data.aws_vpc.cluster_vpc.id}"
}

output "master_subnet_ids" {
  value = "${local.master_subnet_ids}"
}

output "worker_subnet_ids" {
  value = "${local.worker_subnet_ids}"
}

output "bastion_subnet_ids" {
  value = "${local.bastion_subnet_ids}"
}

output "etcd_sg_id" {
  value = "${element(concat(aws_security_group.etcd.*.id, list("")), 0)}"
}

output "master_sg_id" {
  value = "${aws_security_group.master.id}"
}

output "worker_sg_id" {
  value = "${aws_security_group.worker.id}"
}

output "bastion_sg_id" {
  value = "${element(concat(aws_security_group.bastion.*.id, list("")), 0)}"
}

output "aws_lb_api_target_group_arn" {
  value = "${element(concat(aws_lb_target_group.master6443.*.arn, list("")), 0)}"
}

output "aws_lb_target_groups_arns" {
  value = ["${compact(concat(aws_lb_target_group.master6443.*.arn, aws_lb_target_group.master6440.*.arn))}"]
}

output "aws_api_external_dns_name" {
  value = "${element(concat(aws_lb.api_external.*.dns_name, list("")), 0)}"
}

output "aws_lb_api_external_zone_id" {
  value = "${element(concat(aws_lb.api_external.*.zone_id, list("")), 0)}"
}

output "bastion_eip_ip" {
  value = "${element(concat(aws_eip.bastion_eip.*.public_ip, list("")), 0)}"
}

output "bastion_eip_id" {
  value = "${element(concat(aws_eip.bastion_eip.*.id, list("")), 0)}"
}
