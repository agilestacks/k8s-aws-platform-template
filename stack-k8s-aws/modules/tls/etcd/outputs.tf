output "etcd_client_crt_pem" {
  value = "${element(concat(tls_locally_signed_cert.etcd_client.*.cert_pem, list("")), 0)}"
}

output "etcd_client_key_pem" {
  value = "${element(concat(tls_private_key.etcd_client.*.private_key_pem, list("")), 0)}"
}

output "etcd_peer_crt_pem" {
  value = "${element(concat(tls_locally_signed_cert.etcd_peer.*.cert_pem, list("")), 0)}"
}

output "etcd_peer_key_pem" {
  value = "${element(concat(tls_private_key.etcd_peer.*.private_key_pem, list("")), 0)}"
}

output "etcd_server_crt_pem" {
  value = "${element(concat(tls_locally_signed_cert.etcd_server.*.cert_pem, list("")), 0)}"
}

output "etcd_server_key_pem" {
  value = "${element(concat(tls_private_key.etcd_server.*.private_key_pem, list("")), 0)}"
}

output "etcd_client_id_list" {
   value = ["${compact(flatten(list(
     "${data.ignition_file.etcd_ca_cert.*.id}",
     "${data.ignition_file.etcd_client_crt.*.id}",
     "${data.ignition_file.etcd_client_key.*.id}",
  )))}"]
}
