provider "aws" {
  alias  = "bucket"
  region = "${var.backend_region}"
}

resource "aws_s3_bucket_object" "ca_pem" {
  provider     = "aws.bucket"
  bucket       = "${var.backend_bucket}"
  key          = "${var.name}.${var.base_domain}/stack-k8s-aws/tls/ca.pem"
  content      = "${module.ca_certs.kube_ca_cert_pem}"
  acl          = "private"
  content_type = "text/plain"
  server_side_encryption = "AES256"

  lifecycle {
    ignore_changes = ["content"]
  }
}

resource "aws_s3_bucket_object" "ca_key" {
  provider     = "aws.bucket"
  bucket       = "${var.backend_bucket}"
  key          = "${var.name}.${var.base_domain}/stack-k8s-aws/tls/ca-key.pem"
  content      = "${module.ca_certs.kube_ca_key_pem}"
  acl          = "private"
  content_type = "text/plain"
  server_side_encryption = "AES256"

  lifecycle {
    ignore_changes = ["content"]
  }
}

# TODO(elco) to rename key value, need to sync with HUB
resource "aws_s3_bucket_object" "admin_pem" {
  provider     = "aws.bucket"
  bucket       = "${var.backend_bucket}"
  key          = "${var.name}.${var.base_domain}/stack-k8s-aws/tls/client.pem"
  content      = "${module.kube_certs.admin_cert_pem}"
  acl          = "private"
  content_type = "text/plain"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "admin_key" {
  provider     = "aws.bucket"
  bucket       = "${var.backend_bucket}"
  key          = "${var.name}.${var.base_domain}/stack-k8s-aws/tls/client-key.pem"
  content      = "${module.kube_certs.admin_key_pem}"
  acl          = "private"
  content_type = "text/plain"
  server_side_encryption = "AES256"
}

