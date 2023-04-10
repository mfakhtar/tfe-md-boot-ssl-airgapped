# Generate the SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload the public key to AWS
resource "aws_key_pair" "ssh_key_pair" {
  key_name   = var.unique_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "foo" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${var.unique_name}.pem"
  file_permission = "0400"
}
