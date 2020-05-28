variable "base_domain" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "linux_channel" {
  type    = "string"
  default = "stable"
}

variable "linux_version" {
  type    = "string"
  default = "*"
}

variable "linux_distro" {
  type    = "string"
  default = "flatcar"
}

variable "instance_count" {
  default = "3"
}

variable "nat_gw_workers" {
  type = "string"
}

variable "ssh_key" {
  type = "string"
}

variable "subnets" {
  type = "list"
}

variable "external_endpoints" {
  type = "list"
}

variable "internal_etcd" {
  type = "string"
}

variable "container_image" {
  type = "string"
}

variable "ec2_type" {
  type = "string"
}

variable "ec2_ami" {
  type    = "string"
  default = ""
}

variable "spot_price" {
  type        = "string"
  description = "Spot request price"
  default     = ""
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = "map"
  default     = {}
}

variable "root_volume_type" {
  type        = "string"
  description = "The type of volume for the root block device."
}

variable "root_volume_size" {
  type        = "string"
  description = "The size of the volume in gigabytes for the root block device."
}

variable "root_volume_iops" {
  type        = "string"
  default     = "100"
  description = "The amount of provisioned IOPS for the root block device."
}

variable "sg_ids" {
  type        = "list"
  description = "The security group IDs to be applied."
}

variable "ign_etcd_dropin_id_list" {
  type = "list"
}

variable "s3_bucket" {
  type = "string"
}

variable "s3_bucket_region" {
  type    = "string"
  default = "us-east-1"
}

variable "s3_key_prefix" {
  type        = "string"
  default     = ""
  description = "s3 key prefix to store all stack artifacts"
}

variable "ign_etcd_crt_id_list" {
  type = "list"
}

variable "etcd_iam_role" {
  type        = "string"
  default     = ""
  description = "IAM role to use for the instance profiles of etcd nodes."
}

variable "ign_etcd_tags_service_id" {
  type = "string"
}

variable "container_images" {
  description = "Container images to use"
  type        = "map"
}
