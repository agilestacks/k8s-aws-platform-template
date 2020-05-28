locals {
  // see https://github.com/hashicorp/terraform/issues/9858  #etcd_initial_cluster_list = "${concat(var.etcd_initial_cluster_list, list("dummy"))}"

  metadata_env = "EnvironmentFile=/run/metadata/coreos"

  metadata_deps = <<EOF
Requires=coreos-metadata.service
After=coreos-metadata.service
EOF
}

data "template_file" "etcd_names" {
  count    = "${var.etcd_count}"
  template = "${var.internal_etcd ? "etcd.i.${var.cluster_name}.${var.base_domain}" : "etcd-${count.index}.i.${var.cluster_name}.${var.base_domain}"}"
}

data "template_file" "advertise_client_urls" {
  count    = "${var.etcd_count}"
  template = "https://${var.etcd_advertise_name_list[count.index]}:2379"
}

data "template_file" "initial_advertise_peer_urls" {
  count    = "${var.etcd_count}"
  template = "https://${var.etcd_advertise_name_list[count.index]}:2380"
}

data "template_file" "initial_cluster" {
  count    = "${var.etcd_count}"
  template = "${data.template_file.etcd_names.*.rendered[count.index]}=https://${var.etcd_initial_cluster_list[count.index]}:2380"
}

data "template_file" "etcd" {
  count    = "${var.etcd_count}"
  template = "${file("${path.module}/resources/dropins/40-etcd-cluster.conf")}"

  vars = {
    #advertise_client_urls       = "${var.internal_etcd ? "https://$${COREOS_EC2_IPV4_LOCAL}:2379" : data.template_file.advertise_client_urls.*.rendered[count.index]}"
    advertise_client_urls = "${var.internal_etcd ? "https://etcd.i.${var.cluster_name}.${var.base_domain}:2379" : data.template_file.advertise_client_urls.*.rendered[count.index]}"
    container_image       = "${var.container_images["etcd"]}"

    #initial_advertise_peer_urls = "${var.internal_etcd ? "https://$${COREOS_EC2_IPV4_LOCAL}:2380" : data.template_file.initial_advertise_peer_urls.*.rendered[count.index]}"
    initial_advertise_peer_urls = "${var.internal_etcd ? "https://etcd.i.${var.cluster_name}.${var.base_domain}:2380" : data.template_file.initial_advertise_peer_urls.*.rendered[count.index]}"
    initial_cluster             = "${format("--initial-cluster=%s", join(",", data.template_file.initial_cluster.*.rendered))}"
    metadata_deps               = "${var.use_metadata ? local.metadata_deps : ""}"
    metadata_env                = "${var.use_metadata ? local.metadata_env : ""}"
    name                        = "${data.template_file.etcd_names.*.rendered[count.index]}"
    scheme                      = "https"
    initial_cluster_token       = "${var.internal_etcd ? format("--initial-cluster-token=%s", var.uuid) : ""}"
    initial_cluster_state       = "${var.internal_etcd ? format("--initial-cluster-state=%s", "new") : ""}"
  }
}

data "ignition_systemd_unit" "etcd" {
  count   = "${var.etcd_count}"
  name    = "etcd-member.service"
  enabled = true

  dropin = [
    {
      name    = "40-etcd-cluster.conf"
      content = "${data.template_file.etcd.*.rendered[count.index]}"
    },
  ]
}

data "ignition_systemd_unit" "etcd_tags" {
  name    = "etcd-tags.service"
  enabled = true
  content = "${file("${path.module}/resources/services/etcd-tags.service")}"
}

data "ignition_file" "etcd_ca" {
  count = 1

  path       = "/etc/ssl/etcd/ca.crt"
  mode       = 0644
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.etcd_ca_cert_pem}"
  }
}

data "ignition_file" "etcd_client_key" {
  path       = "/etc/ssl/etcd/client.key"
  mode       = 0400
  uid        = 0
  gid        = 0
  filesystem = "root"

  content {
    content = "${var.etcd_client_key_pem}"
  }
}

data "ignition_file" "etcd_client_crt" {
  path       = "/etc/ssl/etcd/client.crt"
  mode       = 0400
  uid        = 0
  gid        = 0
  filesystem = "root"

  content {
    content = "${var.etcd_client_crt_pem}"
  }
}

data "ignition_file" "etcd_server_key" {
  count = 1

  path       = "/etc/ssl/etcd/server.key"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.etcd_server_key_pem}"
  }
}

data "ignition_file" "etcd_server_crt" {
  count = 1

  path       = "/etc/ssl/etcd/server.crt"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.etcd_server_crt_pem}"
  }
}

data "ignition_file" "etcd_peer_key" {
  count = 1

  path       = "/etc/ssl/etcd/peer.key"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.etcd_peer_key_pem}"
  }
}

data "ignition_file" "etcd_peer_crt" {
  count = 1

  path       = "/etc/ssl/etcd/peer.crt"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.etcd_peer_crt_pem}"
  }
}

# Client certs for kube-apiserver
data "ignition_file" "kube_etcd_ca_cert" {
  filesystem = "root"
  mode       = "0644"
  path = "/opt/asi/tls/etcd-client-ca.crt"

  content {
    content = "${var.etcd_ca_cert_pem}"
  }
}

data "ignition_file" "kube_etcd_client_key" {
   filesystem = "root"
   mode       = "0600"
   path = "/opt/asi/tls/etcd-client.key"

  content {
    content = "${var.etcd_client_key_pem}"
  }
}

data "ignition_file" "kube_etcd_client_crt" {
   filesystem = "root"
   mode       = "0644"
   path = "/opt/asi/tls/etcd-client.crt"

  content {
    content = "${var.etcd_client_crt_pem}"
  }
}
