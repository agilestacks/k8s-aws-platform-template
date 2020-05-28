data "template_file" "calico" {
  template = "${file("${path.module}/resources/manifests/kube-calico.yaml")}"

  vars {
    calico_cni_image = "${var.container_images["calico_cni"]}"
    calico_image     = "${var.container_images["calico"]}"
    cluster_cidr     = "${var.cluster_cidr}"
    mtu              = "${var.mtu}"
  }
}
data "ignition_file" "calico" {
  count = "${var.enabled ? 1 : 0}"
  filesystem = "root"
  path       = "/opt/asi/net-manifests/kube-calico.yaml"
  mode       = "0644"

  content {
    content  = "${data.template_file.calico.rendered}"
  }
}
