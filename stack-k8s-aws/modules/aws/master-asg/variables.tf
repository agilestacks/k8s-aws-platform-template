variable "autoscaling_group_extra_tags" {
  description = "Extra AWS tags to be applied to created autoscaling group resources."
  type        = "list"
  default     = []
}

variable "base_domain" {
  type        = "string"
  description = "Domain on which the ELB records will be created"
}

variable "linux_channel" {
  type = "string"
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

variable "cluster_name" {
  type = "string"
}

variable "container_images" {
  description = "Container images to use"
  type        = "map"
}

variable "bastion_enabled" {
  type = "string"
}

variable "ec2_type" {
  type = "string"
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

variable "ec2_ami" {
  type    = "string"
  default = ""
}

variable "instance_count" {
  type = "string"
}

variable "master_iam_role" {
  type        = "string"
  default     = ""
  description = "IAM role to use for the instance profiles of master nodes."
}

variable "master_sg_ids" {
  type        = "list"
  description = "The security group IDs to be applied to the master nodes."
}

variable "private_endpoints" {
  description = "If set to true, private-facing ingress resources are created."
  default     = true
}

variable "public_endpoints" {
  description = "If set to true, public-facing ingress resources are created."
  default     = true
}

variable "aws_lb_target_groups_arns" {
  description = "List of aws_lb target group arns for the APIs"
  type        = "list"
  default     = []
}

variable "root_volume_iops" {
  type        = "string"
  default     = "100"
  description = "The amount of provisioned IOPS for the root block device."
}

variable "root_volume_size" {
  type        = "string"
  description = "The size of the volume in gigabytes for the root block device."
}

variable "root_volume_type" {
  type        = "string"
  description = "The type of volume for the root block device."
}

variable "ssh_key" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "ign_init_assets_service_id" {
  type = "string"
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

variable "aws_lb_api_target_group_arn" {
  type = "string"
}

variable "lifecycle_hook_target_arn" {
  type        = "string"
  default     = ""
  description = <<EOF
Optional. If defined, then immediate lifecycle hook
will be created emmiting to the ARN of the resource
that should receive autoscaling group events. This
variable can be empty or ARN
EOF
}

variable "lifecycle_hook_ext_r53_name" {
  type        = "string"
  default     = ""
  description = <<EOF
Optional. Works in conjunction with "lifecycle_hook_target_arn"
Refers to the existing route53_record_set to managed
EOF
}

variable "lifecycle_hook_ext_r53_type" {
  type        = "string"
  default     = "A"
  description = <<EOF
Optional. Works in conjunction with "lifecycle_hook_r53_name"
Default is A record. But can be changed to other record types
EOF
}

variable "lifecycle_hook_int_r53_name" {
  type        = "string"
  default     = ""
  description = <<EOF
Optional. Works in conjunction with "lifecycle_hook_target_arn"
Refers to the existing route53_record_set to managed
EOF
}

variable "lifecycle_hook_int_r53_type" {
  type        = "string"
  default     = "A"
  description = <<EOF
Optional. Works in conjunction with "lifecycle_hook_r53_name"
Default is A record. But can be changed to other record types
EOF
}

variable "lifecycle_hook_int_zone_id" {
  type        = "string"
}

variable "lifecycle_hook_ext_zone_id" {
  type        = "string"
}

variable "kubeadm_master_init_service_id" {
  type        = "string"
  description = "The ID of the kubeadm bootstrap systemd service unit"
}

variable "ign_kubeadm_config_id" {
  type        = "string"
  description = "The ID of the kubeadm config"
}

variable "ign_kubeadm_assets_id" {
  type        = "string"
  description = "The ID of the kubeadm bootstrap "
}

variable "ign_kubeadm_manifest_service_id" {
  type        = "string"
  description = "The ID of the kubeadm manifest bootstarp service "
}

variable "ign_kubeadm_manifest_script_id" {
  type        = "string"
  description = "The ID of the kubeadm script file "
}

variable "ign_kubeadm_manifest_file_ids" {
  type        = "list"
  description = "The ID of the kubeadm manifest files "
}

variable "k8s_api_fqdn" {
  type        = "string"
}
