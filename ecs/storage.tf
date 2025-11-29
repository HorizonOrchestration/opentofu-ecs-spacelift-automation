# ------------------------------------------------------------------------------
# Storage Resources
# ------------------------------------------------------------------------------

resource "aws_efs_file_system" "ecs_efs" {
  creation_token = "ecs-efs-${var.environment}"
  encrypted      = true
  kms_key_id     = aws_kms_key.customer_managed_key.arn

  tags = {
    Name = "ecs-efs-${var.environment}"
  }
}
