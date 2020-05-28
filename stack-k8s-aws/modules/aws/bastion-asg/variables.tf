variable "base_domain" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "bastion_enabled" {
  type = "string"
}

variable "bastion_sg" {
  type = "string"
}

variable "bastion_instance_type" {
  description = "Bastion instance type"
  default     = ""
}

variable "bastion_key_name" {
  description = "Bastion SSH key pair name"
  default     = ""
}

variable "bastion_eip_id" {
  type = "string"
}

variable "bastion_user_data_script" {
  description = "Bastion user data bootstrap script"
  default     = ""
}

variable "bastion_ebs_optimized" {
  description = "Bastion EBS optimized (true/false)"
  default     = "false"
}

variable "bastion_enable_monitoring" {
  description = "Bastion enable detailed monitoring (true/false)"
  default     = "false"
}

variable "bastion_volume_type" {
  description = "Bastion root volume type"
  default     = ""
}

variable "bastion_volume_size" {
  description = "Bastion root volume size (GB)"
  default     = ""
}

variable "bastion_max_size" {
  description = "Bastion ASG maximum size"
  default     = "1"
}

variable "bastion_min_size" {
  description = "Bastion ASG minimum size"
  default     = "1"
}

variable "bastion_desired_capacity" {
  description = "Bastion ASG desired size"
  default     = "1"
}

variable "bastion_asg_subnets" {
  description = "List of subnet IDs to launch Bastion in"
  type        = "list"
  default     = []
}

variable "bastion_keys_bucket" {
  type = "string"
}

variable "bastion_keys_bucket_region" {
  type    = "string"
  default = "us-east-1"
}

variable "bastion_keys_bucket_prefix" {
  type = "string"
  default = ""
}


variable "bastion_logs_bucket" {
  type = "string"
}

variable "bastion_logs_bucket_region" {
  type    = "string"
  default = "us-east-1"
}

variable "bastion_logs_bucket_prefix" {
  type = "string"
  default = ""
}
