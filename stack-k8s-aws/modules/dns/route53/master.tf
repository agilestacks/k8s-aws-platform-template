locals {
  api_prefix = "${element(split(".", var.k8s_api_fqdn), 0)}"
}

resource "aws_route53_record" "master_a_int" {
  type    = "A"
  ttl     = "30"
  zone_id = "${local.private_zone_id}"
  name    = "api"
  records = ["127.0.0.1"]

  lifecycle {
    ignore_changes = ["records", "ttl"]
  }
}

resource "aws_route53_record" "master_a_ext" {
  count   = "${var.k8s_api_fqdn == "" ? 0 : 1}"
  type    = "A"
  ttl     = "30"
  zone_id = "${local.public_zone_id}"
  name    = "${local.api_prefix}"
  records = ["127.0.0.1"]

  lifecycle {
    ignore_changes = ["records", "ttl"]
  }
}
