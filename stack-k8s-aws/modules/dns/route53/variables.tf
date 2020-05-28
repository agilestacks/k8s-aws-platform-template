variable "cluster_name" {
  description = "The name of the cluster"
  type        = "string"
}

variable "base_domain" {
  description = "The base domain used in records"
  type        = "string"
}

variable "master_count" {
  description = "The number of masters"
  type        = "string"
}

variable "worker_count" {
  description = "The number of workers"
  type        = "string"
  default     = "0"
}

variable "etcd_count" {
  description = "The number of etcd nodes"
  type        = "string"
}

variable "internal_etcd" {
  description = "Use internal etcd"
  type        = "string"
}

variable "etcd_ip_addresses" {
  description = "List of string IPs for etcd nodes"
  type        = "list"
}

variable "master_ip_addresses" {
  description = "List of string IPs for masters"
  type        = "list"
  default     = []
}

variable "bastion_enabled" {
  description = "Create record for bastion host"
  type        = "string"
}

variable "bastion_public_ip" {
  description = "Elastic ip address for bastion host"
  type        = "string"
}

variable "bastion_zone_ttl" {
  description = "Bastion zone record set cache time to live (seconds)"
  default     = "300"
}

variable "worker_ip_addresses" {
  description = "List of string IPs for workers"
  type        = "list"
  default     = []
}

variable "external_endpoints" {
  type = "list"

  description = <<EOF
  (optional) List of external etcd v3 servers to connect with (hostnames/IPs only).
Needs to be set if using an external etcd cluster.
EOF
}

variable "worker_public_ips" {
  description = "(optional) List of string public IPs for workers"
  type        = "list"
  default     = []
}

// hack: worker_public_ips_enabled is a workaround for https://github.com/hashicorp/terraform/issues/10857
variable "worker_public_ips_enabled" {
  description = "Worker nodes have public IPs assigned. worker_public_ips must be provided if true."
  default     = true
}

variable "asi_extra_tags" {
  type        = "map"
  description = "(optional) Extra tags to be applied to created resources."
}

variable "custom_dns_name" {
  type        = "string"
  default     = ""
  description = "DNS prefix used to construct the API server endpoints."
}

// AWS specific internal zone variables

variable "nlb_alias_enabled" {
  description = <<EOF
(optional) Whether to create an aliased record set to NLB endpoints.
Refer to http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html
for additional information.
EOF

  default = false
}

variable "asi_external_vpc_id" {
  type = "string"

  description = <<EOF
(optional) ID of an existing VPC to launch nodes into.
If unset a new VPC is created.

Example: `vpc-123456`
EOF
}

variable "asi_private_endpoints" {
  description = <<EOF
(optional) If set to true, create private-facing ingress resources (NLB, A-records).
If set to false, no private-facing ingress resources will be provisioned and all DNS records will be created in the public Route53 zone.
EOF
}

variable "asi_public_endpoints" {
  description = <<EOF
(optional) If set to true, create public-facing ingress resources (NLB, A-records).
If set to false, no public-facing ingress resources will be created.
EOF
}

variable "asi_external_private_zone" {
  description = <<EOF
(optional) If set, the given Route53 zone ID will be used as the internal (private) zone.
This zone will be used to create etcd DNS records as well as internal API and internal Ingress records.
If set, no additional private zone will be created.

# Example: `"Z1ILINNUJGTAO1"`
EOF
}

variable "api_external_lb_dns_name" {
  description = "External API's NLB DNS name"
  type        = "string"
}

variable "api_external_lb_zone_id" {
  description = "External API's NLB Zone ID"
  type        = "string"
}


variable "k8s_api_fqdn" {
  type        = "string"
}
