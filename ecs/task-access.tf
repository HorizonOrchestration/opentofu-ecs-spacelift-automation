# ------------------------------------------------------------------------------
# ECS Task Execution Role (for pulling images, logging, secrets)
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

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.environment}-ecs-tasks-sg"
  description = "Security group for ECS tasks - Managed by Tofu"
  vpc_id      = aws_vpc.ecs.id

  egress {
    description = "Allow HTTPS outbound traffic - Managed by Tofu"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-ecs-tasks-sg"
  }
}
