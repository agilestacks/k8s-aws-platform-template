data "template_file" "canal" {
  template = "${file("${path.module}/resources/manifests/canal.yaml")}"

  vars {
    cluster_cidr      = "${var.cluster_cidr}"
    flannel_cni_image = "${var.container_images["flannel_cni"]}"
    flannel_image     = "${var.container_images["flannel"]}"
    calico_cni_image  = "${var.container_images["calico_cni"]}"
    calico_image      = "${var.container_images["calico"]}"
    mtu               = "${var.mtu}"
  }
}

data "ignition_file" "canal" {
  count = "${var.enabled ? 1 : 0}"
  filesystem = "root"
  path       = "/opt/asi/net-manifests/canal.yaml"
  mode       = "0644"

  content {
    content  = "${data.template_file.canal.rendered}"
  }
}
