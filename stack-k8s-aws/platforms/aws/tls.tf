module "ca_certs" {
  source = "../../modules/tls/ca"

  kube_ca_cert_pem_path = "${var.asi_ca_cert}"
  kube_ca_key_alg       = "${var.asi_ca_key_alg}"
  kube_ca_key_pem_path  = "${var.asi_ca_key}"
}

module "kube_certs" {
  source = "../../modules/tls/kube"

  kube_ca_cert_pem = "${module.ca_certs.kube_ca_cert_pem}"
  kube_ca_key_alg  = "${module.ca_certs.kube_ca_key_alg}"
  kube_ca_key_pem  = "${module.ca_certs.kube_ca_key_pem}"

  front_proxy_ca_cert_pem      = "${module.ca_certs.front_proxy_ca_cert_pem}"
  front_proxy_ca_key_alg       = "${module.ca_certs.front_proxy_ca_key_alg}"
  front_proxy_ca_key_pem       = "${module.ca_certs.front_proxy_ca_key_pem}"

  kube_apiserver_url = "${var.k8s_api_fqdn == "" ? "https://${module.vpc.aws_api_external_dns_name}:443/" : "https://${var.k8s_api_fqdn}:6443/"}"
  service_cidr       = "${var.asi_service_cidr}"
  validity_period    = "${var.asi_tls_validity_period}"
  common_name        = "${var.cluster_admin_user}@${module.dns.api_external_fqdn}"
  int_api_fqdn       = "api.${module.dns.api_internal_fqdn}"
}

module "etcd_certs" {
  source = "../../modules/tls/etcd"

  etcd_ca_cert_pem = "${module.ca_certs.etcd_ca_cert_pem}"
  etcd_ca_key_alg  = "${module.ca_certs.etcd_ca_key_alg}"
  etcd_ca_key_pem  = "${module.ca_certs.etcd_ca_key_pem}"

  etcd_cert_dns_names   = "${data.template_file.etcd_hostname_list.*.rendered}"
  etcd_cert_common_name = "${module.dns.etcd_a_name}.i.${var.name}.${var.base_domain}"
  # Used for external etcd cluster
  /* etcd_client_cert_path = "${var.asi_etcd_client_cert_path}"
  etcd_client_key_path  = "${var.asi_etcd_client_key_path}"
  self_signed           = "${length(compact(var.asi_etcd_servers)) == 0 ? "true" : "false"}"
  */
  service_cidr          = "${var.asi_service_cidr}"
}
