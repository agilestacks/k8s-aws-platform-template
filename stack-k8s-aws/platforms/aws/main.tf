provider "aws" {
  version = "2.49.0"
}

data "aws_availability_zones" "azs" {}

module "stack" {
  source = "../../modules/stack"
  name   = "${var.name}.${var.base_domain}"
}

module "secondary_az" {
  source            = "../../modules/another_az"
  availability_zone = "${var.aws_az}"
}

module "private_subnet" {
  source            = "../../modules/subnet"
  multi_az_enabled  = "${var.asi_aws_multi_az ? true : false}"
  name              = "rds-${var.name}-${var.base_domain}"
  cluster           = "${var.name}-${var.base_domain}"
  vpc_id            = "${module.vpc.vpc_id}"
  availability_zone = "${module.secondary_az.zone1}"
  cidr_block        = "${cidrsubnet("${var.asi_aws_vpc_cidr_block}", 5, 31)}"
}

data "template_file" "etcd_hostname_list" {
  count    = "${var.etcd_count > 0 ? var.etcd_count : length(data.aws_availability_zones.azs.names) == 5 ? 5 : 3}"
  template = "etcd-${count.index}.i.${var.name}.${var.base_domain}"
}

locals {
  az_subnet_map = {
    empty         = "${map()}"
    master        = "${map(var.aws_az, var.k8s_master_subnet)}"
    worker        = "${map(var.aws_az, var.k8s_worker_subnet)}"
    custom_master = "${var.asi_aws_master_custom_subnets}"
    custom_worker = "${var.asi_aws_worker_custom_subnets}"
  }

  master_subnet = "${var.asi_aws_multi_az ? "empty" : "master"}"
  worker_subnet = "${var.asi_aws_multi_az ? "empty" : "worker"}"

  aws_master_custom_subnets = "${length(keys(var.asi_aws_master_custom_subnets)) > 0 ?
    "custom_master" :
    local.master_subnet }"

  aws_worker_custom_subnets = "${length(keys(var.asi_aws_worker_custom_subnets)) > 0 ?
    "custom_worker" :
    local.worker_subnet }"
}

module "vpc" {
  source = "../../modules/aws/vpc"

  base_domain              = "${var.base_domain}"
  bastion_enabled          = "${var.bastion_enabled ? true : false}"
  cidr_block               = "${var.asi_aws_vpc_cidr_block}"
  cluster_name             = "${var.name}"
  custom_dns_name          = "${var.asi_dns_name}"
  enable_etcd_sg           = "${var.internal_etcd && var.master_count == 1 ? 0 : 1}"
  external_master_subnets  = "${compact(var.asi_aws_external_master_subnet_ids)}"
  external_vpc_id          = "${var.asi_aws_external_vpc_id}"
  external_worker_subnets  = "${compact(var.asi_aws_external_worker_subnet_ids)}"
  extra_tags               = "${var.asi_aws_extra_tags}"
  private_master_endpoints = "${var.asi_aws_private_endpoints}"
  public_master_endpoints  = "${var.asi_aws_public_endpoints}"
  nat_gw_workers           = "${var.nat_gw_workers ? true : false}"
  nat_gw_eipallocs         = "${var.asi_aws_nat_gw_eipallocs}"

  # VPC layout settings.
  #
  # The following parameters control the layout of the VPC accross availability zones.
  # Two modes are available:
  # A. Explicitly configure a list of AZs + associated subnet CIDRs
  # B. Let the module calculate subnets accross a set number of AZs
  #
  # To enable mode A, configure a set of AZs + CIDRs for masters and workers using the
  # "asi_aws_master_custom_subnets" and "asi_aws_worker_custom_subnets" variables.
  #
  # To enable mode B, make sure that "asi_aws_master_custom_subnets" and "asi_aws_worker_custom_subnets"
  # ARE NOT SET.

  # These counts could be deducted by length(keys(var.asi_aws_master_custom_subnets))
  # but there is a restriction on passing computed values as counts. This approach works around that.
  master_az_count = "${length(keys(local.az_subnet_map[local.aws_master_custom_subnets])) > 0 ? "${length(keys(local.az_subnet_map[local.aws_master_custom_subnets]))}" : "${length(data.aws_availability_zones.azs.names)}"}"
  worker_az_count = "${length(keys(local.az_subnet_map[local.aws_worker_custom_subnets])) > 0 ? "${length(keys(local.az_subnet_map[local.aws_worker_custom_subnets]))}" : "${length(data.aws_availability_zones.azs.names)}"}"
  # The appending of the "padding" element is required as workaround since the function
  # element() won't work on empty lists. See https://github.com/hashicorp/terraform/issues/11210
  master_subnets = "${concat(values(local.az_subnet_map[local.aws_master_custom_subnets]),list("padding"))}"
  worker_subnets  = "${concat(values(local.az_subnet_map[local.aws_worker_custom_subnets]),list("padding"))}"
  bastion_subnets = "${concat(values(var.asi_aws_bastion_custom_subnets),list("padding"))}"
  # The split() / join() trick works around the limitation of ternary operator expressions
  # only being able to return strings.
  master_azs = "${ split("|", "${length(keys(local.az_subnet_map[local.aws_master_custom_subnets]))}" > 0 ?
    join("|", keys(local.az_subnet_map[local.aws_master_custom_subnets])) :
    join("|", data.aws_availability_zones.azs.names)
  )}"
  worker_azs = "${ split("|", "${length(keys(local.az_subnet_map[local.aws_worker_custom_subnets]))}" > 0 ?
    join("|", keys(local.az_subnet_map[local.aws_worker_custom_subnets])) :
    join("|", data.aws_availability_zones.azs.names)
  )}"
  k8s_api_fqdn = "${var.k8s_api_fqdn}"
}

module "etcd" {
  source = "../../modules/aws/etcd"

  base_domain              = "${var.base_domain}"
  cluster_name             = "${var.name}"
  container_image          = "${var.asi_container_images["etcd"]}"
  linux_channel            = "${var.asi_ami_linux_channel}"
  linux_version            = "${var.asi_ami_linux_version}"
  linux_distro             = "flatcar"
  container_images         = "${var.asi_container_images}"
  ec2_type                 = "${var.etcd_instance_type}"
  spot_price               = "${var.etcd_spot_price}"
  internal_etcd            = "${var.internal_etcd && var.master_count == 1 ? true : false}"
  external_endpoints       = "${compact(var.asi_etcd_servers)}"
  extra_tags               = "${var.asi_aws_extra_tags}"
  ign_etcd_crt_id_list     = "${module.ignition_masters.etcd_crt_id_list}"
  ign_etcd_dropin_id_list  = "${module.ignition_masters.etcd_dropin_id_list}"
  ign_etcd_tags_service_id = "${module.ignition_masters.etcd_tags_service_id}"
  instance_count           = "${var.internal_etcd && var.master_count == 1 ? 0 : length(data.template_file.etcd_hostname_list.*.id)}"
  nat_gw_workers           = "${var.nat_gw_workers ? true : false}"
  root_volume_iops         = "${var.asi_aws_etcd_root_volume_iops}"
  root_volume_size         = "${var.asi_aws_etcd_root_volume_size}"
  root_volume_type         = "${var.asi_aws_etcd_root_volume_type}"
  s3_bucket                = "${var.backend_bucket}"
  s3_bucket_region         = "${var.backend_region}"
  s3_key_prefix            = "${var.backend_bucket_key_prefix}/ignition"
  sg_ids                   = "${concat(var.asi_aws_etcd_extra_sg_ids, list(module.vpc.etcd_sg_id))}"
  ssh_key                  = "${var.keypair}"
  subnets                  = "${module.vpc.worker_subnet_ids}"
  etcd_iam_role            = "${var.asi_aws_etcd_iam_role_name}"
  ec2_ami                  = "${var.asi_aws_ec2_ami_override}"
}

module "kubeadm_config" {
  source = "../../modules/kubeadm"

  kubernetes_version = "${var.kubernetes_version}"
  cluster_name       = "${var.name}.${var.base_domain}"
  admin_user         = "${var.cluster_admin_user}"
  cluster_cidr       = "${var.asi_cluster_cidr}"
  service_cidr       = "${var.asi_service_cidr}"
  kube_apiserver_url = "api.${module.dns.api_internal_fqdn}"

  etcd_url          = "${data.template_file.etcd_hostname_list.*.rendered}"
  api_url           = "api.${module.dns.api_internal_fqdn}"
  kubeadm_token     = "${module.kubeadm_config.token}"
  worker_node_label = "node-role.kubernetes.io/node"
  cloud_provider    = "${var.cloud_provider}"
}

module "ignition_masters" {
  source = "../../modules/ignition"

  base_domain               = "${var.base_domain}"
  bootstrap_upgrade_cl      = "${var.asi_bootstrap_upgrade_cl}"
  cloud_provider            = "${var.cloud_provider}"
  cluster_name              = "${var.name}"
  container_images          = "${var.asi_container_images}"
  custom_ca_cert_pem_list   = "${var.asi_custom_ca_pem_list}"
  etcd_advertise_name_list  = "${data.template_file.etcd_hostname_list.*.rendered}"
  etcd_ca_cert_pem          = "${module.ca_certs.etcd_ca_cert_pem}"
  etcd_client_crt_pem       = "${module.etcd_certs.etcd_client_crt_pem}"
  etcd_client_key_pem       = "${module.etcd_certs.etcd_client_key_pem}"
  etcd_count                = "${var.internal_etcd && var.master_count == 1 ? "1" : length(data.template_file.etcd_hostname_list.*.id)}"
  etcd_initial_cluster_list = "${split(",", var.internal_etcd && var.master_count == 1 ? "etcd.i.${var.name}.${var.base_domain}" : join(",", data.template_file.etcd_hostname_list.*.rendered))}"
  etcd_peer_crt_pem         = "${module.etcd_certs.etcd_peer_crt_pem}"
  etcd_peer_key_pem         = "${module.etcd_certs.etcd_peer_key_pem}"
  etcd_server_crt_pem       = "${module.etcd_certs.etcd_server_crt_pem}"
  etcd_server_key_pem       = "${module.etcd_certs.etcd_server_key_pem}"
  image_re                  = "${var.asi_image_re}"
  image_re_torcx            = "${var.asi_image_re_torcx}"
  internal_etcd             = "${var.internal_etcd && var.master_count == 1 ? true : false}"
  iscsi_enabled             = "${var.asi_iscsi_enabled}"
  kube_ca_cert_pem          = "${module.ca_certs.kube_ca_cert_pem}"
  kubelet_debug_config      = "${var.asi_kubelet_debug_config}"
  kubelet_node_label        = "node-role.kubernetes.io/master"
  kubelet_node_taints       = "node-role.kubernetes.io/master=:NoSchedule"

  # https://github.com/coreos/etcd/issues/5139
  uuid = "${module.stack.shared_uuid}"
}

module "masters" {
  source = "../../modules/aws/master-asg"

  autoscaling_group_extra_tags = "${var.asi_autoscaling_group_extra_tags}"
  aws_lb_target_groups_arns    = "${module.vpc.aws_lb_target_groups_arns}"
  base_domain                  = "${var.base_domain}"
  cluster_name                 = "${var.name}"
  bastion_enabled              = "${var.bastion_enabled ? true : false}"
  container_images             = "${var.asi_container_images}"
  linux_distro                 = "flatcar"
  linux_channel                = "${var.asi_ami_linux_channel}"
  linux_version                = "${var.asi_ami_linux_version}"
  ec2_type                     = "${var.master_instance_type}"
  spot_price                   = "${var.master_spot_price}"
  extra_tags                   = "${var.asi_aws_extra_tags}"
  ign_ca_cert_id_list          = "${module.ignition_masters.masters_ca_cert_id_list}"
  ign_docker_dropin_id         = "${module.ignition_masters.docker_dropin_id}"

  # Because of the not merged PR - https://github.com/hashicorp/hil/pull/42
  ign_etcd_crt_id_list                 = "${split(",", var.internal_etcd && var.master_count == 1 ? join(",", module.ignition_masters.kube_etcd_crt_id_list) : join(",", module.etcd_certs.etcd_client_id_list))}"
  ign_etcd_dropin_id_list              = "${split(",", var.internal_etcd && var.master_count == 1 ? join(",", module.ignition_masters.etcd_dropin_id_list) : join(",", list("")))}"
  ign_init_assets_service_id           = "${module.ignition_masters.init_assets_service_id}"
  ign_installer_runtime_mappings_id    = "${module.ignition_masters.installer_runtime_mappings_id}"
  ign_iscsi_service_id                 = "${module.ignition_masters.iscsi_service_id}"
  ign_kube_certs_list                  = "${module.kube_certs.ignition_file_id_list}"
  ign_locksmithd_service_id            = "${module.ignition_masters.locksmithd_service_id}"
  ign_max_user_watches_id              = "${module.ignition_masters.max_user_watches_id}"
  ign_update_ca_certificates_dropin_id = "${module.ignition_masters.update_ca_certificates_dropin_id}"
  instance_count                       = "${var.master_count}"
  master_iam_role                      = "${var.asi_aws_master_iam_role_name}"
  master_sg_ids                        = "${concat(var.asi_aws_master_extra_sg_ids, list(module.vpc.master_sg_id))}"
  private_endpoints                    = "${var.asi_aws_private_endpoints}"
  public_endpoints                     = "${var.asi_aws_public_endpoints}"
  root_volume_iops                     = "${var.asi_aws_master_root_volume_iops}"
  root_volume_size                     = "${var.asi_aws_master_root_volume_size}"
  root_volume_type                     = "${var.asi_aws_master_root_volume_type}"
  s3_bucket                            = "${var.backend_bucket}"
  s3_bucket_region                     = "${var.backend_region}"
  s3_key_prefix                        = "${var.backend_bucket_key_prefix}/ignition"
  ssh_key                              = "${var.keypair}"
  subnet_ids                           = "${module.vpc.master_subnet_ids}"
  ec2_ami                              = "${var.asi_aws_ec2_ami_override}"
  aws_lb_api_target_group_arn          = "${module.vpc.aws_lb_api_target_group_arn}"

  lifecycle_hook_target_arn   = "${module.sns.arn}"
  lifecycle_hook_ext_r53_name = "${var.k8s_api_fqdn}"
  lifecycle_hook_ext_zone_id  = "${module.dns.ext_zone_id}"
  lifecycle_hook_int_r53_name = "api.${module.dns.api_internal_fqdn}"
  lifecycle_hook_int_zone_id  = "${module.dns.int_zone_id}"

  #kubeadm
  kubeadm_master_init_service_id  = "${module.kubeadm_config.kubeadm_master_init_service_id}"
  ign_kubeadm_config_id           = "${module.kubeadm_config.kubeadm_init_config_id}"
  ign_kubeadm_assets_id           = "${module.kubeadm_config.kubeadm_assets_id}"
  ign_kubeadm_manifest_service_id = "${module.kubeadm_config.manifest_config_service_id}"
  ign_kubeadm_manifest_script_id  = "${module.kubeadm_config.manifest_script_id}"
  ign_kubeadm_manifest_file_ids   = "${module.kubeadm_config.ignition_file_id_list}"
  k8s_api_fqdn                    = "${var.k8s_api_fqdn}"
}

module "ignition_workers" {
  source = "../../modules/ignition"

  bootstrap_upgrade_cl    = "${var.asi_bootstrap_upgrade_cl}"
  cloud_provider          = "${var.cloud_provider}"
  container_images        = "${var.asi_container_images}"
  custom_ca_cert_pem_list = "${var.asi_custom_ca_pem_list}"
  etcd_ca_cert_pem        = "${module.ca_certs.etcd_ca_cert_pem}"
  image_re                = "${var.asi_image_re}"
  image_re_torcx          = "${var.asi_image_re_torcx}"
  internal_etcd           = false
  iscsi_enabled           = "${var.asi_iscsi_enabled}"
  kube_ca_cert_pem        = "${module.ca_certs.kube_ca_cert_pem}"
  kubelet_debug_config    = "${var.asi_kubelet_debug_config}"
  kubelet_node_label      = "node-role.kubernetes.io/node"
  kubelet_node_taints     = ""
}

module "workers" {
  source = "../../modules/aws/worker-asg"

  base_domain                                     = "${var.base_domain}"
  cluster_name                                    = "${var.name}"
  linux_distro                                    = "flatcar"
  linux_channel                                   = "${var.asi_ami_linux_channel}"
  linux_version                                   = "${var.asi_ami_linux_version}"
  extra_tags                                      = "${var.asi_aws_extra_tags}"
  ign_ca_cert_id_list                             = "${module.ignition_masters.workers_ca_cert_id_list}"
  ign_docker_dropin_id                            = "${module.ignition_workers.docker_dropin_id}"
  ign_installer_runtime_mappings_id               = "${module.ignition_workers.installer_runtime_mappings_id}"
  ign_iscsi_service_id                            = "${module.ignition_workers.iscsi_service_id}"
  ign_locksmithd_service_id                       = "${module.ignition_workers.locksmithd_service_id}"
  ign_max_user_watches_id                         = "${module.ignition_workers.max_user_watches_id}"
  ign_update_ca_certificates_dropin_id            = "${module.ignition_workers.update_ca_certificates_dropin_id}"
  root_volume_iops                                = "${var.asi_aws_worker_root_volume_iops}"
  root_volume_size                                = "${var.asi_aws_worker_root_volume_size}"
  root_volume_type                                = "${var.asi_aws_worker_root_volume_type}"
  s3_bucket                                       = "${var.backend_bucket}"
  s3_bucket_region                                = "${var.backend_region}"
  s3_key_prefix                                   = "${var.backend_bucket_key_prefix}/ignition"
  sg_ids                                          = "${concat(var.asi_aws_worker_extra_sg_ids, list(module.vpc.worker_sg_id))}"
  ssh_key                                         = "${var.keypair}"
  subnet_ids                                      = "${module.vpc.worker_subnet_ids}"
  vpc_id                                          = "${module.vpc.vpc_id}"
  worker_iam_role                                 = "${var.asi_aws_worker_iam_role_name}"
  asi_aws_default_iam_role_enabled                = "${var.asi_aws_default_iam_role_enabled}"

  #kubeadm
  kubeadm_master_init_service_id = "${module.kubeadm_config.kubeadm_join_service_id}"
  ign_kubeadm_assets_id          = "${module.kubeadm_config.kubeadm_assets_id}"
  ign_kubeadm_join_config_id     = "${module.kubeadm_config.kubeadm_join_config_id}"
}

module "bastion" {
  source = "../../modules/aws/bastion-asg"

  base_domain     = "${var.base_domain}"
  cluster_name    = "${var.name}"
  bastion_enabled = "${var.bastion_enabled ? true : false}"

  bastion_eip_id            = "${module.vpc.bastion_eip_id}"
  bastion_sg                = "${module.vpc.bastion_sg_id}"
  bastion_instance_type     = "t2.micro"
  bastion_key_name          = "${var.keypair}"
  bastion_ebs_optimized     = "false"
  bastion_enable_monitoring = "false"
  bastion_volume_type       = "gp2"
  bastion_volume_size       = "8"

  bastion_max_size         = "1"
  bastion_min_size         = "1"
  bastion_desired_capacity = "1"
  bastion_asg_subnets      = "${module.vpc.bastion_subnet_ids}"

  bastion_keys_bucket = "${var.backend_bucket}"
  bastion_logs_bucket = "${var.backend_bucket}"

  bastion_keys_bucket        = "${var.backend_bucket}"
  bastion_keys_bucket_prefix = "${var.backend_bucket_key_prefix}/bastion/public-keys"
  bastion_keys_bucket_region = "${var.backend_region}"
  bastion_logs_bucket        = "${var.backend_bucket}"

  # TODO we might want to use cheaper storage driver for logs
  bastion_logs_bucket_prefix = "${var.backend_bucket_key_prefix}/bastion/logs"
  bastion_logs_bucket_region = "${var.backend_region}"
}

module "dns" {
  source = "../../modules/dns/route53"

  api_external_lb_dns_name  = "${module.vpc.aws_api_external_dns_name}"
  api_external_lb_zone_id   = "${module.vpc.aws_lb_api_external_zone_id}"
  base_domain               = "${var.base_domain}"
  cluster_name              = "${var.name}"
  bastion_enabled           = "${var.bastion_enabled ? true : false}"
  bastion_public_ip         = "${module.vpc.bastion_eip_ip}"
  bastion_zone_ttl          = "300"
  custom_dns_name           = "${var.asi_dns_name}"
  nlb_alias_enabled         = true
  etcd_count                = "${length(data.template_file.etcd_hostname_list.*.id)}"
  etcd_ip_addresses         = "${module.etcd.ip_addresses}"
  external_endpoints        = ["${compact(var.asi_etcd_servers)}"]
  internal_etcd             = "${var.internal_etcd && var.master_count == 1 ? 1 : 0}"
  master_count              = "${var.master_count}"
  asi_external_private_zone = "${var.asi_aws_external_private_zone}"
  asi_external_vpc_id       = "${module.vpc.vpc_id}"
  asi_extra_tags            = "${var.asi_aws_extra_tags}"
  asi_private_endpoints     = "${var.asi_aws_private_endpoints}"
  asi_public_endpoints      = "${var.asi_aws_public_endpoints}"
  k8s_api_fqdn              = "${var.k8s_api_fqdn}"
}

resource "aws_resourcegroups_group" "cluster" {
  name = "${var.name}.${var.base_domain}"

  resource_query {
    type = "TAG_FILTERS_1_0"

    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "superhub.io/stack/${module.stack.name1}"
    }
  ]
}
JSON
  }
}
