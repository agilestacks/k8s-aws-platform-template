variable "name" {
  type        = "string"
  description = "autoscaling lifecycle hook name"
}

variable "ag_name" {
  type        = "string"
  description = "autoscaling group name"
  default     = "name of the autoscaling group"
}

variable "target_arn" {
  type        = "string"
  description = "arn of the hook notification"
}

variable "metadata_json" {
  type        = "string"
  description = "JSON encoded metadata that will be given to the ag lifecycle hook"
  default     = ""
}

variable "hook_enabled" {
  type = "string"
}
