variable "container_images" {
  description = "Container images to use"
  type        = "map"
}

variable "cluster_cidr" {
  description = "A CIDR notation IP range from which to assign pod IPs"
  type        = "string"
}

variable "enabled" {
  description = "If set true, calico networking will be deployed"
}

# https://docs.projectcalico.org/v3.3/usage/configuration/mtu
variable "mtu" {
  type    = "string"
  default = 8951
}
