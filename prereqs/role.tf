# IAM role for Spacelift to assume when executing OpenTofu plans and applies
# Uses AWS managed policies for simplicity and minimal custom permissions


# Trust policy allowing Spacelift to assume this role
data "aws_iam_policy_document" "spacelift_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.spacelift_principal_arn]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringLike"
      variable = "sts:ExternalId"
      values   = [var.spacelift_external_id_pattern]
    }
  }
}

resource "aws_iam_role" "spacelift_tofu" {
  name               = "spacelift-tofu-execution-role"
  description        = "IAM role for Spacelift to manage ECS infrastructure via OpenTofu - Managed by Tofu"
  assume_role_policy = data.aws_iam_policy_document.spacelift_assume_role.json
}

# AWS managed policies to attach
locals {
  managed_policies = [
    "AmazonECS_FullAccess",
    "AmazonEC2ContainerRegistryFullAccess",
    "AmazonVPCFullAccess",
    "ElasticLoadBalancingFullAccess",
    "CloudWatchFullAccess",
    "AmazonS3FullAccess",
    "IAMFullAccess"
  ]
}

# Attach AWS managed policies using for_each
resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = {
    for policy in local.managed_policies : policy => policy
  }

  role       = aws_iam_role.spacelift_tofu.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

# Minimal custom policy for IAM role management and other services
data "aws_iam_policy_document" "spacelift_custom_permissions" {
  # IAM - Create and manage service roles for ECS tasks
  statement {
    sid    = "IAMRoleManagement"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:UpdateRole",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PassRole",
      "iam:TagRole",
      "iam:UntagRole",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecs-*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*-ecs-*",
    ]
  }

  # Application Auto Scaling - For ECS service autoscaling
  statement {
    sid       = "AutoScaling"
    effect    = "Allow"
    actions   = ["application-autoscaling:*"]
    resources = ["*"]
  }

  # Systems Manager Parameter Store
  statement {
    sid       = "SSMParameters"
    effect    = "Allow"
    actions   = ["ssm:*"]
    resources = ["*"]
  }

  # Secrets Manager
  statement {
    sid       = "SecretsManager"
    effect    = "Allow"
    actions   = ["secretsmanager:*"]
    resources = ["*"]
  }

  # Service Discovery
  statement {
    sid       = "ServiceDiscovery"
    effect    = "Allow"
    actions   = ["servicediscovery:*"]
    resources = ["*"]
  }

  # Route53 for DNS
  statement {
    sid       = "Route53"
    effect    = "Allow"
    actions   = ["route53:*"]
    resources = ["*"]
  }

  # KMS for encryption
  statement {
    sid       = "KMS"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "spacelift_custom_policy" {
  name   = "spacelift-custom-permissions"
  role   = aws_iam_role.spacelift_tofu.id
  policy = data.aws_iam_policy_document.spacelift_custom_permissions.json
}

# Output the role ARN for use in Spacelift configuration
output "spacelift_role_arn" {
  description = "ARN of the IAM role for Spacelift to assume"
  value       = aws_iam_role.spacelift_tofu.arn
}

output "spacelift_role_name" {
  description = "Name of the IAM role for Spacelift"
  value       = aws_iam_role.spacelift_tofu.name
}
