
resource "aws_eip" "bar" {
  vpc = true

  instance                  = aws_instance.guide-tfe-md.id
  associate_with_private_ip = aws_instance.guide-tfe-md.private_ip

}