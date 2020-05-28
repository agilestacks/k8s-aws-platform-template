resource "aws_internet_gateway" "igw" {
  count  = "${var.external_vpc_id == "" ? 1 : 0}"
  vpc_id = "${data.aws_vpc.cluster_vpc.id}"

  tags = "${merge(map(
      "Name", "igw-${var.cluster_name}-${var.base_domain}",
      "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "shared",
      "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
    ), var.extra_tags)}"
}

resource "aws_route_table" "default" {
  count  = "${var.external_vpc_id == "" ? 1 : 0}"
  vpc_id = "${data.aws_vpc.cluster_vpc.id}"

  tags = "${merge(map(
      "Name", "public-${var.cluster_name}-${var.base_domain}",
      "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "shared",
      "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
    ), var.extra_tags)}"
}

resource "aws_main_route_table_association" "main_vpc_routes" {
  count          = "${var.external_vpc_id == "" ? 1 : 0}"
  vpc_id         = "${data.aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.default.id}"
}

resource "aws_route" "igw_route" {
  count                  = "${var.external_vpc_id == "" ? 1 : 0}"
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = "${aws_route_table.default.id}"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_subnet" "master_subnet" {
  count = "${var.external_vpc_id == "" ? var.master_az_count : 0}"

  vpc_id = "${data.aws_vpc.cluster_vpc.id}"

  cidr_block = "${length(var.master_subnets) > 1 ?
    "${element(var.master_subnets, count.index)}" :
    "${cidrsubnet(data.aws_vpc.cluster_vpc.cidr_block, 5, count.index)}"
  }"

  availability_zone = "${var.master_azs[count.index]}"

  tags = "${merge(map(
      "Name", "master-${ "${length(var.master_azs)}" > 0 ?
     "${var.master_azs[count.index]}-${var.cluster_name}-${var.base_domain}" :
     "${data.aws_availability_zones.azs.names[count.index]}-${var.cluster_name}-${var.base_domain}" }",
      "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "shared",
      "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
    ), var.extra_tags)}"
}

resource "aws_subnet" "bastion_subnet" {
  count = "${var.bastion_enabled ? var.master_az_count : 0}"

  vpc_id = "${data.aws_vpc.cluster_vpc.id}"

  cidr_block = "${length(var.bastion_subnets) > 1 ?
    "${element(var.bastion_subnets, count.index)}" :
    "${cidrsubnet(data.aws_vpc.cluster_vpc.cidr_block, 5, count.index + var.master_az_count + var.worker_az_count)}"
  }"

  availability_zone = "${var.master_azs[count.index]}"

  tags = "${merge(map(
      "Name", "bastion-${ "${length(var.master_azs)}" > 0 ?
     "${var.master_azs[count.index]}-${var.cluster_name}-${var.base_domain}" :
     "${data.aws_availability_zones.azs.names[count.index]}-${var.cluster_name}-${var.base_domain}" }",
      "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "shared",
      "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
    ), var.extra_tags)}"
}

resource "aws_route_table_association" "route_net" {
  count          = "${var.external_vpc_id == "" && var.k8s_api_fqdn == "" ? var.master_az_count : 0}"
  route_table_id = "${aws_route_table.default.id}"
  subnet_id      = "${aws_subnet.master_subnet.*.id[count.index]}"
}

resource "aws_route_table_association" "route_bastion" {
  count          = "${var.external_vpc_id == "" && var.bastion_enabled ? var.master_az_count : 0}"
  route_table_id = "${aws_route_table.default.id}"
  subnet_id      = "${aws_subnet.bastion_subnet.*.id[count.index]}"
}

resource "aws_eip" "nat_eip" {
  #||
  count = "${var.external_vpc_id == "" && var.nat_gw_workers && length(var.nat_gw_eipallocs) == 0 ?
    min(var.master_az_count, var.worker_az_count) : 0}"
  vpc   = true

  # Terraform does not declare an explicit dependency towards the internet gateway.
  # this can cause the internet gateway to be deleted/detached before the EIPs.
  # https://github.com/coreos/tectonic-installer/issues/1017#issuecomment-307780549
  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_eip" "bastion_eip" {
  count = "${var.bastion_enabled ? 1 : 0}"
  vpc   = true

  # Terraform does not declare an explicit dependency towards the internet gateway.
  # this can cause the internet gateway to be deleted/detached before the EIPs.
  # https://github.com/coreos/tectonic-installer/issues/1017#issuecomment-307780549
  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_nat_gateway" "nat_gw" {
  #||
  count         = "${var.external_vpc_id == "" && var.nat_gw_workers ? min(var.master_az_count, var.worker_az_count) : 0}"
  allocation_id = "${length(var.nat_gw_eipallocs) == 0 ?
    element(concat(aws_eip.nat_eip.*.id, list("")), count.index) :
    element(concat(var.nat_gw_eipallocs, list("error")), count.index)}" // let wrap-around and get an error if counts mismatch
  subnet_id     = "${var.bastion_enabled ? element(concat(aws_subnet.bastion_subnet.*.id, list("")), count.index) : aws_subnet.master_subnet.*.id[count.index]}"
  tags {
    Name = "${var.cluster_name}.${var.base_domain}"
  }
}
