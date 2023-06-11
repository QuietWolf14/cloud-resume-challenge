# fts hosted zone
resource "aws_route53_zone" "fts" {
  name = "forevertechstudent.com"
  comment = "zone for my portfolio website"
}

resource "aws_route53_record" "fts-ns" {
  zone_id = aws_route53_zone.fts.zone_id
  name    = "forevertechstudent.com"
  type    = "NS"
  ttl     = "172800"
  records = ["ns-1152.awsdns-16.org.",
             "ns-1820.awsdns-35.co.uk.",
             "ns-495.awsdns-61.com.",
             "ns-726.awsdns-26.net."]
}

resource "aws_route53_record" "fts-soa" {
  zone_id = aws_route53_zone.fts.zone_id
  name    = "forevertechstudent.com"
  type    = "SOA"
  ttl     = "900"
  records = ["ns-495.awsdns-61.com. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"]
}

resource "aws_route53_record" "fts-a" {
  zone_id = aws_route53_zone.fts.zone_id
  name    = "forevertechstudent.com"
  type    = "A"

  alias {
    name = aws_cloudfront_distribution.fts_distr.domain_name
    zone_id = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "fts-www-a" {
  zone_id = aws_route53_zone.fts.zone_id
  name    = "www.forevertechstudent.com"
  type    = "A"

  alias {
    name = aws_cloudfront_distribution.fts_distr-www.domain_name
    zone_id = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "fts-cname" {
  zone_id = aws_route53_zone.fts.zone_id
  name    = "_27f8ab11ad4f4cf6bf683a8e45d6638c.forevertechstudent.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["_39275f2c689ddac39e118a758316dd24.fpktwqqglf.acm-validations.aws."]
}

resource "aws_route53_record" "fts-www-cname" {
  zone_id = aws_route53_zone.fts.zone_id
  name    = "_e8221ec8537785ea58a35c508e9ad982.www.forevertechstudent.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["_93396072ed4e0563d47b114a250431f0.fpktwqqglf.acm-validations.aws."]
}
