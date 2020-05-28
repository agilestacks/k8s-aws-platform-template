resource "random_string" "rnd" {
  length = 4
  special = false
  upper = false
  special = false
}

data "ignition_config" "main" {
  files = [
    "${var.ign_installer_runtime_mappings_id}",
    "${var.ign_max_user_watches_id}",
    "${var.ign_ca_cert_id_list}",
    "${var.ign_kubeadm_assets_id}",
    "${var.ign_kubeadm_join_config_id}",
  ]

  systemd = [
    "${var.ign_docker_dropin_id}",
    "${var.ign_locksmithd_service_id}",
    "${var.ign_update_ca_certificates_dropin_id}",
    "${var.ign_iscsi_service_id}",
    "${var.kubeadm_master_init_service_id}",
  ]
}

data "ignition_config" "with_ebs" {
  append {
    source = "s3://${aws_s3_bucket_object.ignition_worker.bucket}/${aws_s3_bucket_object.ignition_worker.key}"
    verification = "sha512-${sha512(data.ignition_config.main.rendered)}"
  }

  systemd = [
    "${data.ignition_systemd_unit.kubelet_dropin.id}",
    "${data.ignition_systemd_unit.varlibkubeletpods.id}"
  ]

  filesystems = [
    "${data.ignition_filesystem.varlibkubeletpods.id}",
  ]
}

resource "local_file" "ignition" {
  content  = "${aws_s3_bucket_object.ignition_worker.content}"
  filename = "${path.cwd}/.terraform/worker-${local.rnd}.json"
  lifecycle {
    create_before_destroy = true
  }
}
