data "aws_route53_zone" "fts" {
  name         = "forevertechstudent.com"
  private_zone = false
}

# https://stackoverflow.com/questions/59584443/why-error-alias-target-name-does-not-lie-within-the-target-zone-in-terraform
resource "aws_route53_record" "fts-a" {
  zone_id = data.aws_route53_zone.fts.zone_id
  name    = "forevertechstudent.com"
  type    = "A"
  allow_overwrite = true

  alias {
    name = aws_cloudfront_distribution.fts_distr.domain_name
    zone_id = aws_cloudfront_distribution.fts_distr.hosted_zone_id
    evaluate_target_health = false
  }
}

# https://stackoverflow.com/questions/59584443/why-error-alias-target-name-does-not-lie-within-the-target-zone-in-terraform
resource "aws_route53_record" "fts-www-a" {
  zone_id = data.aws_route53_zone.fts.zone_id
  name    = "www.forevertechstudent.com"
  type    = "A"
  allow_overwrite = true

  alias {
    name = aws_cloudfront_distribution.fts_distr-www.domain_name
    zone_id = aws_cloudfront_distribution.fts_distr.hosted_zone_id
    evaluate_target_health = false
  }
}

#https://stackoverflow.com/questions/57644466/missing-dns-validation-record-when-using-terraform-aws-acm-certificate-validatio

resource "aws_route53_record" "main_cert_validation_record" {
  count = length(var.alternative-names) + 1
  zone_id = data.aws_route53_zone.fts.zone_id
  name    = element(aws_acm_certificate.main_cert.domain_validation_options.*.resource_record_name, count.index)
  type    = element(aws_acm_certificate.main_cert.domain_validation_options.*.resource_record_type, count.index)
  records = [element(aws_acm_certificate.main_cert.domain_validation_options.*.resource_record_value, count.index)]
  ttl     = "300"
  allow_overwrite = true
}
