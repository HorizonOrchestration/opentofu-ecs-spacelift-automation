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

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Docker image to use for the container"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on (set to null if no port mapping needed)"
  type        = number
  default     = null
}

variable "environment_variables" {
  description = "Environment variables to pass to the container"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets to pass to the container from SSM Parameter Store or Secrets Manager"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# Logging Configuration
# ------------------------------------------------------------------------------

variable "log_group_name" {
  description = "CloudWatch log group name for container logs"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# Health Check Configuration
# ------------------------------------------------------------------------------

variable "health_check" {
  description = "Container health check configuration"
  type = object({
    command      = list(string)
    interval     = number
    timeout      = number
    retries      = number
    start_period = number
  })
  default = null
}

# ------------------------------------------------------------------------------
# Volume Configuration
# ------------------------------------------------------------------------------

variable "mount_points" {
  description = "Mount points for volumes in the container"
  type = list(object({
    source_volume  = string
    container_path = string
    read_only      = bool
  }))
  default = []
}

variable "efs_volumes" {
  description = "EFS volumes to attach to the task"
  type = list(object({
    name            = string
    file_system_id  = string
    root_directory  = string
    access_point_id = string
  }))
  default = []
}
