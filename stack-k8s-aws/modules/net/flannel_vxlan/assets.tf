data "template_file" "flannel" {
  template = "${file("${path.module}/resources/manifests/kube-flannel.yaml")}"

  vars {
    cluster_cidr      = "${var.cluster_cidr}"
    flannel_cni_image = "${var.container_images["flannel_cni"]}"
    flannel_image     = "${var.container_images["flannel"]}"
  }
}

data "ignition_file" "flannel" {
  count = "${var.enabled ? 1 : 0}"
  filesystem = "root"
  path       = "/opt/asi/net-manifests/kube-flannel.yaml"
  mode       = "0644"

  content {
    content  = "${data.template_file.flannel.rendered}"
  }
}
