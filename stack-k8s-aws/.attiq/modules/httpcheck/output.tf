output "ca_filename" {
  value = "${element(concat(local_file.ca_crt.*.filename, list("")), 0)}"
}

output "client_crt_filename" {
  value = "${element(concat(local_file.client_crt.*.filename, list("")), 0)}"
}

output "client_key_filename" {
  value = "${element(concat(local_file.client_key.*.filename, list("")), 0)}"
}
