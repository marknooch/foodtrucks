# SSL Certificate
resource "aws_acm_certificate" "ssl-certificate" {
  provider                  = aws.acm_provider
  domain_name               = var.domain-name
  subject_alternative_names = ["*.${var.domain-name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert-validation" {
  provider                = aws.acm_provider
  certificate_arn         = aws_acm_certificate.ssl-certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.ssl-cert-validation : record.fqdn]
}
