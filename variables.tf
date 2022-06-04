variable "aws_ec2_instance_count" {
  type        = number
  default     = 1
  description = "Is quantity AWS EC2 instance"
}

variable "aws_ec2_instance_type" {
  type        = string
  default     = "c6g.medium"
  description = "Is instance type AWS EC2 instance"
}

variable "aws_ec2_tag_name" {
  type        = string
  default     = "EC2 instance"
  description = "Is tag name EC2 instance"
}

variable "aws_ami_owners" {
  type    = list(string)
  default = ["099720109477"]
}
