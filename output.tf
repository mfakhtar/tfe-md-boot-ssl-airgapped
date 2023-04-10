output "ssh_public_ip" {
  description = "Command for ssh to the Client public IP of the EC2 Instance"
  value = [
    "ssh ubuntu@${aws_eip.bar.public_dns} -i ${var.unique_name}.pem"
  ]
}


output "replicated-ui" {
  value = "https://${aws_route53_record.www.name}:8800/"
}

output "tfe-ui" {
  value = "https://${aws_route53_record.www.name}/"
}