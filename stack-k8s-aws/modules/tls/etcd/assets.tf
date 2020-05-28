# etcd assets

data "ignition_file" "etcd_ca_cert" {
   filesystem = "root"
   mode       = "0644"
   path = "/opt/asi/tls/etcd-client-ca.crt"

   content {
     content  = "${var.etcd_ca_cert_pem}"
   }
}
data "ignition_file" "etcd_client_crt" {
   filesystem = "root"
   mode       = "0644"
   path = "/opt/asi/tls/etcd-client.crt"

   content {
     content  = "${join("", tls_locally_signed_cert.etcd_client.*.cert_pem)}"
   }
}

data "ignition_file" "etcd_client_key" {
   filesystem = "root"
   mode       = "0600"
   path = "/opt/asi/tls/etcd-client.key"

   content {
     content  = "${join("", tls_private_key.etcd_client.*.private_key_pem)}"
   }
}

data "ignition_file" "etcd_server_crt" {
   filesystem = "root"
   mode       = "0644"
   path = "/opt/asi/tls/etcd/server.crt"

   content {
     content  = "${join("", tls_locally_signed_cert.etcd_server.*.cert_pem)}"
   }
}

data "ignition_file" "etcd_server_key" {
   filesystem = "root"
   mode       = "0600"
   path = "/opt/asi/tls/etcd/server.key"

   content {
     content  = "${join("", tls_private_key.etcd_server.*.private_key_pem)}"
   }
}

data "ignition_file" "etcd_peer_crt" {
   filesystem = "root"
   mode       = "0644"
   path = "/opt/asi/tls/etcd/peer.crt"

   content {
     content  = "${join("", tls_locally_signed_cert.etcd_peer.*.cert_pem)}"
   }
}

data "ignition_file" "etcd_peer_key" {
   filesystem = "root"
   mode       = "0600"
   path = "/opt/asi/tls/etcd/peer.key"

   content {
     content  = "${join("", tls_private_key.etcd_peer.*.private_key_pem)}"
   }
}
