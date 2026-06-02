terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "http" "operator_ip" {
  count = var.operator_public_ip_cidr == "" ? 1 : 0
  url   = "https://ifconfig.me/ip"
}

locals {
  operator_cidr = var.operator_public_ip_cidr != "" ? var.operator_public_ip_cidr : "${chomp(data.http.operator_ip[0].response_body)}/32"
  sip_cidr      = var.sip_allowed_cidr != "" ? var.sip_allowed_cidr : local.operator_cidr
  web_cidr      = var.web_allowed_cidr != "" ? var.web_allowed_cidr : local.operator_cidr
}

data "aws_ami" "linux" {
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "pbx" {
  name        = "${var.project_name}-sg"
  description = "Security group for Issabel PBX lab"

  ingress {
    description = "SSH from operator"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.operator_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.web_cidr]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.web_cidr]
  }

  ingress {
    description = "SIP UDP"
    from_port   = 5060
    to_port     = 5060
    protocol    = "udp"
    cidr_blocks = [local.sip_cidr]
  }

  ingress {
    description = "SIP TCP"
    from_port   = 5060
    to_port     = 5060
    protocol    = "tcp"
    cidr_blocks = [local.sip_cidr]
  }

  ingress {
    description = "RTP media"
    from_port   = var.rtp_start_port
    to_port     = var.rtp_end_port
    protocol    = "udp"
    cidr_blocks = [local.sip_cidr]
  }

  ingress {
    description = "WireGuard"
    from_port   = var.wireguard_port
    to_port     = var.wireguard_port
    protocol    = "udp"
    cidr_blocks = [local.operator_cidr]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [local.operator_cidr]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [local.operator_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

resource "aws_instance" "pbx" {
  ami                         = var.ami_id != "" ? var.ami_id : data.aws_ami.linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.pbx.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = var.root_volume_size_gb
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/cloud-init.yaml", {
    swap_size_gb = var.swap_size_gb
  })

  tags = {
    Name    = "${var.project_name}-aws"
    Project = var.project_name
  }
}
