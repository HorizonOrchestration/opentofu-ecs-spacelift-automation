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
  default     = 512
}

variable "task_memory" {
  description = "Memory for the task in MB (512, 1024, 2048, etc.)"
  type        = number
  default     = 1024
}

variable "execution_role_arn" {
  description = "ARN of the task execution role (for ECR, logs, secrets)"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the task role (for application permissions)"
  type        = string
}

variable "container_definitions" {
  description = "Container definitions for the ECS task"
  type        = list(any)
  default     = []
}

# ------------------------------------------------------------------------------
# Service Configuration
# ------------------------------------------------------------------------------

variable "cluster_arn" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "desired_count" {
  description = "Desired number of task instances"
  type        = number
  default     = 1
}

variable "capacity_provider" {
  description = "Capacity provider name for the ECS cluster"
  type        = string
  default     = "FARGATE_SPOT"
}

variable "infra_role_arn" {
  description = "ARN of the infrastructure role for ECS tasks"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# Storage Configuration
# ------------------------------------------------------------------------------

variable "efs_file_system_id" {
  description = "EFS filesystem ID for shared configuration storage"
  type        = string
}

variable "shared_efs_access_point_id" {
  description = "EFS access point ID for shared persistent storage"
  type        = string
}

variable "ebs_volumes" {
  description = "List of EBS volumes to attach to the task containers"
  type = map(object({
    size_in_gb = optional(number, 20)
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# Networking Configuration
# ------------------------------------------------------------------------------

variable "namespace_id" {
  description = "Service Discovery Namespace ID"
  type        = string
}

variable "task_security_group_id" {
  description = "Security group ID for the ECS task"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ECS service"
  type        = list(string)
}

variable "create_discovery_service" {
  description = "Whether to create a Service Discovery service for this ECS task"
  type        = bool
  default     = true
}