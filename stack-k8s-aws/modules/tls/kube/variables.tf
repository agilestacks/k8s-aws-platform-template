variable "kube_ca_cert_pem" {
  description = "PEM-encoded CA certificate"
  type        = "string"
}

variable "kube_ca_key_alg" {
  description = "Algorithm used to generate kube_ca_key"
  type        = "string"
}

variable "kube_ca_key_pem" {
  description = "PEM-encoded CA key"
  type        = "string"
}

variable "front_proxy_ca_cert_pem" {
  description = "PEM-encoded CA certificate"
  type        = "string"
}

variable "front_proxy_ca_key_alg" {
  description = "Algorithm used to generate front_proxy_ca_key"
  type        = "string"
}

variable "front_proxy_ca_key_pem" {
  description = "PEM-encoded CA key"
  type        = "string"
}

variable "kube_apiserver_url" {
  type = "string"
}

variable "service_cidr" {
  type = "string"
}

variable "validity_period" {
  description = <<EOF
Validity period of the self-signed certificates (in hours).
Default is 3 years.
EOF

  type = "string"
}

variable "common_name" {
  type = "string"
  description = "CN for Certificate Request"
  default = ""
}

variable "int_api_fqdn" {
  type = "string"
}
