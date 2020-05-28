resource "aws_security_group" "bastion" {
  count  = "${var.bastion_enabled ? 1 : 0}"
  vpc_id = "${data.aws_vpc.cluster_vpc.id}"

  tags = "${merge(map(
      "Name", "bastion-sg-${var.cluster_name}-${var.base_domain}",
      "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "owned",
      "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
    ), var.extra_tags)}"
}

resource "aws_security_group_rule" "bastion_egress" {
  count             = "${var.bastion_enabled ? 1 : 0}"
  type              = "egress"
  security_group_id = "${aws_security_group.bastion.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion_ingress_ssh" {
  count             = "${var.bastion_enabled ? 1 : 0}"
  type              = "ingress"
  security_group_id = "${aws_security_group.bastion.id}"

  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 22
  to_port     = 22
}
