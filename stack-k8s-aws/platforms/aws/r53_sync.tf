locals {
  r53_sync_dir = "${path.cwd}/lambda/r53-sync"
}

data "local_file" "r53_sync_zip" {
  filename   = "${local.r53_sync_dir}/lambda.zip"
}

module "lambda_r53_sync" {
  source   = "../../modules/lambda"
  name     = "r53-sync-${module.stack.name2}"
  handler  = "main.handler"
  zip_file = "${data.local_file.r53_sync_zip.filename}"
  policy   = "${file("${local.r53_sync_dir}/policy.json")}"
  runtime  = "${var.r53_sync_runtime}"
  tags     = {
      "kubernetes.io/cluster/${var.name}-${var.base_domain}" = "owned",
      "superhub.io/stack/${var.name}.${var.base_domain}"     = "owned",
  }
}

module "sns" {
  source = "../../modules/sns"
  name   = "sns-${module.stack.name2}"
}

module "sns_subscription" {
  source      = "../../modules/sns_subscription"
  lambda_arn  = "${module.lambda_r53_sync.arn}"
  lambda_name = "${module.lambda_r53_sync.name}"
  sns_arn     = "${module.sns.arn}"
}
