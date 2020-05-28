data "template_file" "kubeadm" {
  template = "${file("${path.module}/resources/kubeadm-assets.sh")}"

  vars {
    CNI_VERSION    = "v0.8.2"
    CRICTL_VERSION = "v1.16.0"
    RELEASE        = "${var.kubernetes_version}"
  }
}

data "ignition_file" "kubeadm_assets" {
  filesystem = "root"
  path       = "/opt/kubeadm/kubeadm-assets.sh"
  mode       = 0755

  content {
    content = "${data.template_file.kubeadm.rendered}"
  }
}

data "template_file" "kubeadm_init_config" {
  template = "${file("${path.module}/resources/kubeadm-init.yaml")}"

  vars {
    CLUSTER_NAME   = "${var.cluster_name}.${var.base_domain}"
    API_URL        = "${var.api_url}"
    KUBEADM_TOKEN  = "${var.kubeadm_token}"
    ETCD_URL       = "${jsonencode(formatlist("https://%s:2379", var.etcd_url))}"
    CLOUD_PROVIDER = "${var.cloud_provider}"
  }
}

data "ignition_file" "kubeadm_init_config" {
  filesystem = "root"
  path       = "/opt/kubeadm/kubeadm-init.yaml"
  mode       = 0755

  content {
    content = "${data.template_file.kubeadm_init_config.rendered}"
  }
}

data "template_file" "kubeadm_join_config" {
  template = "${file("${path.module}/resources/kubeadm-join.yaml")}"

  vars {
    CLUSTER_NAME   = "${var.cluster_name}.${var.base_domain}"
    KUBEADM_TOKEN  = "${var.kubeadm_token}"
    API_URL        = "${var.api_url}"
    NODE_LABELS    = "${var.worker_node_label}"
    CLOUD_PROVIDER = "${var.cloud_provider}"
  }
}

data "ignition_file" "kubeadm_join_config" {
  filesystem = "root"
  path       = "/opt/kubeadm/kubeadm-join.yaml"
  mode       = 0755

  content {
    content = "${data.template_file.kubeadm_join_config.rendered}"
  }
}

data "template_file" "kubeadm_init" {
  template = "${file("${path.module}/resources/services/kbd-init.service")}"

  vars {
    ETCD_URL = "${var.etcd_url[0]}"
  }
}

data "ignition_systemd_unit" "kubeadm_init" {
  name    = "kbd-init.service"
  enabled = true
  content = "${data.template_file.kubeadm_init.rendered}"
}

data "template_file" "kubeadm_join" {
  template = "${file("${path.module}/resources/services/kbd-join.service")}"

  vars {
    API_URL = "${var.api_url}"
  }
}

data "ignition_systemd_unit" "kubeadm_join" {
  name    = "kbd-init.service"
  enabled = true
  content = "${data.template_file.kubeadm_join.rendered}"
}

#---
data "template_file" "kubeadm_master_manifest_service" {
  template = "${file("${path.module}/resources/services/kbd-config.service")}"

  vars {
    API_URL = "${var.api_url}"
  }
}

data "ignition_systemd_unit" "kubeadm_master_manifest_service" {
  name    = "kbd-config.service"
  enabled = true
  content = "${data.template_file.kubeadm_master_manifest_service.rendered}"
}

data "template_file" "kubeadm_master_manifest_script" {
  template = "${file("${path.module}/resources/kbd-config.sh")}"
}

data "ignition_file" "kubeadm_master_manifest_script" {
  filesystem = "root"
  path       = "/opt/kubeadm/kbd-config.sh"
  mode       = 0644

  content {
    content = "${data.template_file.kubeadm_master_manifest_script.rendered}"
  }
}

data "template_file" "manifest_file_list" {
  count    = "${length(var.manifest_names)}"
  template = "${file("${path.module}/resources/manifests/${var.manifest_names[count.index]}")}"

  vars {
    cluster_name = "${var.cluster_name}"
    server       = "${var.kube_apiserver_url}"
    cluster_cidr = "${var.cluster_cidr}"
    service_cidr = "${var.service_cidr}"
    admin_email  = "${var.admin_user}@${var.cluster_name}"
  }
}

data "ignition_file" "manifest_file_list" {
  count      = "${length(var.manifest_names)}"
  filesystem = "root"
  mode       = "0644"

  path = "/opt/kubeadm/manifests/${var.manifest_names[count.index]}"

  content {
    content = "${data.template_file.manifest_file_list.*.rendered[count.index]}"
  }
}

resource "random_string" "token_1" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "token_2" {
  length  = 16
  special = false
  upper   = false
}

# Kubernetes Service Account
resource "tls_private_key" "service_account" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

data "ignition_file" "service_account_key" {
  filesystem = "root"
  path       = "/opt/asi/tls/sa.key"
  mode       = "0644"

  content {
    content = "${tls_private_key.service_account.private_key_pem}"
  }
}

data "ignition_file" "service_account_crt" {
  filesystem = "root"
  path       = "/opt/asi/tls/sa.pub"
  mode       = "0644"

  content {
    content = "${tls_private_key.service_account.public_key_pem}"
  }
}
