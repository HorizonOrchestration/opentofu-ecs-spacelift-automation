# Shared Encryption Resources

data "aws_iam_policy_document" "customer_managed_key" {
  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.region}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowAccount"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "customer_managed_key" {
  count               = var.enable_cloudwatch_logging ? 1 : 0
  description         = "CMK KMS key for environment-wide usage - Managed by Tofu"
  enable_key_rotation = true

  policy = data.aws_iam_policy_document.customer_managed_key.json

  tags = {
    Name = "${var.environment}-kms-cmk"
  }
}
