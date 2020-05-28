variable "ssh_key" {
  type = "string"
}

variable "vpc_id" {
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

variable "base_domain" {
  type        = "string"
  description = "Domain on which the NLB records will be created"
}

variable "cluster_name" {
  type = "string"
}

variable "spot_price" {
  type        = "string"
  description = "Spot request price"
  default     = ""
}

variable "subnet_ids" {
  type = "list"
}

variable "sg_ids" {
  type        = "list"
  description = "The security group IDs to be applied."
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = "map"
  default     = {}
}

variable "autoscaling_group_extra_tags" {
  description = "Extra AWS tags to be applied to created autoscaling group resources."
  type        = "list"
  default     = []
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

variable "worker_iam_role" {
  type        = "string"
  default     = ""
  description = "IAM role to use for the instance profiles of worker nodes."
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

variable "worker_group_mixed_enabled" {
  type        = "string"
  default     = "false"
  description = "Type of ASG to use: mixed or spot/on-demand"
}

variable "worker_on_demand_allocation_strategy" {
  type        = "string"
  default     = "prioritized"
  description = "Strategy to use when launching on-demand instances. Valid values: prioritized."
}

variable "worker_on_demand_base_capacity" {
  type        = "string"
  default     = "0"
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances"
}

variable "worker_on_demand_percentage_above_base_capacity" {
  type        = "string"
  default     = "0"
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity"
}

variable "worker_spot_allocation_strategy" {
  type        = "string"
  default     = "lowest-price"
  description = "The only valid value is lowest-price, which is also the default value. The Auto Scaling group selects the cheapest Spot pools and evenly allocates your Spot capacity across the number of Spot pools that you specify."
}

variable "worker_spot_instance_pools" {
  type        = "string"
  default     = "10"
  description = "Number of Spot pools per availability zone to allocate capacity. EC2 Auto Scaling selects the cheapest Spot pools and evenly allocates Spot capacity across the number of Spot pools that you specify."
}

variable "worker_spot_max_price" {
  type        = "string"
  default     = ""
  description = "Maximum price per unit hour that the user is willing to pay for the Spot instances. Default is the on-demand price"
}

variable "worker_override_instance_type_1" {
  type        = "string"
  default     = "t3.large"
  description = "Override instance type 1 for mixed instances policy"
}

variable "worker_override_instance_type_2" {
  type        = "string"
  default     = "r5.large"
  description = "Override instance type 2 for mixed instances policy"
}

variable "worker_override_instance_type_3" {
  type        = "string"
  default     = "m5.large"
  description = "Override instance type 3 for mixed instances policy"
}

variable "worker_override_instance_type_4" {
  type        = "string"
  default     = "c5.large"
  description = "Override instance type 4 for mixed instances policy"
}

variable "ephemeral_storage_iops" {
  default = 100
  description = "Number of input/ouptut operationos for Kubelet ephemeral storage volume"
}

variable "ephemeral_storage_type" {
  default = "gp2"
  description = "EBS type for Kubelet ephemeral storage volume"
}

variable "asi_aws_default_iam_role_enabled" {
  default     = true
  description = "(optional) Whether to use a default and permissive IAM role for workers"
}

variable "kubeadm_master_init_service_id" {
  type        = "string"
  description = "The ID of the kubeadm bootstrap systemd service unit"
}

variable "ign_kubeadm_assets_id" {
  type        = "string"
  description = "The ID of the kubeadm bootstrap "
}

variable "ign_kubeadm_join_config_id" {
  type        = "string"
  description = "The ID of the kubeadm bootstrap "
}
