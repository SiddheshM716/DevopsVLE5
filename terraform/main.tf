provider "aws" {
  region = "us-east-1"
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnet (first one)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group allowing SSH
resource "aws_security_group" "sg" {
  name   = "devops-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
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

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "devops_server" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  key_name                    = "devops-key"
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true

  subnet_id = data.aws_subnets.default.ids[0]

  tags = {
    Name = "DevOps-Lab-Server"
  }
}