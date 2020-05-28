variable "vpc_id" {}

variable "name" {
  default = "private"
}

variable "cidr_block" {
  default = "10.0.1.0/24"
}

variable "availability_zone" {
  default = ""
}

variable "multi_az_enabled" {
  type = "string"
}

variable "cluster" {
  description = "Name of the Kubernetes to be able to bind subnet"
}

data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

resource "aws_subnet" "main" {
  count             = "${var.multi_az_enabled ? 0 : 1}"
  vpc_id            = "${data.aws_vpc.selected.id}"
  cidr_block        = "${var.cidr_block}"
  availability_zone = "${var.availability_zone}"

  tags = "${map(
      "Name", "${var.name}",
      "Cluster", "${var.cluster}",
      "kubernetes.io/cluster/${var.cluster}", "owned",
      "kubernetes.io/role/elb", ""
    )}"
}

output "subnet_id" {
  value = "${element(concat(aws_subnet.main.*.id, list("")), 0)}"
}
