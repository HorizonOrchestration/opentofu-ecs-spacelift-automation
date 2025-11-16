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
├── prereqs/          # IAM roles and prerequisites for Spacelift
└── (future)          # ECS clusters, services, networking, etc.
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
- Run Spacelift local preview validation

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
