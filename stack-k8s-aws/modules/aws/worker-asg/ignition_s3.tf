data "aws_s3_bucket" "backend_bucket" {
  bucket   = "${var.s3_bucket}"
  provider = "aws.bucket"
}

provider "aws" {
  alias  = "bucket"
  region = "${var.s3_bucket_region}"
}

resource "aws_s3_bucket_object" "ignition_worker" {
  provider     = "aws.bucket"
  bucket       = "${data.aws_s3_bucket.backend_bucket.id}"
  key          = "${var.s3_key_prefix}/ignition_worker.json"
  content      = "${data.ignition_config.main.rendered}"
  acl          = "private"
  content_type = "text/json"

  server_side_encryption = "AES256"

  tags = "${merge(map(
      "Name", "ignition-worker-${var.cluster_name}-${var.base_domain}",
      "KubernetesCluster", "${var.cluster_name}-${var.base_domain}",
      "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "owned",
    ), var.extra_tags)}"
}

data "ignition_config" "s3" {
  replace {
    source       = "s3://${aws_s3_bucket_object.ignition_worker.bucket}/${aws_s3_bucket_object.ignition_worker.key}"
    verification = "sha512-${sha512(data.ignition_config.main.rendered)}"
  }
}
