resource "aws_security_group" "etcd" {
  count  = "${var.enable_etcd_sg}"
  vpc_id = "${data.aws_vpc.cluster_vpc.id}"

  tags = "${merge(map(
      "Name", "etcd-sg-${var.cluster_name}-${var.base_domain}",
      "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "owned",
      "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
    ), var.extra_tags)}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    self      = true

    security_groups = ["${var.bastion_enabled ? join(" ", aws_security_group.bastion.*.id) : aws_security_group.master.id}"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 2379
    to_port   = 2379
    self      = true

    security_groups = ["${aws_security_group.master.id}"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 2380
    to_port   = 2380
    self      = true
  }
}
