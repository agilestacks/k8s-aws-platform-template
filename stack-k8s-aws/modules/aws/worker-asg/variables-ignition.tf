# This file is supposed to be symlinked in consuming modules

variable "ign_max_user_watches_id" {
  type = "string"
}

variable "ign_docker_dropin_id" {
  type = "string"
}


variable "ign_locksmithd_service_id" {
  type = "string"
}

variable "ign_installer_runtime_mappings_id" {
  type = "string"
}



variable "ign_update_ca_certificates_dropin_id" {
  type = "string"
}

variable "ign_ca_cert_id_list" {
  type        = "list"
  description = "The list of public CA certificate ignition file IDs."
}

variable "ign_iscsi_service_id" {
  type = "string"
}
