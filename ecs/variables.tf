# ------------------------------------------------------------------------------
# General
# ------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "environment tag to apply to resources"
  type        = string
  default     = "dev"
}

# ------------------------------------------------------------------------------
# Network
# ------------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24"
  ]
}

variable "azs" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
  default = [
    "eu-west-2a",
    "eu-west-2b",
    "eu-west-2c"
  ]
}

variable "use_private_cidrs" {
  description = "Whether to use private subnets with NAT gateway (true) or public subnets only (false)"
  type        = bool
  default     = true
}

variable "allowed_public_ingress_cidrs" {
  description = "List of CIDR blocks allowed to access public subnets on HTTPS (443)"
  type        = list(string)
  default     = ["154.51.81.155/32"]
}

variable "additional_public_egress_rules" {
  description = "Additional NACL egress rules for public subnets"
  type = list(object({
    name        = string
    rule_number = number
    egress      = bool
    protocol    = string
    rule_action = string
    cidr_block  = string
    from_port   = number
    to_port     = number
  }))
  default = []
}

variable "additional_private_egress_rules" {
  description = "Additional NACL egress rules for private subnets"
  type = list(object({
    name        = string
    rule_number = number
    egress      = bool
    protocol    = string
    rule_action = string
    cidr_block  = string
    from_port   = number
    to_port     = number
  }))
  default = []
}

# ------------------------------------------------------------------------------
# Logging
# ------------------------------------------------------------------------------

variable "enable_cloudwatch_logging" {
  description = "Whether to enable CloudWatch logging for VPC Flow Logs"
  type        = bool
  default     = false
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

# ------------------------------------------------------------------------------
# ECS Cluster
# ------------------------------------------------------------------------------

variable "enable_container_insights" {
  description = "Whether to enable Container Insights for the ECS cluster"
  type        = bool
  default     = false
}

variable "capacity_provider" {
  description = "ECS capacity provider to use (FARGATE or FARGATE_SPOT)"
  type        = string
  default     = "FARGATE_SPOT"
}

# ------------------------------------------------------------------------------
# ECS Service Configuration
# ------------------------------------------------------------------------------

variable "default_task_cpu" {
  description = "Default CPU units for service tasks (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "default_task_memory" {
  description = "Default memory for service tasks in MB (512, 1024, 2048, etc.)"
  type        = number
  default     = 512
}

variable "ecs_services" {
  description = "Map of ECS services to create"
  type = map(object({
    container_image       = string
    container_name        = string
    container_port        = optional(number)
    task_cpu              = optional(number)
    task_memory           = optional(number)
    environment_variables = optional(map(string), {})
    secrets               = optional(map(string), {})
    health_check = optional(object({
      command      = list(string)
      interval     = number
      timeout      = number
      retries      = number
      start_period = number
    }))
    mount_points = optional(list(object({
      source_volume  = string
      container_path = string
      read_only      = bool
    })), [])
  }))
  default = {}
}
