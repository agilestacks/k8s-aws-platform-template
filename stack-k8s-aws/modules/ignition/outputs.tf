output "max_user_watches_id" {
  value = "${data.ignition_file.max_user_watches.id}"
}

output "max_user_watches_rendered" {
  value = "${data.template_file.max_user_watches.rendered}"
}

output "docker_dropin_id" {
  value = "${data.ignition_systemd_unit.docker_dropin.id}"
}

output "docker_dropin_rendered" {
  value = "${data.template_file.docker_dropin.rendered}"
}

output "kubelet_service_id" {
  value = "${data.ignition_systemd_unit.kubelet.id}"
}

output "kubelet_service_rendered" {
  value = "${data.template_file.kubelet.rendered}"
}

output "init_assets_service_id" {
  value = "${data.ignition_systemd_unit.init_assets.id}"
}

output "etcd_tags_service_id" {
  value = "${data.ignition_systemd_unit.etcd_tags.id}"
}

output "locksmithd_service_id" {
  value = "${data.ignition_systemd_unit.locksmithd.id}"
}

output "installer_runtime_mappings_id" {
  value = "${data.ignition_file.installer_runtime_mappings.id}"
}

output "installer_runtime_mappings_rendered" {
  value = "${data.template_file.installer_runtime_mappings.rendered}"
}

output "tx_off_service_id" {
  value = "${data.ignition_systemd_unit.tx_off.id}"
}

output "tx_off_service_rendered" {
  value = "${data.template_file.tx_off.rendered}"
}

output "etcd_dropin_id_list" {
  value = "${data.ignition_systemd_unit.etcd.*.id}"
}

output "coreos_metadata_dropin_id" {
  value = "${data.ignition_systemd_unit.coreos_metadata.id}"
}

output "coreos_metadata_dropin_rendered" {
  value = "${data.template_file.coreos_metadata.rendered}"
}

output "update_ca_certificates_dropin_id" {
  value = "${data.ignition_systemd_unit.update_ca_certificates_dropin.id}"
}

output "update_ca_certificates_dropin_rendered" {
  value = "${data.template_file.update_ca_certificates_dropin.rendered}"
}

output "iscsi_service_id" {
  value = "${data.ignition_systemd_unit.iscsi.id}"
}


output "workers_ca_cert_id_list" {
value = ["${compact(flatten(list(
     data.ignition_file.custom_ca_cert_pem.*.id,
     list(
       data.ignition_file.kube_ca_cert_pem.id,
     ),
   )))}"]
}


output "masters_ca_cert_id_list" {
value = ["${compact(flatten(list(
     data.ignition_file.custom_ca_cert_pem.*.id,
     list(
       data.ignition_file.kube_ca_cert_pem.id,
       data.ignition_file.etcd_ca_cert_pem.id,
     ),
   )))}"]
}

# Used by etcd module
output "etcd_crt_id_list" {
  value = ["${compact(flatten(list(
    data.ignition_file.etcd_ca.*.id,
    data.ignition_file.etcd_client_key.*.id,
    data.ignition_file.etcd_client_crt.*.id,
    data.ignition_file.etcd_server_key.*.id,
    data.ignition_file.etcd_server_crt.*.id,
    data.ignition_file.etcd_peer_key.*.id,
    data.ignition_file.etcd_peer_crt.*.id,
  )))}"]
}

 # Used by masters module in case of internal etcd
output "kube_etcd_crt_id_list" {
  value = ["${compact(flatten(list(
    list(
      data.ignition_file.kube_etcd_ca_cert.id,
      data.ignition_file.kube_etcd_client_key.id,
      data.ignition_file.kube_etcd_client_crt.id,
    ),
    data.ignition_file.etcd_ca.*.id,
    data.ignition_file.etcd_client_key.*.id,
    data.ignition_file.etcd_client_crt.*.id,
    data.ignition_file.etcd_server_key.*.id,
    data.ignition_file.etcd_server_crt.*.id,
    data.ignition_file.etcd_peer_key.*.id,
    data.ignition_file.etcd_peer_crt.*.id,
  )))}"]
}
