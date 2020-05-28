data "template_file" "max_user_watches" {
  template = "${file("${path.module}/resources/sysctl.d/max-user-watches.conf")}"
}

data "ignition_file" "max_user_watches" {
  filesystem = "root"
  path       = "/etc/sysctl.d/10-max-user-watches.conf"
  mode       = "0644"

  content {
    content = "${data.template_file.max_user_watches.rendered}"
  }
}

data "template_file" "docker_dropin" {
  template = "${file("${path.module}/resources/dropins/10-dockeropts.conf")}"
}

data "ignition_systemd_unit" "docker_dropin" {
  name    = "docker.service"
  enabled = true

  dropin = [
    {
      name    = "10-dockeropts.conf"
      content = "${data.template_file.docker_dropin.rendered}"
    },
  ]
}

data "template_file" "installer_runtime_mappings" {
  template = "${file("${path.module}/resources/kubernetes/runtime-mappings.yaml")}"
}

data "ignition_file" "installer_runtime_mappings" {
  filesystem = "root"
  path       = "/etc/kubernetes/installer/runtime-mappings.yaml"
  mode       = 0644

  content {
    content = "${data.template_file.installer_runtime_mappings.rendered}"
  }
}

data "template_file" "kubelet" {
  template = "${file("${path.module}/resources/services/kubelet.service")}"

  vars {
    cloud_provider        = "${var.cloud_provider}"
    node_label            = "${var.kubelet_node_label}"
    node_taints_param     = "${var.kubelet_node_taints != "" ? "--register-with-taints=${var.kubelet_node_taints}" : ""}"
    kubelet_image_url     = "${replace(var.container_images["hyperkube"],var.image_re,"$1")}"
    kubelet_image_tag     = "${replace(var.container_images["hyperkube"],var.image_re,"$2")}"
    volume_plugin_dir     = "${var.volume_plugin_dir}"
  }
}

data "ignition_systemd_unit" "kubelet" {
  name    = "kubelet.service"
  enabled = true
  content = "${data.template_file.kubelet.rendered}"
}

data "ignition_systemd_unit" "init_assets" {
  name    = "init-assets.service"
  enabled = true
  content = "${file("${path.module}/resources/services/init-assets.service")}"
}

data "ignition_systemd_unit" "locksmithd" {
  name = "locksmithd.service"
  mask = true
}


data "template_file" "tx_off" {
  template = "${file("${path.module}/resources/services/tx-off.service")}"
}

data "ignition_systemd_unit" "tx_off" {
  name    = "tx-off.service"
  enabled = true
  content = "${data.template_file.tx_off.rendered}"
}

data "template_file" "coreos_metadata" {
  template = "${file("${path.module}/resources/dropins/10-metadata.conf")}"

  vars {
    metadata_provider = "${var.metadata_provider}"
  }
}

data "ignition_systemd_unit" "coreos_metadata" {
  name    = "coreos-metadata.service"
  enabled = true

  dropin = [
    {
      name    = "10-metadata.conf"
      content = "${data.template_file.coreos_metadata.rendered}"
    },
  ]
}

data "ignition_systemd_unit" "iscsi" {
  name    = "iscsid.service"
  enabled = "${var.iscsi_enabled ? true : false}"
}
