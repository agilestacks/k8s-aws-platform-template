
variable "kubernetes_version" {
  default = "v1.16.7"
  description = "kubernetes version used for master & workers"
}

variable "asi_aws_config_version" {
  description = <<EOF
(internal) This declares the version of the AWS configuration variables.
It has no impact on generated assets but declares the version contract of the configuration.
EOF

  default = "1.0"
}

variable "asi_aws_profile" {
  description = <<EOF
(optional) This declares the AWS credentials profile to use.
EOF

  type    = "string"
  default = "default"
}

variable "keypair" {
  type        = "string"
  description = "Name of an SSH key located within the AWS region. Example: coreos-user."
}

variable "master_instance_type" {
  type        = "string"
  description = "Instance size for the master node(s). Example: `t3.small`."
  default     = "t3.medium"
}

variable "master_spot_price" {
  type        = "string"
  description = "Spot request price. Empty for on-demand"
  default     = ""
}

variable "worker_instance_type" {
  type        = "string"
  description = "Instance size for the worker node(s). Example: `t3.small`."
  default     = "t3.large"
}

variable "worker_spot_price" {
  type        = "string"
  description = "Spot request price. Empty for on-demand"
  default     = ""
}

variable "worker_group_mixed_enabled" {
  type        = "string"
  description = "Type of ASG to use: mixed or spot/on-demand."
  default     = "false"
}

variable "worker_on_demand_base_capacity" {
  type        = "string"
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances"
  default     = "0"
}

variable "worker_on_demand_percentage_above_base_capacity" {
  type        = "string"
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity"
  default     = "0"
}

variable "worker_mixed_instance_type_1" {
  type        = "string"
  description = "Instance size for the worker node(s). Example: `t3.small`."
  default     = "t3.small"
}

variable "worker_mixed_instance_type_2" {
  type        = "string"
  description = "Instance size for the worker node(s). Example: `t3.small`."
  default     = "t3.small"
}

variable "worker_mixed_instance_type_3" {
  type        = "string"
  description = "Instance size for the worker node(s). Example: `t3.small`."
  default     = "t3.small"
}

variable "worker_mixed_instance_type_4" {
  type        = "string"
  description = "Instance size for the worker node(s). Example: `t3.small`."
  default     = "t3.small"
}

variable "etcd_instance_type" {
  type = "string"

  description = <<EOF
  Instance size for the etcd node(s). Example: `t3.small`. Read the [etcd recommended hardware](https://coreos.com/etcd/docs/latest/op-guide/hardware.html) guide for best performance
  EOF

  default = "t3.small"
}

variable "asi_aws_ec2_ami_override" {
  type        = "string"
  description = "(optional) AMI override for all nodes. Example: `ami-foobar123`."
  default     = ""
}

variable "etcd_spot_price" {
  type        = "string"
  description = "Spot request price. Empty for on-demand"
  default     = ""
}

variable "asi_aws_etcd_extra_sg_ids" {
  description = <<EOF
(optional) List of additional security group IDs for etcd nodes.

Example: `["sg-51530134", "sg-b253d7cc"]`
EOF

  type    = "list"
  default = []
}

variable "asi_aws_master_extra_sg_ids" {
  description = <<EOF
(optional) List of additional security group IDs for master nodes.

Example: `["sg-51530134", "sg-b253d7cc"]`
EOF

  type    = "list"
  default = []
}

variable "asi_aws_worker_extra_sg_ids" {
  description = <<EOF
(optional) List of additional security group IDs for worker nodes.

Example: `["sg-51530134", "sg-b253d7cc"]`
EOF

  type    = "list"
  default = []
}

variable "asi_aws_master_custom_subnets" {
  type    = "map"
  default = {}

  description = <<EOF
(optional) This configures master availability zones and their corresponding subnet CIDRs directly.
Example:
`{ eu-west-1a = "10.0.0.0/21", eu-west-1b = "10.0.16.0/21" }`
EOF
}

variable "asi_aws_worker_custom_subnets" {
  type    = "map"
  default = {}

  description = <<EOF
(optional) This configures worker availability zones and their corresponding subnet CIDRs directly.
Example: `{ eu-west-1a = "10.0.64.0/21", eu-west-1b = "10.0.80.0/21" }`
EOF
}

variable "asi_aws_bastion_custom_subnets" {
  type    = "map"
  default = {}

  description = <<EOF
(optional) This configures bastion host availability zones and their corresponding subnet CIDRs directly.
Example: `{ eu-west-1a = "10.0.64.0/21", eu-west-1b = "10.0.80.0/21" }`
EOF
}

variable "asi_aws_vpc_cidr_block" {
  type    = "string"
  default = "10.0.0.0/16"

  description = <<EOF
Block of IP addresses used by the VPC.
This should not overlap with any other networks, such as a private datacenter connected via Direct Connect.
EOF
}

variable "asi_aws_external_vpc_id" {
  type = "string"

  description = <<EOF
(optional) ID of an existing VPC to launch nodes into.
If unset a new VPC is created.

Example: `vpc-123456`
EOF

  default = ""
}

variable "asi_aws_multi_az" {
  type    = "string"
  default = false

  description = <<EOF
Deploy into multiple AWS AZ in region.
EOF
}

variable "k8s_master_subnet" {
  type    = "string"
  default = "10.0.16.0/21"

  description = <<EOF
The cidr block for kubernetes master nodes to be used.
EOF
}

variable "k8s_worker_subnet" {
  type    = "string"
  default = "10.0.32.0/21"

  description = <<EOF
The cidr block for kubernetes worker nodes to be used.
EOF
}

variable "k8s_bastion_subnets" {
  type    = "string"
  default = "10.0.240.0/21"

  description = <<EOF
The cidr block for AWS bastion host.
EOF
}

variable "asi_aws_private_endpoints" {
  default = true

  description = <<EOF
(optional) If set to true, create private-facing ingress resources (NLB, A-records).
If set to false, no private-facing ingress resources will be provisioned and all DNS records will be created in the public Route53 zone.
EOF
}

variable "asi_aws_public_endpoints" {
  default = true

  description = <<EOF
(optional) If set to true, create public-facing ingress resources (NLB, A-records).
If set to false, no public-facing ingress resources will be created.
EOF
}

variable "asi_aws_external_private_zone" {
  default = ""

  description = <<EOF
(optional) If set, the given Route53 zone ID will be used as the internal (private) zone.
This zone will be used to create etcd DNS records as well as internal API and internal Ingress records.
If set, no additional private zone will be created.

Example: `"Z1ILINNUJGTAO1"`
EOF
}

variable "asi_aws_external_master_subnet_ids" {
  type = "list"

  description = <<EOF
(optional) List of subnet IDs within an existing VPC to deploy master nodes into.
Required to use an existing VPC and the list must match the AZ count.

Example: `["subnet-111111", "subnet-222222", "subnet-333333"]`
EOF

  default = []
}

variable "asi_aws_external_worker_subnet_ids" {
  type = "list"

  description = <<EOF
(optional) List of subnet IDs within an existing VPC to deploy worker nodes into.
Required to use an existing VPC and the list must match the AZ count.

Example: `["subnet-111111", "subnet-222222", "subnet-333333"]`
EOF

  default = []
}

variable "asi_aws_extra_tags" {
  type        = "map"
  description = "(optional) Extra AWS tags to be applied to created resources."
  default     = {}
}

variable "asi_autoscaling_group_extra_tags" {
  type    = "list"
  default = []

  description = <<EOF
(optional) Extra AWS tags to be applied to created autoscaling group resources.
This is a list of maps having the keys `key`, `value` and `propagate_at_launch`.

Example: `[ { key = "foo", value = "bar", propagate_at_launch = true } ]`
EOF
}

variable "asi_dns_name" {
  type        = "string"
  default     = ""
  description = "(optional) DNS prefix used to construct the API server endpoints."
}

variable "asi_aws_etcd_root_volume_type" {
  type        = "string"
  default     = "gp2"
  description = "The type of volume for the root block device of etcd nodes."
}

variable "asi_aws_etcd_root_volume_size" {
  type        = "string"
  default     = "10"
  description = "The size of the volume in gigabytes for the root block device of etcd nodes."
}

variable "asi_aws_etcd_root_volume_iops" {
  type    = "string"
  default = "100"

  description = <<EOF
The amount of provisioned IOPS for the root block device of etcd nodes.
Ignored if the volume type is not io1.
EOF
}

variable "asi_aws_master_root_volume_type" {
  type        = "string"
  default     = "gp2"
  description = "The type of volume for the root block device of master nodes."
}

variable "asi_aws_master_root_volume_size" {
  type        = "string"
  default     = "30"
  description = "The size of the volume in gigabytes for the root block device of master nodes."
}

variable "asi_aws_master_root_volume_iops" {
  type    = "string"
  default = "100"

  description = <<EOF
The amount of provisioned IOPS for the root block device of master nodes.
Ignored if the volume type is not io1.
EOF
}

variable "asi_aws_worker_root_volume_type" {
  type        = "string"
  default     = "gp2"
  description = "The type of volume for the root block device of worker nodes."
}

variable "asi_aws_worker_root_volume_size" {
  type        = "string"
  default     = "30"
  description = "The size of the volume in gigabytes for the root block device of worker nodes."
}

variable "asi_aws_worker_root_volume_iops" {
  type    = "string"
  default = "100"

  description = <<EOF
The amount of provisioned IOPS for the root block device of worker nodes.
Ignored if the volume type is not io1.
EOF
}

variable "asi_aws_master_iam_role_name" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) Name of IAM role to use for the instance profiles of master nodes.
The name is also the last part of a role's ARN.

Example:
 * Role ARN  = arn:aws:iam::123456789012:role/master-role
 * Role Name = master-role
EOF
}

variable "asi_aws_worker_iam_role_name" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) Name of IAM role to use for the instance profiles of worker nodes.
The name is also the last part of a role's ARN.

Example:
 * Role ARN  = arn:aws:iam::123456789012:role/worker-role
 * Role Name = worker-role
EOF
}

variable "asi_aws_etcd_iam_role_name" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) Name of IAM role to use for the instance profiles of etcd nodes.
The name is also the last part of a role's ARN.

Example:
 * Role ARN  = arn:aws:iam::123456789012:role/etcd-role
 * Role Name = etcd-role
EOF
}

variable "asi_aws_worker_load_balancers" {
  type    = "list"
  default = []

  description = <<EOF
(optional) List of ELBs to attach all worker instances to.
This is useful for exposing NodePort services via load-balancers managed separately from the cluster.
Functionality was removed from workers-asg module.

Example:
 * `["ingress-nginx"]`
EOF
}

variable "asi_aws_nat_gw_eipallocs" {
  type    = "list"
  default = []

  description = <<EOF
(optional) List of existing Elastic IP allocations to attach NAT Gateway(s) to.
This allows outbound access from a set of fixed addresses.

Example:
 * `["eipalloc-f419e0d5"]`
EOF
}

variable "r53_sync_runtime" {
  default     = "python3.8"
  description = "r53_sync lambda function runtime. For fine tuning of the Lambda function"
}

variable "cloud_provider" {
  type        = "string"
  default     = "aws"
  description = "(optional) The cloud provider to be used for the kubelet"
}

variable "asi_aws_default_iam_role_enabled" {
  default     = true
  description = "(optional) Whether to use a default and permissive IAM role for workers"
}

variable "k8s_api_fqdn" {
  type        = "string"
  description = "(optional) FQDN of Kubernetes api server. If not set, then load balancer will be created"
}
