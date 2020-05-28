resource "aws_security_group" "worker" {
  vpc_id = "${data.aws_vpc.cluster_vpc.id}"

  tags = "${merge(map(
      "Name", "worker-sg-${var.cluster_name}-${var.base_domain}",
      "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "owned",
      "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
    ), var.extra_tags)}"
}

resource "aws_security_group_rule" "worker_egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.worker.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "worker_ingress_ssh" {
  count             = "${var.bastion_enabled ? 0 : 1}"
  type              = "ingress"
  security_group_id = "${aws_security_group.worker.id}"

  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 22
  to_port     = 22
}

resource "aws_security_group_rule" "worker_bastion_ssh" {
  count                    = "${var.bastion_enabled ? 1 : 0}"
  type                     = "ingress"
  security_group_id        = "${aws_security_group.worker.id}"
  source_security_group_id = "${aws_security_group.bastion.id}"

  protocol  = "tcp"
  from_port = 22
  to_port   = 22
}

resource "aws_security_group_rule" "worker_ingress_flannel" {
  type              = "ingress"
  security_group_id = "${aws_security_group.worker.id}"

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_flannel_from_master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.worker.id}"
  source_security_group_id = "${aws_security_group.master.id}"

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
}

resource "aws_security_group_rule" "worker_ingress_node_exporter" {
  type              = "ingress"
  security_group_id = "${aws_security_group.worker.id}"

  protocol  = "tcp"
  from_port = 9100
  to_port   = 9100
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_node_exporter_from_master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.worker.id}"
  source_security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 9100
  to_port   = 9100
}

resource "aws_security_group_rule" "worker_ingress_kubelet_insecure" {
  type              = "ingress"
  security_group_id = "${aws_security_group.worker.id}"

  protocol  = "tcp"
  from_port = 10250
  to_port   = 10250
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_kubelet_insecure_from_master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.worker.id}"
  source_security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 10250
  to_port   = 10250
}

resource "aws_security_group_rule" "worker_ingress_kubelet_secure" {
  type              = "ingress"
  security_group_id = "${aws_security_group.worker.id}"

  protocol  = "tcp"
  from_port = 10255
  to_port   = 10255
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_kubelet_secure_from_master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.worker.id}"
  source_security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 10255
  to_port   = 10255
}

resource "aws_security_group_rule" "worker_ingress_services" {
  type              = "ingress"
  security_group_id = "${aws_security_group.worker.id}"

  protocol  = "tcp"
  from_port = 30000
  to_port   = 32767
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_portworx" {
  type              = "ingress"
  security_group_id = "${aws_security_group.worker.id}"

  protocol  = "tcp"
  from_port = 9001
  to_port   = 9021
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_nfs" {
  type              = "ingress"
  security_group_id = "${aws_security_group.worker.id}"

  protocol  = "tcp"
  from_port = 2049
  to_port   = 2049
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_nfs_from_master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.worker.id}"
  source_security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 2049
  to_port   = 2049
}
