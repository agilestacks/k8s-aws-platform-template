locals {
  varlibkubeletpods_devicename = "/dev/xvdb"
  rnd = "${random_string.rnd.result}"
  # varlibkubeletpods_devicename = "/dev/sdb"
}

data "ignition_systemd_unit" "kubelet_dropin" {
  name = "kubelet.service"
  dropin {
    name = "10-wait-volume-mount.conf"
    content = "${local_file.kubelet_dropin.content}"
  }
}

data "ignition_filesystem" "varlibkubeletpods" {
  mount {
    device = "${local.varlibkubeletpods_devicename}"
    format = "ext4"
    label  = "pods"
  }
}

data "ignition_systemd_unit" "varlibkubeletpods" {
  name    = "var-lib-kubelet-pods.mount"
  enabled = true
  content = "${local_file.varlibkubeletpods.content}"
}

data "ignition_systemd_unit" "kubelet" {
  name = "kubelet.service"
  dropin {
    name = "10-wait-var-lib-kubelet-pods-mount.conf"
    content = "${local_file.kubelet_dropin.content}"
  }
}

resource "local_file" "varlibkubeletpods" {
  filename = "${path.module}/.terraform/${local.rnd}.service"
  content  = <<EOF
[Unit]
Description=Mount ebs to /var/lib/kubelet/pods
Before=local-fs.target
[Mount]
What=${local.varlibkubeletpods_devicename}
Where=/var/lib/kubelet/pods
Type=ext4
[Install]
WantedBy=local-fs.target
EOF

  lifecycle {
    create_before_destroy = true
    ignore_changes = ["filename"]
  }
}

resource "local_file" "kubelet_dropin" {
  filename = "${path.module}/.terraform/${local.rnd}-dropin1.service"
  content  = <<EOF
[Unit]
After=var-lib-kubelet-pods.mount
Requires=var-lib-kubelet-pods.mount
EOF
  lifecycle {
    ignore_changes = ["filename"]
  }
}
