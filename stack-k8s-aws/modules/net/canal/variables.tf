variable "container_images" {
  description = "Container images to use"
  type        = "map"
}

variable "cluster_cidr" {
  description = "A CIDR notation IP range from which to assign pod IPs"
  type        = "string"
}

variable "enabled" {
  description = "If set true, calico network policy will be deployed"
}

# https://docs.projectcalico.org/v3.3/usage/configuration/mtu
# Default jumbo mtu for AWS(9001) - 50 vxlan overlay overhead
variable "mtu" {
  type    = "string"
  default = 8951
}
