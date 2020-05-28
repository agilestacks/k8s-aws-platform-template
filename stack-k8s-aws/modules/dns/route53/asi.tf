data "aws_route53_zone" "base" {
  count = "${var.k8s_api_fqdn == "" ? 0 : 1}"
  name  = "${var.base_domain}"
}

data "aws_region" "current" {}

resource "aws_route53_zone" "main" {
  count         = "${var.k8s_api_fqdn == "" ? 0 : 1}"
  name          = "${var.cluster_name}.${data.aws_route53_zone.base.name}"
  force_destroy = true

  tags = "${merge(map(
      "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "owned",
      "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
      "Kind", "public",
    ), var.asi_extra_tags)}"
}

resource "aws_route53_record" "parent" {
  count   = "${var.k8s_api_fqdn == "" ? 0 : 1}"
  zone_id = "${data.aws_route53_zone.base.zone_id}"
  name    = "${var.cluster_name}"
  type    = "NS"
  ttl     = "60"
  records = ["${aws_route53_zone.main.name_servers}"]
}

locals {
  private_zone_id = "${var.asi_external_private_zone == "" ?
                        join("", aws_route53_zone.asi_int.*.zone_id) :
                        var.asi_external_private_zone}"

  public_zone_id = "${join("", aws_route53_zone.main.*.zone_id)}"
}

resource "aws_route53_zone" "asi_int" {
  count = "${var.asi_external_private_zone == "" ? 1 : 0 }"
  name  = "i.${var.cluster_name}.${var.base_domain}"
  vpc {
    vpc_id = "${var.asi_external_vpc_id}"
  }
  force_destroy = true

  tags = "${merge(map(
      "Name", "asi-int-zone-${var.cluster_name}-${var.base_domain}",
      "KubernetesCluster", "${var.cluster_name}-${var.base_domain}",
      "Kind", "private",
      "superhub.io/stack/${var.cluster_name}-${var.base_domain}", "owned",
      "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "owned",
      "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
    ), var.asi_extra_tags)}"
}
