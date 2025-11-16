#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Builds and pushes a Docker image to AWS ECR Public.

.DESCRIPTION
    This script builds a Docker image from the Dockerfile in the current directory
    and pushes it to AWS ECR Public.

.PARAMETER RepositoryName
    The name of the ECR Public repository (default: runners/spacelift)

.PARAMETER ImageTag
    The tag for the Docker image (default: latest)

.EXAMPLE
    .\Build-Image.ps1
    .\Build-Image.ps1 -RepositoryName runners/spacelift -ImageTag v1.0.0
#>

param(
    [string]$RepositoryName = "runners/spacelift",
    [string]$ImageTag = "latest"
)

$ErrorActionPreference = "Stop"

Write-Host "Building and pushing Docker image to ECR Public..." -ForegroundColor Cyan

# Public ECR always uses us-east-1
$Region = "us-east-1"

# Construct ECR Public repository URI
$EcrUri = "public.ecr.aws"

# Check if ECR Public repository exists
Write-Host "`n→ Checking if ECR Public repository exists..." -ForegroundColor Yellow
aws ecr-public describe-repositories --repository-names $RepositoryName --region $Region 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "ECR Public repository '$RepositoryName' does not exist. Please create it first."
    exit 1
}

# Get the repository URI
$RepoUri = (aws ecr-public describe-repositories --repository-names $RepositoryName --region $Region --query 'repositories[0].repositoryUri' --output text)
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to get repository URI"
    exit 1
}
Write-Host "  Repository exists: $RepoUri" -ForegroundColor Green

$ImageUri = "${RepoUri}:${ImageTag}"

# Authenticate Docker to ECR Public
Write-Host "`n→ Authenticating Docker to ECR Public..." -ForegroundColor Yellow
aws ecr-public get-login-password --region $Region | docker login --username AWS --password-stdin $EcrUri
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to authenticate Docker to ECR Public"
    exit 1
}
Write-Host "  Authentication successful" -ForegroundColor Green

# Build Docker image
Write-Host "`n→ Building Docker image..." -ForegroundColor Yellow
docker build -t $RepositoryName`:$ImageTag -f DOCKERFILE .
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to build Docker image"
    exit 1
}
Write-Host "  Build successful" -ForegroundColor Green

# Tag image for ECR
Write-Host "`n→ Tagging image for ECR..." -ForegroundColor Yellow
docker tag $RepositoryName`:$ImageTag $ImageUri
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to tag Docker image"
    exit 1
}
Write-Host "  Tag successful" -ForegroundColor Green

# Push image to ECR
Write-Host "`n→ Pushing image to ECR..." -ForegroundColor Yellow
docker push $ImageUri
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to push Docker image to ECR"
    exit 1
}
Write-Host "  Push successful" -ForegroundColor Green

Write-Host "`n✓ Image successfully built and pushed to ECR" -ForegroundColor Green
Write-Host "  Image URI: $ImageUri" -ForegroundColor Cyan
Write-Host "`nTo use this image in Spacelift, set:" -ForegroundColor Yellow
Write-Host "  runner_image: $ImageUri" -ForegroundColor White
