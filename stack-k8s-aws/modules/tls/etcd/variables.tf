# Used for external etcd cluster
/*variable "self_signed" {
  description = <<EOF
If set to true, self-signed certificates are generated.
If set to false, only the passed CA and client certs are being used.
EOF
}

variable "etcd_ca_cert_path" {
  type        = "string"
  description = "external CA certificate"
}

variable "etcd_client_cert_path" {
  type = "string"
}

variable "etcd_client_key_path" {
  type = "string"
}
*/
variable "validity_period" {
  description = <<EOF
Validity period of the self-signed certificates (in hours).
Default is 3 years.
EOF

  type = "string"

  default = 26280
}

variable "service_cidr" {
  type = "string"
}

variable "etcd_cert_dns_names" {
  type = "list"
}

variable "etcd_cert_common_name" {
  type = "string"
}

variable "etcd_ca_cert_pem" {
  type = "string"
}

variable "etcd_ca_key_alg" {
  type = "string"
}

variable "etcd_ca_key_pem" {
  type = "string"
}
