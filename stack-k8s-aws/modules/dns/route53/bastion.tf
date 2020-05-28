resource "aws_route53_record" "bastion_host" {
  count   = "${var.bastion_enabled ? 1 : 0}"
  zone_id = "${local.public_zone_id}"
  name    = "bastion"
  type    = "A"
  ttl     = "${var.bastion_zone_ttl}"

  records = ["${var.bastion_public_ip}"]
}
