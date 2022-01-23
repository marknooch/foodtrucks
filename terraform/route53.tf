resource "aws_route53_zone" "main" {
  name = var.domain-name
}

# comment out so we can get the zone and configure name records in freenom before getting the rest of this stuff setup
# resource "aws_route53_record" "root-a" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = var.domain-name
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.root_s3_distribution.domainvar.domain-name
#     zone_id                = aws_cloudfront_distribution.root_s3_distribution.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

# resource "aws_route53_record" "www-a" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "www.${var.domain-name}"
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.www_s3_distribution.domainvar.domain-name
#     zone_id                = aws_cloudfront_distribution.www_s3_distribution.hosted_zone_id
#     evaluate_target_health = false
#   }
# }
