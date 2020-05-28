resource "random_string" "rnd" {
  length = 4
  special = false
  upper = false
  special = false
}

resource "local_file" "admin_cert" {
  content  = "${module.kube_certs.admin_cert_pem}"
  filename = "${path.cwd}/.terraform/client-${random_string.rnd.result}.pem"
  lifecycle {
    create_before_destroy = true
  }
}

resource "local_file" "admin_key" {
  content  = "${module.kube_certs.admin_key_pem}"
  filename = "${path.cwd}/.terraform/client-key-${random_string.rnd.result}.pem"
  lifecycle {
    create_before_destroy = true
  }
}

resource "local_file" "ca_cert" {
  content  = "${module.ca_certs.kube_ca_cert_pem}"
  filename = "${path.cwd}/.terraform/ca-${random_string.rnd.result}.pem"
  lifecycle {
    create_before_destroy = true
  }
}

resource "local_file" "ca_key" {
  content  = "${module.ca_certs.kube_ca_key_pem}"
  filename = "${path.cwd}/.terraform/ca-key-${random_string.rnd.result}.pem"
  lifecycle {
    create_before_destroy = true
  }
}
