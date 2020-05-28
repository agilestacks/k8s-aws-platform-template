resource "random_string" "rnd" {
  length = 4
  special = false
  upper = false
  special = false
}

module "stack" {
  source = "../../stack"
  name   = "${var.cluster_name}.${var.base_domain}"
}

data "ignition_config" "main" {
  files = [
    "${var.ign_kube_certs_list}",
    "${var.ign_etcd_crt_id_list}",
    "${var.ign_ca_cert_id_list}",
    "${data.ignition_file.detect_master.id}",
    "${data.ignition_file.init_assets.id}",
    "${var.ign_installer_runtime_mappings_id}",
    "${var.ign_max_user_watches_id}",
    "${var.ign_kubeadm_assets_id}",
    "${var.ign_kubeadm_config_id}",
    "${var.ign_kubeadm_manifest_file_ids}",
    "${var.ign_kubeadm_manifest_script_id}",
  ]
  systemd = ["${compact(list(
    var.ign_docker_dropin_id,
    var.ign_locksmithd_service_id,
    var.ign_update_ca_certificates_dropin_id,
    var.kubeadm_master_init_service_id,
    var.ign_kubeadm_manifest_service_id,
    var.ign_iscsi_service_id,
  ))}"]
}

data "template_file" "detect_master" {
  template = "${file("${path.module}/resources/detect-master.sh")}"

  vars {
    target_group_arn = "${var.aws_lb_api_target_group_arn}"
    master_elb_enabled = "${var.k8s_api_fqdn == ""}"
    k8s_api_url        = "https://${var.k8s_api_fqdn}:6443/"
  }
}

data "ignition_file" "detect_master" {
  filesystem = "root"
  path       = "/opt/detect-master.sh"
  mode       = 0755

  content {
    content = "${data.template_file.detect_master.rendered}"
  }
}

data "template_file" "init_assets" {
  template = "${file("${path.module}/resources/init-assets.sh")}"

  vars {
    cluster_name       = "${var.cluster_name}.${var.base_domain}"
    awscli_image       = "${var.container_images["awscli"]}"
  }
}

data "ignition_file" "init_assets" {
  filesystem = "root"
  path       = "/opt/init-assets.sh"
  mode       = 0755

  content {
    content = "${data.template_file.init_assets.rendered}"
  }
}

resource "local_file" "ignition" {
  content  = "${aws_s3_bucket_object.ignition_master.content}"
  filename = "${path.cwd}/.terraform/master-${random_string.rnd.result}.json"
  lifecycle {
    create_before_destroy = true
  }
}
