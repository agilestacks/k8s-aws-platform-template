data "ignition_file" "front_proxy_ca_crt" {
   filesystem = "root"
   mode       = "0644"
   path = "/opt/asi/tls/front-proxy-ca.crt"

   content {
     content  = "${var.front_proxy_ca_cert_pem}"
   }
}

data "ignition_file" "apiserver_key" {
   filesystem = "root"
   mode       = "0600"
   path = "/opt/asi/tls/apiserver.key"

   content {
     content  = "${tls_private_key.apiserver.private_key_pem}"
   }
}

data "ignition_file" "apiserver_crt" {
   filesystem = "root"
   mode       = "0644"
   path = "/opt/asi/tls/apiserver.crt"

   content {
     content  = "${tls_locally_signed_cert.apiserver.cert_pem}"
   }
}

data "ignition_file" "front_proxy_key" {
   filesystem = "root"
   mode       = "0600"
   path = "/opt/asi/tls/front-proxy-client.key"

   content {
     content  = "${tls_private_key.front_proxy.private_key_pem}"
   }
}

data "ignition_file" "front_proxy_crt" {
   filesystem = "root"
   mode       = "0644"
   path = "/opt/asi/tls/front-proxy-client.crt"

   content {
     content  = "${tls_locally_signed_cert.front_proxy.cert_pem}"
   }
}

data "ignition_file" "kube_ca_key" {
   filesystem = "root"
   mode       = "0600"
   path = "/opt/asi/tls/ca.key"

   content {
     content  = "${var.kube_ca_key_pem}"
   }
}

data "ignition_file" "kube_ca_crt" {
   filesystem = "root"
   mode       = "0644"
   path = "/opt/asi/tls/ca.crt"

   content {
     content  = "${var.kube_ca_cert_pem}"
   }
}

data "ignition_file" "admin_key" {
   filesystem = "root"
   mode       = "0600"
   path = "/opt/asi/tls/admin.key"

   content {
     content  = "${tls_private_key.admin.private_key_pem}"
   }
}

data "ignition_file" "admin_crt" {
   filesystem = "root"
   mode       = "0644"
   path = "/opt/asi/tls/admin.crt"

   content {
     content  = "${tls_locally_signed_cert.admin.cert_pem}"
   }
}
