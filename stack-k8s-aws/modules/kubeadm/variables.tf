variable "kubernetes_version" {
  type = "string"
}

variable "base_domain" {
  type    = "string"
  default = ""
}

variable "worker_node_label" {
  type        = "string"
  description = "Label that Kubelet will apply on the node"
}

variable "manifest_names" {
  default = [
    "kube-flannel.yaml",
    "kube-system-rbac-role-binding.yaml",
    "kubeconfig-in-cluster.yaml",
    "rbac-admin-role-binding.yaml",
    "storage-class.yaml",
  ]
}

variable "cluster_name" {
  type = "string"
}

variable "admin_user" {
  type = "string"
}

variable "cluster_cidr" {
  type = "string"
}

variable "service_cidr" {
  type = "string"
}

variable "kube_apiserver_url" {
  type = "string"
}

variable "etcd_url" {
  type = "list"
}

variable "api_url" {
  type = "string"
}

variable "kubeadm_token" {
  type = "string"
}

variable "cloud_provider" {
  type = "string"
}
