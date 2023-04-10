data "aws_route53_zone" "base_domain" {
  name = var.dns_zonename
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.base_domain.zone_id
  name    = var.dns_hostname
  type    = "A"
  ttl     = "300"
  records = [aws_eip.bar.public_ip]
}