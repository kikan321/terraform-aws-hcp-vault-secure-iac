# LEGACY MONOLITHIC CODE (ANTI-PATTERN EXAMPLE)
# This file represents the infrastructure before being refactored into modules.

provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAIOSFODNN7EXAMPLE" # CRITICAL BUG: Plain text credentials
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

# Everything is hardcoded in a single file
resource "aws_vpc" "bad_vpc" {
  cidr_block           = "10.0.0.0/16" # Hardcoded network range
  enable_dns_hostnames = true
}

resource "aws_subnet" "bad_subnet" {
  vpc_id                  = aws_vpc.bad_vpc.id
  cidr_block              = "10.0.1.0/24" # Hardcoded subnet range
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "bad_igw" {
  vpc_id = aws_vpc.bad_vpc.id
}

resource "aws_route_table" "bad_rt" {
  vpc_id = aws_vpc.bad_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bad_igw.id
  }
}

resource "aws_route_table_association" "bad_assoc" {
  subnet_id      = aws_subnet.bad_subnet.id
  route_table_id = aws_route_table.bad_rt.id
}

resource "aws_security_group" "bad_sg" {
  name   = "allow_http"
  vpc_id = aws_vpc.bad_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bad_ec2" {
  ami                    = "ami-0fc5d935ebf8bc3bc" # Hardcoded AMI (Will break if region changes)
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.bad_subnet.id
  vpc_security_group_ids = [aws_security_group.bad_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install nginx -y
              EOF
}
