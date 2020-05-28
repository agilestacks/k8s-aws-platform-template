variable "container_images" {
  description = "Container images to use"
  type        = "map"
}

variable "image_re" {
  description = <<EOF
(internal) Regular expression used to extract repo and tag components from image strings
EOF

  type = "string"
}

variable "image_re_torcx" {
  description = <<EOF
(internal) Regular expression used to extract repo and tag components from image strings
EOF

  type = "string"
}

variable "internal_etcd" {
  type = "string"
}

variable "kubelet_debug_config" {
  type        = "string"
  default     = ""
  description = "internal debug flags for the kubelet (used in CI only)"
}

variable "kubelet_node_label" {
  type        = "string"
  description = "Label that Kubelet will apply on the node"
}

variable "kubelet_node_taints" {
  type        = "string"
  description = "(optional) Taints that Kubelet will apply on the node"
  default     = ""
}

variable "cloud_provider" {
  type        = "string"
  description = "(optional) The cloud provider to be used for the kubelet."
  default     = ""
}

variable "cloud_provider_config" {
  type        = "string"
  description = "(optional) The cloud provider config to be used for the kubelet."
  default     = ""
}

variable "bootstrap_upgrade_cl" {
  type        = "string"
  description = "(optional) Whether to trigger a ContainerLinux OS upgrade during the bootstrap process."
  default     = "false"
}

variable "torcx_store_url" {
  type        = "string"
  description = "(optional) URL template for torcx store. Leave empty to use the default CoreOS endpoint."
  default     = ""
}

variable "etcd_count" {
  type    = "string"
  default = 0
}

variable "etcd_advertise_name_list" {
  type    = "list"
  default = []
}

variable "etcd_initial_cluster_list" {
  type    = "list"
  default = []
}

variable "base_domain" {
  type    = "string"
  default = ""
}

variable "cluster_name" {
  type    = "string"
  default = ""
}

variable "metadata_provider" {
  type    = "string"
  default = ""
}

variable "uuid" {
  type        = "string"
  default     = ""
  description = "uuid for internal etcd cluster id"
}

variable "use_metadata" {
  default = true
}

variable "kube_ca_cert_pem" {
  type        = "string"
  description = "The Kubernetes CA certificate in PEM format."
}

variable "etcd_ca_cert_pem" {
  type        = "string"
  description = "The etcd kube CA certificate in PEM format."
}

variable "etcd_client_key_pem" {
  default = ""
}

variable "etcd_client_crt_pem" {
  default = ""
}

variable "etcd_server_key_pem" {
  default = ""
}

variable "etcd_server_crt_pem" {
  default = ""
}

variable "etcd_peer_key_pem" {
  default = ""
}

variable "etcd_peer_crt_pem" {
  default = ""
}

variable "custom_ca_cert_pem_list" {
  type        = "list"
  description = "(optional) A list of custom CAs in PEM format."
}

variable "iscsi_enabled" {
  type    = "string"
  default = "false"
}

variable "volume_plugin_dir" {
  type = "string"
  description = "Directory mounted in kubelet that contains kubernetes volume plugins"
  default = "/var/lib/kubelet/volumeplugins"
}