data "ignition_config" "etcd" {
  count = "${var.instance_count}"

  systemd = [
    "${data.ignition_systemd_unit.locksmithd.*.id[count.index]}",
    "${var.ign_etcd_dropin_id_list[count.index]}",
    "${var.ign_etcd_tags_service_id}",
  ]

  files = ["${flatten(list(
    var.ign_etcd_crt_id_list,
    list(
      data.ignition_file.etcd_tags.id,
      data.ignition_file.update_tags.id,
    ),
   ))}"]
}

data "ignition_systemd_unit" "locksmithd" {
  count = "${var.instance_count}"

  name    = "locksmithd.service"
  enabled = true

  dropin = [
    {
      name = "40-etcd-lock.conf"

      content = <<EOF
[Service]
Environment=REBOOT_STRATEGY=off
Environment="LOCKSMITHD_ETCD_CAFILE=/etc/ssl/etcd/ca.crt"
Environment="LOCKSMITHD_ETCD_KEYFILE=/etc/ssl/etcd/client.key"
Environment="LOCKSMITHD_ETCD_CERTFILE=/etc/ssl/etcd/client.crt"
Environment="LOCKSMITHD_ENDPOINT=https://etcd-${count.index}.i.${var.cluster_name}.${var.base_domain}:2380"
EOF
    },
  ]
}

data "template_file" "etcd_tags" {
  template = "${file("${path.module}/resources/etcd-tags.sh")}"

  vars {
    cluster_name = "${var.cluster_name}.${var.base_domain}"
    awscli_image = "${var.container_images["awscli"]}"
    update_tags  = "${var.spot_price == "" ? "false" : "true"}"
  }
}

data "ignition_file" "etcd_tags" {
  filesystem = "root"
  path       = "/opt/etcd-tags.sh"
  mode       = 0755

  content {
    content = "${data.template_file.etcd_tags.rendered}"
  }
}

data "template_file" "update_tags" {
  template = "${file("${path.module}/resources/update-tags.sh")}"
}

data "ignition_file" "update_tags" {
  filesystem = "root"
  path       = "/opt/update-tags.sh"
  mode       = 0755

  content {
    content = "${data.template_file.update_tags.rendered}"
  }
}
