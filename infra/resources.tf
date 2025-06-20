resource "aws_acm_certificate" "certificate" {
  domain_name       = local.domain_name
  subject_alternative_names = [local.domain_name]
  validation_method = "DNS"

  provider = aws.us-east-1
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn = aws_acm_certificate.certificate.arn

  provider = aws.us-east-1
}

resource "aws_cloudfront_distribution" "distribution" {
  aliases = [local.domain_name]
  default_root_object = "index.html"
  enabled             = true
  price_class         = "PriceClass_200"

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = aws_s3_bucket.bucket.bucket
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.index-redirect.arn
    }
  }

  origin {
    domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = aws_s3_bucket.bucket.bucket
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.certificate.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_function" "index-redirect" {
  code = file("${path.module}/index-redirect.js")
  comment = "Redirects /path or /path/ to the /path/index.html"
  name    = "${local.project_id}-index-redirect"
  publish = true
  runtime = "cloudfront-js-2.0"
}


resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = aws_s3_bucket.bucket.bucket
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_route53domains_registered_domain" "domain" {
  domain_name = local.domain_name

  dynamic "name_server" {
    for_each = aws_route53_zone.hosted_zone.name_servers

    content {
      name = name_server.value
    }
  }
}

resource "aws_route53_record" "validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.hosted_zone.zone_id
}

resource "aws_route53_record" "hosted_zone_a_record" {
  name    = local.domain_name
  type    = "A"
  zone_id = aws_route53_zone.hosted_zone.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
  }
}

resource "aws_route53_zone" "hosted_zone" {
  name = local.domain_name
}

resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "${local.domain_name}-"
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.bucket.bucket
  policy = data.aws_iam_policy_document.bucket-policy-document.json
}

resource "aws_ssm_parameter" "bucket_name" {
  name  = "${local.ssm_path}/bucket-name"
  type  = "String"
  value = aws_s3_bucket.bucket.bucket
}

resource "aws_ssm_parameter" "acm_certificate_arn" {
  name  = "${local.ssm_path}/acm-certificate-arn"
  type  = "String"
  value = aws_acm_certificate.certificate.arn
}

resource "aws_ssm_parameter" "hosted_zone_name" {
  name  = "${local.ssm_path}/hosted-zone-name"
  type  = "String"
  value = aws_route53_zone.hosted_zone.name
}

resource "aws_ssm_parameter" "hosted_zone_id" {
  name  = "${local.ssm_path}/hosted-zone-id"
  type  = "String"
  value = aws_route53_zone.hosted_zone.zone_id
}
