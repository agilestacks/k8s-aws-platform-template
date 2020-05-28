module "stack" {
  source = "../../stack"
  name   = "${var.cluster_name}.${var.base_domain}"
}

resource "aws_lb" "api_external" {
  count                            = "${var.k8s_api_fqdn == "" ? 1 : 0}"
  load_balancer_type               = "network"
  subnets                          = ["${local.master_subnet_ids}"]
  internal                         = false
  enable_cross_zone_load_balancing = true

   tags = "${merge(map(
      "Name", "api-external-${var.cluster_name}-${var.base_domain}",
      "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "owned",
      "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
    ), var.extra_tags)}"
}

resource "aws_lb_listener" "api_external" {
  count             = "${var.k8s_api_fqdn == "" ? 1 : 0}"
  load_balancer_arn = "${aws_lb.api_external.arn}"
  protocol          = "TCP"
  port              = "443"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.master6443.arn}"
  }
}

resource "aws_lb_listener" "httpcheck_external" {
  count             = "${var.k8s_api_fqdn == "" ? 1 : 0}"
  load_balancer_arn = "${aws_lb.api_external.arn}"
  protocol          = "TCP"
  port              = "6440"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.master6440.arn}"
  }
}

resource "aws_lb_target_group" "master6443" {
  count    = "${var.k8s_api_fqdn == "" ? 1 : 0}"
  vpc_id   = "${data.aws_vpc.cluster_vpc.id}"
  port     = 6443
  protocol = "TCP"
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = 6443

    # NLBs required to use same healthy and unhealthy thresholds
    healthy_threshold   = 3
    unhealthy_threshold = 3

    # Must be one of the following values '[10, 30]' for target groups with the TCP protocol.
    interval = 10
  }
  tags = "${map(
    "Name", "master6443-${var.cluster_name}-${var.base_domain}",
    "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "owned",
    "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
  )}"
}

resource "aws_lb_target_group" "master6440" {
  count    = "${var.k8s_api_fqdn == "" ? 1 : 0}"
  vpc_id   = "${data.aws_vpc.cluster_vpc.id}"
  port     = 6440
  protocol = "TCP"
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = 6440

    # NLBs required to use same healthy and unhealthy thresholds
    healthy_threshold   = 3
    unhealthy_threshold = 3

    # Must be one of the following values '[10, 30]' for target groups with the TCP protocol.
    interval = 10
  }

  tags = "${map(
    "Name", "master6440-${var.cluster_name}-${var.base_domain}",
    "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "owned",
    "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
  )}"
}
