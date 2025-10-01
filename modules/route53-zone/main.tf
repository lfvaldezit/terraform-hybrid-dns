resource "aws_route53_zone" "this" {
  name = var.domain_name
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "this" {
  zone_id = aws_route53_zone.this.id
  name    = var.record_name
  type    = "A"
  ttl     = 300
  records = var.record_value
}