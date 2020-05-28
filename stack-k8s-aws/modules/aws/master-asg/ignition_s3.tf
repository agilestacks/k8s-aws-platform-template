data "aws_s3_bucket" "backend_bucket" {
  bucket   = "${var.s3_bucket}"
  provider = "aws.bucket"
}

provider "aws" {
  alias  = "bucket"
  region = "${var.s3_bucket_region}"
}

resource "aws_s3_bucket_object" "ignition_master" {
  provider = "aws.bucket"
  bucket   = "${data.aws_s3_bucket.backend_bucket.id}"
  key      = "${var.s3_key_prefix}/ignition_master.json"
  content  = "${data.ignition_config.main.rendered}"
  acl      = "private"

  server_side_encryption = "AES256"

  tags = "${merge(map(
      "Name", "ignition-master-${var.cluster_name}-${var.base_domain}",
      "KubernetesCluster", "${var.cluster_name}-${var.base_domain}",
      "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "owned",
      "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
    ), var.extra_tags)}"
}

data "ignition_config" "s3" {
  replace {
    source       = "${format("s3://%s/%s", var.s3_bucket, aws_s3_bucket_object.ignition_master.key)}"
    verification = "sha512-${sha512(data.ignition_config.main.rendered)}"
  }
}
