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

resource "aws_efs_access_point" "shared" {
  file_system_id = aws_efs_file_system.ecs_efs.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/shared-persistent-resources"

    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }
}

# ------------------------------------------------------------------------------
# Additional Service Resources
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "ecs_resources" {
  bucket = "ecs-resources-${var.environment}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "ecs-resources-${var.environment}"
  }
}

resource "aws_s3_bucket_versioning" "ecs_resources" {
  bucket = aws_s3_bucket.ecs_resources.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ecs_resources" {
  bucket = aws_s3_bucket.ecs_resources.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.customer_managed_key.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "ecs_resources" {
  bucket = aws_s3_bucket.ecs_resources.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "ecs_resources_bucket" {
  statement {
    sid    = "AllowECSTaskAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ecs_task.arn]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.ecs_resources.arn,
      "${aws_s3_bucket.ecs_resources.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "ecs_resources" {
  bucket = aws_s3_bucket.ecs_resources.id
  policy = data.aws_iam_policy_document.ecs_resources_bucket.json
}

resource "aws_s3_object" "config_files" {
  for_each = fileset("${path.module}/resources/", "**")

  bucket  = aws_s3_bucket.ecs_resources.id
  key     = each.value
  content = replace(file("${path.module}/resources/${each.value}"), "\r", "")
  etag    = md5(replace(file("${path.module}/resources/${each.value}"), "\r", ""))
}
