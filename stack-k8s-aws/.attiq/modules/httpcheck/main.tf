data "template_file" "httpcheck" {
  template = "${file("${path.module}/create.sh")}"

  vars {
    master_count = "${var.master_count}"
    context      = "${var.context}"
    cluster     = "${element(split(":", element(split("://api.", "${var.server}"), 1)), 0)}"
    server      = "${var.server}"
    ca_pem      = "${local_file.ca_crt.filename}"
    client_key  = "${local_file.client_key.filename}"
    client_pem  = "${local_file.client_crt.filename}"
    namespace   = "${var.namespace}"
    use_context = "${var.use_context}"
  }
}

resource "local_file" "create" {
  content  = "${data.template_file.httpcheck.rendered}"
  filename = "${path.cwd}/.terraform/${replace("${var.context}", ".", "-")}-create.sh"

  provisioner "local-exec" {
    command = "chmod +x ${self.filename}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "kubeconfig_delete" {
  template = "${file("${path.module}/unconfigure.sh")}"

  vars {
    cluster = "${element(split(":", element(split("://api.", "${var.server}"), 1)), 0)}"
  }
}

resource "local_file" "unconfigure" {
  content  = "${data.template_file.kubeconfig_delete.rendered}"
  filename = "${path.cwd}/.terraform/${replace(element(split(":", element(split("://api.", "${var.server}"), 1)), 0), ".", "-")}-unkubeconfig.sh"

  provisioner "local-exec" {
    command = "chmod +x ${self.filename}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "create" {
  depends_on = ["local_file.create",
    "local_file.unconfigure",
  ]

  triggers {
    trigger_function = "${uuid()}"
  }

  provisioner "local-exec" {
    on_failure = "continue"
    command    = "sh ${local_file.create.filename}"
  }

  provisioner "local-exec" {
    on_failure = "continue"
    when       = "destroy"

    # this is originally `sh ${local_file.unconfigure.filename}`, but
    # * module.kubeconfig.null_resource.configure (destroy): 1 error(s) occurred:
    # * Resource 'local_file.unconfigure' not found for variable 'local_file.unconfigure.filename'
    command = "[ \"${var.apply}\" = \"true\" ] && sh ${path.cwd}/.terraform/${replace(element(split(":", element(split("://api.", "${var.server}"), 1)), 0), ".", "-")}-unkubeconfig.sh"

    #command = "[ \"${var.apply}\" = \"true\" ] && sh ${local_file.unconfigure.filename}"
  }
}

resource "local_file" "client_crt" {
  content  = "${var.client_pem}"
  filename = "${path.cwd}/.terraform/${replace(element(split(":", element(split("://api.", "${var.server}"), 1)), 0), ".", "-")}-client.pem"

  lifecycle {
    create_before_destroy = true
  }
}

resource "local_file" "client_key" {
  content  = "${var.client_key}"
  filename = "${path.cwd}/.terraform/${replace(element(split(":", element(split("://api.", "${var.server}"), 1)), 0), ".", "-")}-client-key.pem"

  lifecycle {
    create_before_destroy = true
  }
}

resource "local_file" "ca_crt" {
  content  = "${var.ca_pem}"
  filename = "${path.cwd}/.terraform/${replace(element(split(":", element(split("://api.", "${var.server}"), 1)), 0), ".", "-")}-ca.pem"

  lifecycle {
    create_before_destroy = true
  }
}
