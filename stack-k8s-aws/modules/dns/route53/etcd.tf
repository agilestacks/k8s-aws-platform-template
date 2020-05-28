resource "aws_route53_record" "etcd_a_nodes" {
  allow_overwrite = true
  count   = "${var.internal_etcd ? 0 : var.etcd_count}"
  type    = "A"
  ttl     = "60"
  zone_id = "${local.private_zone_id}"
  name    = "etcd-${count.index}"
  records = ["${var.etcd_ip_addresses[count.index]}"]

  lifecycle {
    ignore_changes = ["records", "ttl"]
  }
}

resource "aws_route53_record" "etcd_a" {
  allow_overwrite = true
  count   = "${var.internal_etcd ? 1 : 0}"
  type    = "A"
  ttl     = "30"
  zone_id = "${local.zone_id}"
  name    = "etcd"
  records = ["127.0.0.1"]

  lifecycle {
    ignore_changes = ["records", "ttl"]
  }
}


