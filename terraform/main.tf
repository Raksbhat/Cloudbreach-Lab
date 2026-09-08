terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_vpc" "lab" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "cloudbreach-lab-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "cloudbreach-lab-public-subnet"
  }
}

resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "cloudbreach-lab-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "cloudbreach-lab-public-rt"
  }
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "13.48.85.149/32"
  gateway_id             = aws_internet_gateway.lab.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "open_ssh" {
  name        = "cloudbreach-lab-open-ssh"
  description = "Intentionally vulnerable SSH access"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["13.48.85.149/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["13.48.85.149/32"]
  }

  tags = {
    Name = "cloudbreach-lab-open-ssh"
  }
}

resource "aws_instance" "lab" {
  ami           = "ami-01d5faff4584de9de"
  instance_type = "t3.micro"
  key_name      = "cloudbreach-lab-key"
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.open_ssh.id
  ]

  associate_public_ip_address = true

  tags = {
    Name = "cloudbreach-lab-ec2"
  }
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/cloudbreach-lab/vpc-flow-logs"
  retention_in_days = 7
}

resource "aws_iam_role" "vpc_flow_logs" {
  name = "cloudbreach-lab-vpc-flow-logs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_flow_log" "lab" {
  vpc_id          = aws_vpc.lab.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn

  tags = {
    Name = "cloudbreach-lab-vpc-flow-logs"
  }
}
