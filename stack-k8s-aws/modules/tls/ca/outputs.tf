output "kube_ca_cert_pem" {
  value = "${var.kube_ca_cert_pem_path == "" ? join("", tls_self_signed_cert.kube_ca.*.cert_pem) : file(local._kube_ca_cert_pem_path)}"
}

output "kube_ca_key_alg" {
  value = "${var.kube_ca_key_alg == "" ? join("", tls_self_signed_cert.kube_ca.*.key_algorithm) : var.kube_ca_key_alg}"
}

output "kube_ca_key_pem" {
  value = "${var.kube_ca_key_pem_path == "" ? join("", tls_private_key.kube_ca.*.private_key_pem) : file(local._kube_ca_key_pem_path)}"
}

output "front_proxy_ca_cert_pem" {
  value = "${var.front_proxy_ca_cert_pem_path == "" ? join("", tls_self_signed_cert.front_proxy_ca.*.cert_pem) : file(local._front_proxy_ca_cert_pem_path)}"
}

output "front_proxy_ca_key_alg" {
  value = "${var.front_proxy_ca_key_alg == "" ? join("", tls_self_signed_cert.front_proxy_ca.*.key_algorithm) : var.front_proxy_ca_key_alg}"
}

output "front_proxy_ca_key_pem" {
  value = "${var.front_proxy_ca_key_pem_path == "" ? join("", tls_private_key.front_proxy_ca.*.private_key_pem) : file(local._front_proxy_ca_key_pem_path)}"
}

output "etcd_ca_cert_pem" {
  value = "${var.etcd_ca_cert_pem_path == "" ? join("", tls_self_signed_cert.etcd_ca.*.cert_pem) : file(local._etcd_ca_cert_pem_path)}"
}

output "etcd_ca_key_alg" {
  value = "${var.etcd_ca_key_alg == "" ? join("", tls_self_signed_cert.etcd_ca.*.key_algorithm) : var.etcd_ca_key_alg}"
}

output "etcd_ca_key_pem" {
  value = "${var.etcd_ca_key_pem_path == "" ? join("", tls_private_key.etcd_ca.*.private_key_pem) : file(local._etcd_ca_key_pem_path)}"
}
