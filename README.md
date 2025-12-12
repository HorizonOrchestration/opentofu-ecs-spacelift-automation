# OpenTofu ECS Spacelift Automation

Infrastructure as Code for deploying containerized workloads to AWS ECS using OpenTofu, managed via Spacelift.

## Overview

This repository contains OpenTofu configurations for deploying a personal ECS lab environment, comparing cost and complexity with EKS. The stack uses:

- **AWS ECS (Fargate)** - Container orchestration
- **OpenTofu** - Infrastructure as Code
- **Spacelift** - CI/CD and state management
- **Environment-based configuration** - Separate tfvars per environment (dev, stage, prod)

## Repository Structure

```
.
├── prereqs/  # IAM roles and prerequisites for Spacelift
└── ecs/      # ECS cluster, services, networking, etc.
```

## Getting Started

### Prerequisites Setup

The `prereqs/` directory contains the IAM role configuration that Spacelift assumes when executing deployments:

1. Configure your Spacelift credentials in `prereqs/local.auto.tfvars`
2. Initialize and apply:
   ```bash
   cd prereqs
   tofu init
   tofu apply
   ```
3. Configure the output role ARN in your Spacelift stack settings

### Design Principles

- **Environment-based configuration** - Use `*.tfvars` per environment
- **Encryption at rest** - Enabled for all supported resources (EBS, S3, RDS, etc.)
- **Least privilege IAM** - Separate task roles (app permissions) and execution roles (infrastructure)
- **Fargate Spot** - Preferred launch type unless configured otherwise
- **Managed by Tofu** - All resource descriptions end with "- Managed by Tofu"

## Development

### Pre-commit Hooks

This repository uses [pre-commit](https://pre-commit.com/) to automatically:
- Format terraform code with `terraform fmt`
- Generate terraform documentation for the `ecs/` directory

To install:
```bash
# Install pre-commit (if not already installed)
pip install pre-commit

# Install the git hooks
pre-commit install
```

The hooks will run automatically on `git commit`. To run manually:
```bash
pre-commit run --all-files
```

## SpaceLift GitOps

### Workflow

Each commit triggers an automated workflow in Spacelift:

1. **Format & Lint** - `tofu fmt` ensures consistent formatting, `tflint` validates configuration
2. **Security Scan** - `terrascan` checks for misconfigurations and compliance violations
3. **Plan & Cost** - `tofu plan` generates execution plan, `infracost` estimates AWS spend impact
4. **Review & Apply** - Manual approval required before infrastructure changes are applied

Stacks are configured for auto-deployment on merge to `main` for lower environments, with manual approval gates for production.

## Reference Architecture

This project mirrors the structure and quality of [HorizonOrchestration/tf-eks-helm-automation](https://github.com/HorizonOrchestration/tf-eks-helm-automation), adapted for ECS instead of EKS/Helm.
<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_services"></a> [services](#module\_services) | ./service | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ecs_vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_default_security_group.ecs_default_block_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_efs_access_point.shared](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_file_system.ecs_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.ecs_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_eip.ecs_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.ecs_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.ecs_infrastructure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_task_execution_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecs_task_execution_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecs_task_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_infrastructure_ec2_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_infrastructure_volumes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_task_ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_kms_key.customer_managed_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_nat_gateway.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.ecs_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.ecs_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.ecs_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.ecs_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.service_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_route.ecs_private_nat_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.ecs_public_internet_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.ecs_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.ecs_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.ecs_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.ecs_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_s3_bucket.ecs_resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.ecs_resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.ecs_resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.ecs_resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.ecs_resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.config_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_security_group.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.ecs_tasks_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_tasks_egress_nfs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_tasks_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_service_discovery_private_dns_namespace.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_subnet.ecs_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.ecs_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.customer_managed_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_infrastructure_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_resources_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_execution_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_execution_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_execution_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_flow_logs_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_flow_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_private_egress_rules"></a> [additional\_private\_egress\_rules](#input\_additional\_private\_egress\_rules) | Additional NACL egress rules for private subnets | <pre>list(object({<br/>    name        = string<br/>    rule_number = number<br/>    egress      = bool<br/>    protocol    = string<br/>    rule_action = string<br/>    cidr_block  = string<br/>    from_port   = number<br/>    to_port     = number<br/>  }))</pre> | `[]` | no |
| <a name="input_allowed_public_ingress_cidrs"></a> [allowed\_public\_ingress\_cidrs](#input\_allowed\_public\_ingress\_cidrs) | List of CIDR blocks allowed to access public subnets on HTTPS (443) | `list(string)` | <pre>[<br/>  "123.123.123.123/32"<br/>]</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where resources will be deployed | `string` | `"eu-west-2"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | List of availability zones to use for subnets | `list(string)` | <pre>[<br/>  "eu-west-2a",<br/>  "eu-west-2b",<br/>  "eu-west-2c"<br/>]</pre> | no |
| <a name="input_capacity_provider"></a> [capacity\_provider](#input\_capacity\_provider) | ECS capacity provider to use (FARGATE or FARGATE\_SPOT) | `string` | `"FARGATE"` | no |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | Number of days to retain CloudWatch logs | `number` | `7` | no |
| <a name="input_ecs_services"></a> [ecs\_services](#input\_ecs\_services) | Map of ECS services to create | <pre>map(object({<br/>    task_cpu    = optional(number, 512)<br/>    task_memory = optional(number, 1024)<br/>    container_definitions = list(object({<br/>      name              = string<br/>      image             = string<br/>      essential         = optional(bool, true)<br/>      cpu               = optional(number, 0)<br/>      memory            = optional(number)<br/>      memoryReservation = optional(number)<br/>      startTimeout      = optional(number, 60)<br/>      stopTimeout       = optional(number, 120)<br/>      portMappings = optional(list(object({<br/>        name          = string<br/>        containerPort = number<br/>        hostPort      = number<br/>        protocol      = optional(string, "tcp")<br/>      })), [])<br/>      environment = optional(list(object({<br/>        name  = string<br/>        value = string<br/>      })), [])<br/>      secrets = optional(list(object({<br/>        name      = string<br/>        valueFrom = string<br/>      })), [])<br/>      command = optional(list(string), [])<br/>      logConfiguration = optional(object({<br/>        logDriver = optional(string)<br/>        options   = optional(map(string), {})<br/>      }), {})<br/>      mountPoints = optional(list(object({<br/>        sourceVolume  = string<br/>        containerPath = string<br/>        readOnly      = optional(bool, false)<br/>      })), [])<br/>      dependsOn = optional(list(map(string)), [])<br/>    }))<br/>    create_discovery_service = optional(bool, true)<br/>    ebs_volumes = optional(map(object({<br/>      size_in_gb = optional(number, 20)<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_egress_ports"></a> [egress\_ports](#input\_egress\_ports) | List of egress ports to allow | `list(number)` | <pre>[<br/>  443<br/>]</pre> | no |
| <a name="input_enable_cloudwatch_logging"></a> [enable\_cloudwatch\_logging](#input\_enable\_cloudwatch\_logging) | Whether to enable CloudWatch logging for VPC Flow Logs | `bool` | `true` | no |
| <a name="input_enable_container_insights"></a> [enable\_container\_insights](#input\_enable\_container\_insights) | Whether to enable Container Insights for the ECS cluster | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | environment tag to apply to resources | `string` | `"dev"` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | List of CIDR blocks for private subnets | `list(string)` | <pre>[<br/>  "10.0.11.0/24",<br/>  "10.0.12.0/24",<br/>  "10.0.13.0/24"<br/>]</pre> | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | List of CIDR blocks for public subnets | `list(string)` | <pre>[<br/>  "10.0.1.0/24",<br/>  "10.0.2.0/24",<br/>  "10.0.3.0/24"<br/>]</pre> | no |
| <a name="input_use_private_cidrs"></a> [use\_private\_cidrs](#input\_use\_private\_cidrs) | Whether to use private subnets with NAT gateway (true) or public subnets only (false) | `bool` | `true` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_private_subnet_ids"></a> [ecs\_private\_subnet\_ids](#output\_ecs\_private\_subnet\_ids) | Private subnet IDs for ECS cluster |
| <a name="output_ecs_public_subnet_ids"></a> [ecs\_public\_subnet\_ids](#output\_ecs\_public\_subnet\_ids) | Public subnet IDs for ECS cluster |
| <a name="output_ecs_vpc_id"></a> [ecs\_vpc\_id](#output\_ecs\_vpc\_id) | VPC ID for ECS cluster |
<!-- END_TF_DOCS -->
