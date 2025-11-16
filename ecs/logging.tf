# VPC Flow Logs resources

data "aws_iam_policy_document" "vpc_flow_logs_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  count              = var.enable_cloudwatch_logging ? 1 : 0
  name               = "${var.environment}-ecs-vpc-flow-logs-role"
  description        = "IAM role for VPC Flow Logs to publish to CloudWatch Logs - Managed by Tofu"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_role.json

  tags = {
    Name = "${var.environment}-ecs-vpc-flow-logs-role"
  }
}

data "aws_iam_policy_document" "vpc_flow_logs_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = var.enable_cloudwatch_logging ? [
      aws_cloudwatch_log_group.ecs_vpc_flow_logs[0].arn,
      "${aws_cloudwatch_log_group.ecs_vpc_flow_logs[0].arn}:*"
    ] : []
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count  = var.enable_cloudwatch_logging ? 1 : 0
  name   = "${var.environment}-ecs-vpc-flow-logs-policy"
  role   = aws_iam_role.vpc_flow_logs[0].id
  policy = data.aws_iam_policy_document.vpc_flow_logs_policy.json
}

resource "aws_cloudwatch_log_group" "ecs_vpc_flow_logs" {
  count             = var.enable_cloudwatch_logging ? 1 : 0
  name              = "/aws/vpc/${var.environment}-ecs-flow-logs"
  retention_in_days = var.cloudwatch_log_retention_days
  kms_key_id        = var.enable_cloudwatch_logging ? aws_kms_key.customer_managed_key[0].arn : null

  tags = {
    Name = "${var.environment}-ecs-vpc-flow-logs"
  }
}

resource "aws_flow_log" "ecs_vpc" {
  count                = var.enable_cloudwatch_logging ? 1 : 0
  vpc_id               = aws_vpc.ecs.id
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.ecs_vpc_flow_logs[0].arn
  iam_role_arn         = aws_iam_role.vpc_flow_logs[0].arn
  traffic_type         = "ALL"

  tags = {
    Name = "${var.environment}-ecs-vpc-flow-logs"
  }
}

# ------------------------------------------------------------------------------
# CloudWatch Log Group for ECS
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "ecs_cluster" {
  count             = var.enable_cloudwatch_logging ? 1 : 0
  name              = "/aws/ecs/cluster/${var.environment}"
  retention_in_days = var.cloudwatch_log_retention_days
  kms_key_id        = var.enable_cloudwatch_logging ? aws_kms_key.customer_managed_key[0].arn : null

  tags = {
    Name = "${var.environment}-ecs-cluster-logs"
  }
}
