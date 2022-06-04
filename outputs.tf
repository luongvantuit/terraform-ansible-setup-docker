output "ec2_public_ip" {
  value = {
    for k, v in aws_instance.instance : k => v.public_ip
  }
}
