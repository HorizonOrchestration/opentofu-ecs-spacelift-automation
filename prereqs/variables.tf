variable "aws_region" {
  description = "AWS region for provider configuration"
  type        = string
  default     = "eu-west-2"
}

variable "spacelift_principal_arn" {
  description = "ARN of the Spacelift AWS principal that will assume this role"
  type        = string
}

variable "spacelift_external_id_pattern" {
  description = "External ID for Spacelift role assumption (provided by Spacelift)"
  type        = string
  sensitive   = true
}
