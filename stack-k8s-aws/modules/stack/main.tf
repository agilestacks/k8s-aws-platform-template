variable "name" {
  type = "string"
  description = "name of the stack"
}

resource "null_resource" "main" {
  provisioner "local-exec" {
    command = "uptime"
  }
}

output "name" {
  value = "${var.name}"
}

output "name1" {
  value = "${var.name}"
}

output "name2" {
  value = "${replace("${var.name}", ".", "-")}"
}

output "shared_uuid" {
  value = "${uuid()}"
}