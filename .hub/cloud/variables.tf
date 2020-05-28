variable "domain_name" {
  type = string
  description = "Base domain name for the platform stack"
}

variable "region" {
  type = string
  description = "AWS region"
}

variable "pub_key_path" {
  type = string
  description = "Path to SSH public key"
}
