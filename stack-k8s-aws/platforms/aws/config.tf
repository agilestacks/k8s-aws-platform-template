terraform {
  required_version = ">= 0.11.10"
  backend "s3" {}
}

provider "archive" {
  version = "1.2.2"
}

provider "external" {
  version = "1.1.2"
}

provider "ignition" {
  version = "1.1.0"
}

provider "local" {
  version = "1.4.0"
}

provider "null" {
  version = "2.1.2"
}

provider "template" {
  version = "1.0.0"
}

provider "random" {
  version = "2.1.2"
}

provider "tls" {
  version = "2.1.0"
}

locals {
  // The total amount of public CA certificates present.
  // That is all custom CAs + kube CA + etcd CA
  // This is a local constant, which needs to be dependency inject because TF cannot handle length() on computed values,
  // see https://github.com/hashicorp/terraform/issues/10857#issuecomment-268289775.
  asi_ca_count = "${length(var.asi_custom_ca_pem_list) + 3}"
}

variable "asi_config_version" {
  description = <<EOF
(internal) This declares the version of the global configuration variables.
It has no impact on generated assets but declares the version contract of the configuration.
EOF

  default = "1.0"
}

variable "asi_image_re" {
  description = <<EOF
(internal) Regular expression used to extract repo and tag components
EOF

  type = "string"

  #  default = "/^([^/]+/[^/]+/[^/]+):(.*)$/"
  default = "/^([^/]+/[^/]+):(.*)$/"
}

variable "asi_image_re_torcx" {
  description = <<EOF
(internal) Regular expression used to extract repo and tag components
EOF

  type = "string"

  default = "/^([^/]+/[^/]+/[^/]+):(.*)$/"
}

variable "asi_container_images" {
  description = "(internal) Container images to use"
  type        = "map"

  default = {
    awscli     = "quay.io/coreos/awscli:025a357f05242fdad6a81e8a6b520098aa65a600"
    bootkube   = "quay.io/coreos/bootkube:v0.14.0"
    calico     = "quay.io/calico/node:v3.4.4"
    calico_cni = "quay.io/calico/cni:v3.4.4"

    # As long as we use etcd-service from CoreOS with etcd-wrapper changing image registry url will fail
    # cause it is hardcoded in etcd-wrapper "quay.io"
    etcd = "quay.io/coreos/etcd:v3.3.15"

    flannel          = "quay.io/coreos/flannel:v0.11.0"
    flannel_cni      = "quay.io/coreos/flannel-cni:v0.3.0"
    hyperkube        = "k8s.gcr.io/hyperkube:v1.14.8"
    coredns          = "k8s.gcr.io/coredns:1.6.2"
    pod_checkpointer = "quay.io/coreos/pod-checkpointer:83e25e5968391b9eb342042c435d1b3eeddb2be1"
  }
}

variable "asi_versions" {
  description = "(internal) Versions of the components to use"
  type        = "map"

  default = {
    etcd       = "3.3.15"
    kubernetes = "1.14.8"
  }
}

variable "asi_service_cidr" {
  type    = "string"
  default = "10.3.0.0/16"

  description = <<EOF
(optional) This declares the IP range to assign Kubernetes service cluster IPs in CIDR notation.
The maximum size of this IP range is /12
EOF
}

variable "asi_cluster_cidr" {
  type    = "string"
  default = "10.2.0.0/16"

  description = "(optional) This declares the IP range to assign Kubernetes pod IPs in CIDR notation."
}

variable "master_count" {
  type    = "string"
  default = "1"

  description = <<EOF
The number of master nodes to be created.
This applies only to cloud platforms.
EOF
}

variable "worker_count" {
  type    = "string"
  default = "3"

  description = <<EOF
The number of worker nodes to be created.
This applies only to cloud platforms.
EOF
}

variable "etcd_count" {
  type    = "string"
  default = "0"

  description = <<EOF
The number of etcd nodes to be created.
If set to zero, the count of etcd nodes will be determined automatically.

Note: This is not supported on bare metal.
EOF
}

variable "internal_etcd" {
  default = false

  description = <<EOF
Create etcd cluster running on master nodes.
EOF
}

variable "nat_gw_workers" {
  default = false

  description = <<EOF
Create NAT gateway for worker nodes with private only ips.
EOF
}

variable "asi_etcd_servers" {
  description = <<EOF
(optional) List of external etcd v3 servers to connect with (hostnames/IPs only).
Needs to be set if using an external etcd cluster.
Note: If this variable is defined, the installer will not create self-signed certs.
To provide a CA certificate to trust the etcd servers, set "asi_etcd_ca_cert_path".

Example: `["etcd1", "etcd2", "etcd3"]`
EOF

  type    = "list"
  default = []
}

variable "asi_etcd_ca_cert_path" {
  type    = "string"
  default = "/dev/null"

  description = <<EOF
(optional) The path of the file containing the CA certificate for TLS communication with etcd.

Note: This works only when used in conjunction with an external etcd cluster.
If set, the variable `asi_etcd_servers` must also be set.
EOF
}

variable "asi_etcd_client_cert_path" {
  type    = "string"
  default = "/dev/null"

  description = <<EOF
(optional) The path of the file containing the client certificate for TLS communication with etcd.

Note: This works only when used in conjunction with an external etcd cluster.
If set, the variables `asi_etcd_servers`, `asi_etcd_ca_cert_path`, and `asi_etcd_client_key_path` must also be set.
EOF
}

variable "asi_etcd_client_key_path" {
  type    = "string"
  default = "/dev/null"

  description = <<EOF
(optional) The path of the file containing the client key for TLS communication with etcd.

Note: This works only when used in conjunction with an external etcd cluster.
If set, the variables `asi_etcd_servers`, `asi_etcd_ca_cert_path`, and `asi_etcd_client_cert_path` must also be set.
EOF
}

variable "base_domain" {
  type = "string"

  description = <<EOF
The base DNS domain of the cluster. It must NOT contain a trailing period. Some
DNS providers will automatically add this if necessary.

Example: `openstack.dev.coreos.systems`.

Note: This field MUST be set manually prior to creating the cluster.
This applies only to cloud platforms.

[Azure-specific NOTE]
To use Azure-provided DNS, `base_domain` should be set to `""`
If using DNS records, ensure that `base_domain` is set to a properly configured external DNS zone.
Instructions for configuring delegated domains for Azure DNS can be found here: https://docs.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns
EOF
}

variable "name" {
  type = "string"

  description = <<EOF
The name of the cluster.
If used in a cloud-environment, this will be prepended to `base_domain`.

Note: This field MUST be set manually prior to creating the cluster.
Warning: Special characters in the name like '.' may cause errors on OpenStack platforms due to resource name constraints.
EOF
}

variable "cluster_admin_user" {
  type    = "string"
  default = "admin"

  description = <<EOF
Admin user name in fqdn format, for client certs and RBAC.
EOF
}

variable "aws_az" {
  type = "string"

  description = <<EOF
The name of the cluster AZ, currently used to setup custom master/worker subnets and EFS mount point.
EOF
}

variable "backend_bucket" {
  type = "string"

  description = <<EOF
The name of the cluster release bucket.
EOF
}

variable "backend_region" {
  type = "string"

  description = <<EOF
The name of the cluster release bucket AWS region.
EOF
}

variable "backend_bucket_key_prefix" {
  default = ""

  description = <<EOF
Bucket content will be prefixed by
EOF
}

variable "asi_ami_linux_channel" {
  type    = "string"
  default = "stable"

  description = <<EOF
(optional) The Container Linux update channel.

Examples: `stable`, `beta`, `alpha`
EOF
}

variable "asi_ami_linux_version" {
  type    = "string"
  default = "*"

  description = <<EOF
The Container Linux version to use. Set to `latest` to select the latest available version for the selected update channel.

Examples: `latest`, `1465.6.0`
EOF
}

variable "asi_ca_cert" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) The content of the PEM-encoded CA certificate.
If left blank, a CA certificate will be automatically generated.
EOF
}

variable "asi_ca_key" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) The content of the PEM-encoded CA key.
This field is mandatory if `asi_ca_cert` is set.
EOF
}

variable "asi_ca_key_alg" {
  type    = "string"
  default = "RSA"

  description = <<EOF
(optional) The algorithm used to generate asi_ca_key.
The default value is currently recommended.
This field is mandatory if `asi_ca_cert` is set.
EOF
}

variable "asi_tls_validity_period" {
  type    = "string"
  default = "26280"

  description = <<EOF
Validity period of the self-signed certificates (in hours).
Default is 3 years.
This setting is ignored if user provided certificates are used.
EOF
}

variable "networking" {
  default = "canal"

  description = <<EOF
(optional) Configures the network to be used. One of the following values can be used:

- "flannel": enables overlay networking only. This is implemented by flannel using VXLAN.

- "canal": enables overlay networking including network policy. Overlay is implemented by flannel using VXLAN. Network policy is implemented by Calico.

- "calico": enables IP-IP based networking. Routing and network policy is implemented by Calico.

- "none": disables the installation of any Pod level networking layer. By setting this value, users are expected to deploy their own solution to enable network connectivity for Pods and Services.
EOF
}

variable "bastion_enabled" {
  default = false

  description = <<EOF
Create ssh bastion host, hide master node in private subnet.
EOF
}

variable "asi_bootstrap_upgrade_cl" {
  type        = "string"
  default     = "false"
  description = "(internal) Whether to trigger a ContainerLinux upgrade on node bootstrap."
}

variable "asi_kubelet_debug_config" {
  type    = "string"
  default = ""

  description = "(internal) debug flags for the kubelet (used in CI only)"
}

variable "asi_custom_ca_pem_list" {
  type    = "list"
  default = []

  description = <<EOF
(optional) A list of PEM encoded CA files that will be installed in /etc/ssl/certs on etcd, master, and worker nodes.
EOF
}

variable "asi_iscsi_enabled" {
  type        = "string"
  default     = "false"
  description = "(optional) Start iscsid.service to enable iscsi volume attachment."
}
