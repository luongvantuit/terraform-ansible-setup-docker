provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_instance" "instance" {
  count = var.aws_ec2_instance_count
}
