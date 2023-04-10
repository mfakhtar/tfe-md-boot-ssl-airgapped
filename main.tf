#Add Provider Block
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.5.3"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "acme" {
  # server_url = "https://acme-staging-v02.api.letsencrypt.org/directory" # Untrusted certificates but unlimited to create
  server_url = "https://acme-v02.api.letsencrypt.org/directory" # Valid DNS record. Limited to 5 a week to create
}


#Add EC2 Block
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

resource "aws_instance" "guide-tfe-md" {
  ami                    = "ami-0f8ca728008ff5af4"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.guide-tfe-es-sg.id]
  key_name               = aws_key_pair.ssh_key_pair.key_name

  root_block_device {
    volume_size = "50"
  }

  user_data = templatefile("${path.module}/user-data.sh", {
    tfe-pwd              = var.tfe-pwd
    tfe_release_sequence = var.tfe_release_sequence
    dns_hostname         = var.dns_hostname
    dns_zonename         = var.dns_zonename
    bucket_name          = var.bucket_name
  })

  iam_instance_profile = aws_iam_instance_profile.guide-tfe-es-inst.id
  tags = {
    Name = var.unique_name
  }
  depends_on = [
    aws_key_pair.ssh_key_pair, aws_s3_object.certificate_artifacts_s3_objects , aws_s3_object.file_upload-airgapped
  ]

}

/*
resource "null_resource" "ssh_connection" {
  provisioner "file" {
    source      = "./license.rli"
    destination = "/tmp/license.rli"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local_file.foo.filename)
      host        = aws_instance.guide-tfe-md.public_ip
    }
  }
  provisioner "file" {
    source      = "./cert.pem"
    destination = "/tmp/cert.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local_file.foo.filename)
      host        = aws_instance.guide-tfe-md.public_ip
    }
  }
  provisioner "file" {
    source      = "./key.pem"
    destination = "/tmp/key.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local_file.foo.filename)
      host        = aws_instance.guide-tfe-md.public_ip
    }
  }

  provisioner "file" {
    source      = "./issuer.pem"
    destination = "/tmp/issuer.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local_file.foo.filename)
      host        = aws_instance.guide-tfe-md.public_ip
    }
  }

  depends_on = [
    aws_eip.bar , local_file.cert , local_file.key , local_file.issuer
  ]
}
*/


