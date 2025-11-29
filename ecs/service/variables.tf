# ------------------------------------------------------------------------------
# General
# ------------------------------------------------------------------------------

variable "environment" {
  description = "Environment name (e.g., dev, stage, prod)"
  type        = string
}

variable "task_name" {
  description = "Name of the ECS task"
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

# ------------------------------------------------------------------------------
# Task Configuration
# ------------------------------------------------------------------------------

variable "task_cpu" {
  description = "CPU units for the task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory for the task in MB (512, 1024, 2048, etc.)"
  type        = number
  default     = 512
}

variable "execution_role_arn" {
  description = "ARN of the task execution role (for ECR, logs, secrets)"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the task role (for application permissions)"
  type        = string
}

# ------------------------------------------------------------------------------
# Container Configuration
# ------------------------------------------------------------------------------

variable "container_definitions" {
  description = "Container definitions for the ECS task"
  type        = list(any)
  default     = []
}

# ------------------------------------------------------------------------------
# Logging Configuration
# ------------------------------------------------------------------------------

# variable "log_group_name" {
#   description = "CloudWatch log group name for container logs"
#   type        = string
#   default     = null
# }

# ------------------------------------------------------------------------------
# Storage Configuration
# ------------------------------------------------------------------------------

variable "efs_file_system_id" {
  description = "EFS filesystem ID for shared configuration storage"
  type        = string
}
