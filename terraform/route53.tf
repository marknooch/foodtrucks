resource "aws_route53_zone" "main" {
  name = var.domain-name
}

resource "aws_route53_record" "ssl-cert-validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl-certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

# resource "aws_route53_record" "root-a" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = var.domain-name
#   type    = "A"

#   # comment out   
#   #   alias {
#   #     name                   = aws_cloudfront_distribution.root_s3_distribution.domainvar.domain-name
#   #     zone_id                = aws_cloudfront_distribution.root_s3_distribution.hosted_zone_id
#   #     evaluate_target_health = false
#   #   }
# }

# resource "aws_route53_record" "www-a" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "www.${var.domain-name}"
#   type    = "A"

#   #   alias {
#   #     name                   = aws_cloudfront_distribution.www_s3_distribution.domainvar.domain-name
#   #     zone_id                = aws_cloudfront_distribution.www_s3_distribution.hosted_zone_id
#   #     evaluate_target_health = false
#   #   }
# }
