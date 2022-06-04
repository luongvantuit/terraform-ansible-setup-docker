terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}


provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}



resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Security group of AWS EC2"
  tags = {
    "Name" = "Public Security Group"
    "Role" = "public"
  }
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "ansible_key"
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "local_sensitive_file" "local_sensitive_file_key_pem" {
  file_permission = "600"
  filename        = "${path.module}/ansible_key.pem"
  content         = tls_private_key.private_key.private_key_pem
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow SSH"
  from_port         = 22
  to_port           = 22
  ipv6_cidr_blocks  = ["::/0"]
  protocol          = "tcp"
  security_group_id = aws_security_group.public_sg.id
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow HTTP security group"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.public_sg.id
}


resource "aws_security_group_rule" "egress_allow" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_sg.id
}


data "aws_ami" "ami" { // AMI OS Ubuntu architecture ARM64
  owners      = var.aws_ami_owners
  most_recent = true

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }
}

resource "aws_instance" "instance" {
  count                  = var.aws_ec2_instance_count
  ami                    = data.aws_ami.ami.id
  instance_type          = var.aws_ec2_instance_type
  key_name               = aws_key_pair.key_pair.key_name
  security_groups        = ["${aws_security_group.public_sg.name}"]
  vpc_security_group_ids = ["${aws_security_group.public_sg.id}"]
  
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --key-file ansible_key.pem -T 300 -i '${self.public_ip},', playbook.yaml"
  }

  tags = {
    "Name" = "${var.aws_ec2_tag_name}-${count.index}",
  }
}
