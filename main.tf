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



data "aws_ami" "ami" {
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
  count         = var.aws_ec2_instance_count
  ami           = data.aws_ami.ami.id
  instance_type = var.aws_ec2_instance_type
  key_name      = var.aws_ec2_key_name

  tags = {
    "Name" = "${var.aws_ec2_tag_name}-${count.index}",
  }
}
