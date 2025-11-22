# ECS Network Resources

resource "aws_vpc" "ecs" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-ecs-vpc"
  }
}

resource "aws_default_security_group" "ecs_default_block_all" {
  vpc_id                 = aws_vpc.ecs.id
  revoke_rules_on_delete = true

  ingress = []
  egress  = []

  tags = {
    Name = "${var.environment}-ecs-default-block-all"
  }
}

## Public Subnets

resource "aws_subnet" "ecs_public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.ecs.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = var.use_private_cidrs ? false : true
  availability_zone       = element(var.azs, count.index)

  tags = {
    Name = "${var.environment}-ecs-public-${element(var.azs, count.index)}"
  }
}

resource "aws_internet_gateway" "ecs" {
  vpc_id = aws_vpc.ecs.id

  tags = {
    Name = "${var.environment}-ecs-igw"
  }
}

resource "aws_route_table" "ecs_public" {
  vpc_id = aws_vpc.ecs.id

  tags = {
    Name = "${var.environment}-ecs-public-rt"
    Type = "public"
  }
}

resource "aws_route" "ecs_public_internet_access" {
  route_table_id         = aws_route_table.ecs_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ecs.id
}

resource "aws_route_table_association" "ecs_public" {
  count          = length(aws_subnet.ecs_public)
  subnet_id      = aws_subnet.ecs_public[count.index].id
  route_table_id = aws_route_table.ecs_public.id
}

## Private Subnets

resource "aws_subnet" "ecs_private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.ecs.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.environment}-ecs-private-${element(var.azs, count.index)}"
  }
}

resource "aws_nat_gateway" "ecs" {
  count         = var.use_private_cidrs ? 1 : 0
  allocation_id = aws_eip.ecs_nat[0].id
  subnet_id     = aws_subnet.ecs_public[0].id

  tags = {
    Name = "${var.environment}-ecs-nat"
  }
}

resource "aws_eip" "ecs_nat" {
  count = var.use_private_cidrs ? 1 : 0
  tags = {
    Name = "${var.environment}-ecs-nat-eip"
  }
}

resource "aws_route_table" "ecs_private" {
  vpc_id = aws_vpc.ecs.id

  tags = {
    Name = "${var.environment}-ecs-private-rt"
    Type = "private"
  }
}

resource "aws_route" "ecs_private_nat_access" {
  count                  = var.use_private_cidrs ? 1 : 0
  route_table_id         = aws_route_table.ecs_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ecs[0].id
}

resource "aws_route_table_association" "ecs_private" {
  count          = length(aws_subnet.ecs_private)
  subnet_id      = aws_subnet.ecs_private[count.index].id
  route_table_id = aws_route_table.ecs_private.id
}

# Network outputs

output "ecs_vpc_id" {
  description = "VPC ID for ECS cluster"
  value       = aws_vpc.ecs.id
}

output "ecs_public_subnet_ids" {
  description = "Public subnet IDs for ECS cluster"
  value       = aws_subnet.ecs_public[*].id
}

output "ecs_private_subnet_ids" {
  description = "Private subnet IDs for ECS cluster"
  value       = aws_subnet.ecs_private[*].id
}
