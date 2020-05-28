variable "kube_ca_key_alg" {
  description = "Algorithm used to generate kube_ca_key (required if root_ca_cert is specified)"
  type        = "string"
  default     = "RSA"
}

variable "front_proxy_ca_key_alg" {
  description = "Algorithm used to generate front_proxy_ca_key (required if root_ca_cert is specified)"
  type        = "string"
  default     = "RSA"
}

variable "service_serving_ca_key_alg" {
  description = "Algorithm used to generate service_serving_ca_key (required if root_ca_cert is specified)"
  type        = "string"
  default     = "RSA"
}

variable "etcd_ca_key_alg" {
  description = "Algorithm used to generate etcd_ca_key (required if root_ca_cert is specified)"
  type        = "string"
  default     = "RSA"
}

variable "etcd_ca_cert_pem_path" {
  type    = "string"
  default = ""
}

variable "etcd_ca_key_pem_path" {
  type    = "string"
  default = ""
}

variable "kube_ca_cert_pem_path" {
  type    = "string"
  default = ""
}

variable "kube_ca_key_pem_path" {
  type    = "string"
  default = ""
}

variable "front_proxy_ca_cert_pem_path" {
  type    = "string"
  default = ""
}

variable "front_proxy_ca_key_pem_path" {
  type    = "string"
  default = ""
}

variable "validity_period" {
  description = <<EOF
Validity period of the self-signed certificates (in hours).
Default is 3 years.
EOF

  type = "string"

  default = 26280
}
