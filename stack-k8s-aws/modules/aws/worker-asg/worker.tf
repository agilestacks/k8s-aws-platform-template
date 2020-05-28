locals {
  asg_name        = "${var.cluster_name}-${var.base_domain}"
  # terraform "name_prefix" cannot be longer than 32 characters
  name_prefix     = "worker-${substr(replace(local.asg_name, ".", "-"), 0, min(24, length(local.asg_name)-1))}"
}

resource "aws_iam_instance_profile" "worker_profile" {
  count = "${var.asi_aws_default_iam_role_enabled == true || var.worker_iam_role != "" ? 1 : 0}"
  name  = "worker-profile-${local.asg_name}"

  role = "${var.worker_iam_role == "" ?
    join("|", aws_iam_role.worker_role.*.name) :
    join("|", data.aws_iam_role.worker_role.*.name)
  }"
}

data "aws_iam_role" "worker_role" {
  count = "${var.worker_iam_role != "" && var.asi_aws_default_iam_role_enabled == false ? 1 : 0}"
  name  = "${var.worker_iam_role}"
}

resource "aws_iam_role" "worker_role" {
  count        = "${var.asi_aws_default_iam_role_enabled == true ? 1 : 0}"
  name_prefix  = "${local.name_prefix}"
  path         = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    },
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": { "Service": "ecs-tasks.amazonaws.com"}
    },
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": { "Service": "batch.amazonaws.com"}
    },
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": { "Service": "iam.amazonaws.com"}
    }
  ]
}
EOF

  tags = "${merge(map(
    "kubernetes.io/cluster/${var.cluster_name}-${var.base_domain}", "owned",
    "superhub.io/stack/${var.cluster_name}.${var.base_domain}", "owned",
    "superhub.io/role/kind", "worker",
  ), var.extra_tags)}"
}

resource "aws_iam_role_policy" "worker_policy" {
  count = "${var.asi_aws_default_iam_role_enabled == true ? 1 : 0}"
  name  = "${var.cluster_name}_worker_policy"
  role  = "${aws_iam_role.worker_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "elasticloadbalancing:*",
        "route53:*",
        "s3:*",
        "sts:*",
        "dynamodb:*"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:CompleteLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:InitiateLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:BatchGetImage",
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "sts:AssumeRole",
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action" : [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:CompleteLifecycleAction",
        "autoscaling:DescribeLifecycleHooks",
        "autoscaling:DescribeTags",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action" : [
        "iam:CreateServiceLinkedRole",
        "iam:GetRole",
        "iam:ListGroups",
        "iam:ListInstanceProfiles",
        "iam:ListRoleTags",
        "iam:ListRoles",
        "iam:TagRole",
        "iam:UntagRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
