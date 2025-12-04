# ------------------------------------------------------------------------------
# ECS IAM Resources and Security Group
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "ecs_task_execution_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.environment}-ecs-task-execution-role"
  description        = "IAM role for ECS task execution (ECR, logs, secrets) - Managed by Tofu"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role.json

  tags = {
    Name = "${var.environment}-ecs-task-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional permissions for CloudWatch Logs
data "aws_iam_policy_document" "ecs_task_execution_logs" {
  count = var.enable_cloudwatch_logging ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.ecs_tasks[0].arn,
      "${aws_cloudwatch_log_group.ecs_tasks[0].arn}:*"
    ]
  }
}

resource "aws_iam_role_policy" "ecs_task_execution_logs" {
  count  = var.enable_cloudwatch_logging ? 1 : 0
  name   = "${var.environment}-ecs-task-execution-logs-policy"
  role   = aws_iam_role.ecs_task_execution.id
  policy = data.aws_iam_policy_document.ecs_task_execution_logs[0].json
}

# Additional permissions for SSM Parameter Store / Secrets Manager
data "aws_iam_policy_document" "ecs_task_execution_secrets" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}_ecs/*",
      "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.environment}_ecs/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = ["arn:aws:kms:eu-west-2:${data.aws_caller_identity.current.account_id}:key/*"]
  }
}

resource "aws_iam_role_policy" "ecs_task_execution_secrets" {
  name   = "${var.environment}-ecs-task-execution-secrets-policy"
  role   = aws_iam_role.ecs_task_execution.id
  policy = data.aws_iam_policy_document.ecs_task_execution_secrets.json
}

# ------------------------------------------------------------------------------
# ECS Task Role (for application permissions)
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_task" {
  name               = "${var.environment}-ecs-task-role"
  description        = "IAM role for ECS tasks (application permissions) - Managed by Tofu"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = {
    Name = "${var.environment}-ecs-task-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_ssm" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ------------------------------------------------------------------------------
# ECS Infrastructure Role (for EBS volume management)
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "ecs_infrastructure_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_infrastructure" {
  name               = "${var.environment}-ecs-infrastructure-role"
  description        = "IAM role for ECS infrastructure management (EBS volumes) - Managed by Tofu"
  assume_role_policy = data.aws_iam_policy_document.ecs_infrastructure_assume_role.json

  tags = {
    Name = "${var.environment}-ecs-infrastructure-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_infrastructure_volumes" {
  role       = aws_iam_role.ecs_infrastructure.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForVolumes"
}

# ------------------------------------------------------------------------------
# Security Group for ECS Tasks
# ------------------------------------------------------------------------------

locals {
  # Create combinations of service ports and allowed ingress CIDRs for ingress rules
  ecs_task_ingress_rules = flatten([
    for cidr in var.allowed_public_ingress_cidrs : [
      for port in local.service_ports : {
        cidr = cidr
        port = port
        key  = "${replace(cidr, "/", "_")}_${port}"
      }
    ]
  ])
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.environment}-ecs-tasks-sg"
  description = "Security group for ECS tasks - Managed by Tofu"
  vpc_id      = aws_vpc.ecs.id

  tags = {
    Name = "${var.environment}-ecs-tasks-sg"
  }
}

resource "aws_security_group_rule" "ecs_tasks_egress_https" {
  type              = "egress"
  description       = "Allow HTTPS outbound traffic - Managed by Tofu"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "ecs_tasks_egress_nfs" {
  type              = "egress"
  description       = "Allow NFS traffic for EFS - Managed by Tofu"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.ecs.cidr_block]
  security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "ecs_tasks_ingress" {
  for_each = { for access in local.ecs_task_ingress_rules : access.key => access }

  type              = "ingress"
  description       = "Allow ingress from ${each.value.cidr} on port ${each.value.port} - Managed by Tofu"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = "tcp"
  cidr_blocks       = [each.value.cidr]
  security_group_id = aws_security_group.ecs_tasks.id
}

# ------------------------------------------------------------------------------
# Service Discovery Resources
# ------------------------------------------------------------------------------

resource "aws_service_discovery_private_dns_namespace" "ecs" {
  name        = "${var.environment}-ecs"
  description = "Private DNS namespace for ECS services - Managed by Tofu"
  vpc         = aws_vpc.ecs.id

  tags = {
    Name = "${var.environment}-ecs"
  }
}
