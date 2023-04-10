#Data is require to get AMI ID of Ubuntu
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami_ids

data "aws_ami" "ubuntu" {
  owners      = ["amazon"]
  most_recent = true
  name_regex  = "ubuntu"
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

#data is required for allowing ip address whitelist for 

