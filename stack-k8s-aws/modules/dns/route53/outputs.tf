output "etcd_a_nodes" {
  value = "${aws_route53_record.etcd_a_nodes.*.fqdn}"
}

# We have to do this join() & split() 'trick' because the ternary operator can't output lists.
output "etcd_endpoints" {
  value = ["${split(",", length(var.external_endpoints) == 0 ? join(",", aws_route53_record.etcd_a_nodes.*.fqdn) : join(",", var.external_endpoints))}"]
}

output "etcd_a_name" {
  value = "${element(concat(aws_route53_record.etcd_a.*.name, list("")), 0)}"
}

output "api_external_fqdn" {
  value = "${join(".", compact(split(".", element(concat(aws_route53_zone.main.*.name,list("")),0))))}"
}

output "api_internal_fqdn" {
  value = "${join(".", compact(split(".", element(concat(aws_route53_zone.asi_int.*.name,list("")),0))))}"
}

output "int_zone_id" {
  value = "${element(concat(aws_route53_zone.asi_int.*.zone_id, list("")), 0)}"
}

output "ext_zone_id" {
  value = "${element(concat(aws_route53_zone.main.*.zone_id, list("")), 0)}"
}
