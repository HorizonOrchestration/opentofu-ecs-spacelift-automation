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
  default     = ["123.123.123.123/32"]
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

variable "egress_ports" {
  description = "List of egress ports to allow"
  type        = list(number)
  default     = [443]
}

# ------------------------------------------------------------------------------
# Logging
# ------------------------------------------------------------------------------

variable "enable_cloudwatch_logging" {
  description = "Whether to enable CloudWatch logging for VPC Flow Logs"
  type        = bool
  default     = true
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
  default     = true
}

variable "capacity_provider" {
  description = "ECS capacity provider to use (FARGATE or FARGATE_SPOT)"
  type        = string
  default     = "FARGATE"
}

# ------------------------------------------------------------------------------
# ECS Service Configuration
# ------------------------------------------------------------------------------

variable "ecs_services" {
  description = "Map of ECS services to create"
  type = map(object({
    task_cpu    = optional(number, 512)
    task_memory = optional(number, 1024)
    container_definitions = list(object({
      name              = string
      image             = string
      essential         = optional(bool, true)
      cpu               = optional(number, 256)
      memory            = optional(number, 512)
      memoryReservation = optional(number, 256)
      startTimeout      = optional(number, 60)
      stopTimeout       = optional(number, 120)
      portMappings = optional(list(object({
        name          = string
        containerPort = number
        hostPort      = number
        protocol      = optional(string, "tcp")
      })), [])
      environment = optional(list(object({
        name  = string
        value = string
      })), [])
      secrets = optional(list(object({
        name      = string
        valueFrom = string
      })), [])
      command = optional(list(string), [])
      logConfiguration = optional(object({
        logDriver = optional(string)
        options   = optional(map(string), {})
      }), {})
      mountPoints = optional(list(object({
        sourceVolume  = string
        containerPath = string
        readOnly      = optional(bool, false)
      })), [])
      dependsOn = optional(list(map(string)), [])
    }))
    create_discovery_service = optional(bool, true)
    ebs_volumes = optional(map(object({
      size_in_gb = optional(number, 20)
    })), {})
  }))
  default = {}
}
