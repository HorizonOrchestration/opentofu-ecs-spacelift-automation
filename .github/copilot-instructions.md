# Copilot Instructions for This Project

## Project overview
This repo is for migrating personal workloads from EKS to ECS to compare cost and complexity.
The stack is: AWS + Terraform + ECS (Fargate Spot) + SpaceLift.
The design should mirror the structure and quality of HorizonOrchestration/tf-eks-helm-automation, but use ECS instead of EKS/Helm.

## What to generate
When writing or completing code/config, prefer:
A segregated Terraform file, and a commented variable section in variables.tf for:
- networking (VPC, subnets, routing, NAT, endpoints)
- ecs-cluster (cluster, capacity providers, cluster-level settings)
- ecs-service (task definitions, services, autoscaling, load balancers)
- storage (S3 buckets, EBS volumes for config/data persistence)
- monitoring (CloudWatch log groups)

## Help when troubleshooting
When in agent mode, DO NOT started editing code unless explicitly asked.
When helping with troubleshooting, be succinct in your explanations, giving only one or two suggestions at a time.

## Terraform conventions
Use environment-based configuration with *.tfvars per environment (e.g. dev, stage, prod).
Always enable encryption at rest where supported (EBS, S3, RDS, etc.).
Whenever a provider resource supports a "description" field, populate it with a meaningful description, ending in "- Managed by Tofu" (DO NOT do this for outputs and input variables).

## Follow least privilege IAM:
Separate task role (app permissions) and execution role (ECR/logging).
Prefer Fargate Spot launch types unless explicitly configured otherwise.

## ECS-specific patterns
Load secrets from SSM Parameter Store or Secrets Manager.
Optionally configure autoscaling on CPU/memory or request-based metrics.

## For internet-facing services:
Create ALBs with HTTPS listeners and security groups scoped to required ports.

## Style & structure
Prefer small, composable terraform files.
Add clear descriptions and comments for inputs/outputs of modules.
Keep configuration minimal but production-aligned (e.g. logging, encryption, IAM best practices).

