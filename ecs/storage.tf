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

resource "aws_security_group" "efs" {
  name        = "ecs-efs-sg-${var.environment}"
  description = "Security group to allow ecs nodes to mount EFS - Managed by Terraform."
  vpc_id      = aws_vpc.ecs.id

  ingress {
    description = "Allow NFS access from ecs subnets - Managed by Terraform."
    protocol    = "tcp"
    to_port     = 2049
    from_port   = 2049
    cidr_blocks = [
      for subnet in(var.use_private_cidrs ? aws_subnet.ecs_private : aws_subnet.ecs_public) : subnet.cidr_block
    ]
  }

  tags = {
    Name = "ecs-efs-sg-${var.environment}"
  }
}

resource "aws_efs_mount_target" "ecs_efs" {
  count           = length(var.use_private_cidrs ? aws_subnet.ecs_private : aws_subnet.ecs_public)
  file_system_id  = aws_efs_file_system.ecs_efs.id
  subnet_id       = var.use_private_cidrs ? aws_subnet.ecs_private[count.index].id : aws_subnet.ecs_public[count.index].id
  security_groups = [aws_security_group.efs.id]
}
