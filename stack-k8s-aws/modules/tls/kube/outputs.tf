output "admin_cert_pem" {
  value = "${tls_locally_signed_cert.admin.cert_pem}"
}

output "admin_key_pem" {
  value = "${tls_private_key.admin.private_key_pem}"
}

output "apiserver_cert_pem" {
  value = "${tls_locally_signed_cert.apiserver.cert_pem}"
}

output "apiserver_key_pem" {
  value = "${tls_private_key.apiserver.private_key_pem}"
}

output "front_proxy_cert_pem" {
  value = "${tls_locally_signed_cert.front_proxy.cert_pem}"
}

output "front_proxy_key_pem" {
  value = "${tls_private_key.front_proxy.private_key_pem}"
}

output "ignition_file_id_list" {
   value = [
     "${data.ignition_file.front_proxy_ca_crt.id}",
     "${data.ignition_file.apiserver_crt.id}",
     "${data.ignition_file.apiserver_key.id}",
     "${data.ignition_file.front_proxy_crt.id}",
     "${data.ignition_file.front_proxy_key.id}",
     "${data.ignition_file.kube_ca_key.id}",
     "${data.ignition_file.kube_ca_crt.id}",
     "${data.ignition_file.admin_key.id}",
     "${data.ignition_file.admin_crt.id}",
   ]
}
