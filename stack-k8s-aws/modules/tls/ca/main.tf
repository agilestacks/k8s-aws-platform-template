locals {
  _etcd_ca_cert_pem_path            = "${var.etcd_ca_cert_pem_path == "" ? "/dev/null" : var.etcd_ca_cert_pem_path}"
  _etcd_ca_key_pem_path             = "${var.etcd_ca_key_pem_path == "" ? "/dev/null" : var.etcd_ca_key_pem_path}"
  _kube_ca_cert_pem_path            = "${var.kube_ca_cert_pem_path == "" ? "/dev/null" : var.kube_ca_cert_pem_path}"
  _kube_ca_key_pem_path             = "${var.kube_ca_key_pem_path == "" ? "/dev/null" : var.kube_ca_key_pem_path}"
  _front_proxy_ca_cert_pem_path      = "${var.front_proxy_ca_cert_pem_path == "" ? "/dev/null" : var.front_proxy_ca_cert_pem_path}"
  _front_proxy_ca_key_pem_path       = "${var.front_proxy_ca_key_pem_path == "" ? "/dev/null" : var.front_proxy_ca_key_pem_path}"
}


# etcd CA
resource "tls_private_key" "etcd_ca" {
  count = "${var.etcd_ca_key_pem_path == "" ? 1 : 0}"

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "etcd_ca" {
  count = "${var.etcd_ca_cert_pem_path == "" ? 1 : 0}"

  key_algorithm   = "${tls_private_key.etcd_ca.algorithm}"
  private_key_pem = "${tls_private_key.etcd_ca.private_key_pem}"

  subject {
    common_name         = "etcd-ca"
    organization        = "${uuid()}"
    organizational_unit = "etcd"
  }

  is_ca_certificate  = true

  validity_period_hours = "${var.validity_period}"

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]

  lifecycle {
    ignore_changes = ["subject"]
  }
}

# kube CA
resource "tls_private_key" "kube_ca" {
  count = "${var.kube_ca_key_pem_path == "" ? 1 : 0}"

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "kube_ca" {
  count = "${var.kube_ca_cert_pem_path == "" ? 1 : 0}"

  key_algorithm   = "${tls_private_key.kube_ca.algorithm}"
  private_key_pem = "${tls_private_key.kube_ca.private_key_pem}"

  subject {
    common_name         = "kubernetes-ca"
    organization        = "${uuid()}"
    organizational_unit = "bootkube"
  }

  is_ca_certificate  = true
  validity_period_hours = "${var.validity_period}"

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]

  lifecycle {
    ignore_changes = ["subject"]
  }
}

# Intermediate front-proxy CA
resource "tls_private_key" "front_proxy_ca" {
  count = "${var.front_proxy_ca_key_pem_path == "" ? 1 : 0}"

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "front_proxy_ca" {
  count = "${var.front_proxy_ca_cert_pem_path == "" ? 1 : 0}"

  key_algorithm   = "${tls_private_key.front_proxy_ca.algorithm}"
  private_key_pem = "${tls_private_key.front_proxy_ca.private_key_pem}"

  subject {
    common_name         = "front-proxy-ca"
    organization        = "${uuid()}"
    organizational_unit = "bootkube"
  }

  is_ca_certificate  = true

  validity_period_hours = "${var.validity_period}"

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]

  lifecycle {
    ignore_changes = ["subject"]
  }
}

