output "ip_addresses" {
  value = "${coalescelist(aws_instance.etcd_node.*.private_ip, aws_spot_instance_request.etcd_node.*.private_ip)}"
}
