output "ignition_file_id_list" {
  value = ["${compact(flatten(list(
    list(    
      data.ignition_file.service_account_key.id,
      data.ignition_file.service_account_crt.id,
    ),
    data.ignition_file.manifest_file_list.*.id,
   )))}"]
}

output "token" {
    value = "${random_string.token_1.result}.${random_string.token_2.result}"
}

output "manifest_config_service_id" {
    value = "${data.ignition_systemd_unit.kubeadm_master_manifest_service.id}"
}

output "manifest_script_id" {
    value = "${data.ignition_file.kubeadm_master_manifest_script.id}"
}

output "kubeadm_master_init_service_id" {
  value = "${data.ignition_systemd_unit.kubeadm_init.id}"
}

output "kubeadm_join_service_id" {
  value = "${data.ignition_systemd_unit.kubeadm_join.id}"
}

output "kubeadm_init_config_id" {
  value = "${data.ignition_file.kubeadm_init_config.id}"
}
output "kubeadm_join_config_id" {
  value = "${data.ignition_file.kubeadm_join_config.id}"
}

output "kubeadm_assets_id" {
  value = "${data.ignition_file.kubeadm_assets.id}"
}