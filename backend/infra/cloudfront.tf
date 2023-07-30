# certificate for main bucket cloudfront distribution
resource "aws_acm_certificate" "main_cert" {
  domain_name       = "forevertechstudent.com"
  subject_alternative_names = ["www.forevertechstudent.com"]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "main_cert" {
  certificate_arn         = aws_acm_certificate.main_cert.arn
  validation_record_fqdns = aws_route53_record.main_cert_validation_record.*.fqdn
}

# cloudfront distribution for main bucket
resource "aws_cloudfront_distribution" "fts_distr" {
  enabled = true
  is_ipv6_enabled = true
  aliases = ["forevertechstudent.com"]
  
  
  origin {
    domain_name = aws_s3_bucket_website_configuration.fts.website_endpoint
    origin_id   = aws_s3_bucket_website_configuration.fts.website_endpoint
    connection_attempts = 3
    connection_timeout = 10
   
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy = "http-only"
      origin_read_timeout = 30
      origin_ssl_protocols = ["TLSv1","TLSv1.1","TLSv1.2"]
    }                      
  } 

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress = true
    target_origin_id = "forevertechstudent.com.s3-website-us-east-1.amazonaws.com"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 00
    max_ttl = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations = []
    }
  }

  viewer_certificate {    
    acm_certificate_arn = aws_acm_certificate.main_cert.arn
    cloudfront_default_certificate = false
    iam_certificate_id = ""
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method = "sni-only"
  } 
}


# certificate for www bucket cloudfront distribution
# resource "aws_acm_certificate" "www_cert" {
#   domain_name       = "www.forevertechstudent.com"
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate_validation" "www_cert" {
#   certificate_arn         = aws_acm_certificate.www_cert.arn
#   validation_record_fqdns = [aws_route53_record.www_cert_validation_record.fqdn]
# }

# cloudfront distribution for www bucket
resource "aws_cloudfront_distribution" "fts_distr-www" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.fts-www.website_endpoint
    origin_id   = aws_s3_bucket_website_configuration.fts-www.website_endpoint
    connection_attempts = 3
    connection_timeout = 10

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy = "http-only"
      origin_read_timeout = 30
      origin_ssl_protocols = ["TLSv1","TLSv1.1","TLSv1.2"]
    } 
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = ""
  aliases = ["www.forevertechstudent.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress = true
    target_origin_id = "www.forevertechstudent.com.s3-website-us-east-1.amazonaws.com"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 00
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {    
    acm_certificate_arn = aws_acm_certificate.main_cert.arn
    cloudfront_default_certificate = false
    iam_certificate_id = ""
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method = "sni-only"
  }
}
