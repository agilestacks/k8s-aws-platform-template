# Kubernetes API Server Proxy
resource "tls_private_key" "front_proxy" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "front_proxy" {
  key_algorithm   = "${tls_private_key.front_proxy.algorithm}"
  private_key_pem = "${tls_private_key.front_proxy.private_key_pem}"

  subject {
    common_name  = "front-proxy-client"
    organization = "kube-master"
  }
}

resource "tls_locally_signed_cert" "front_proxy" {
  cert_request_pem = "${tls_cert_request.front_proxy.cert_request_pem}"

  ca_key_algorithm      = "${var.front_proxy_ca_key_alg}"
  ca_private_key_pem    = "${var.front_proxy_ca_key_pem}"
  ca_cert_pem           = "${var.front_proxy_ca_cert_pem}"
  validity_period_hours = "${var.validity_period}"

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}
