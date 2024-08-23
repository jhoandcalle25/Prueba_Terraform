# CloudFront

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_lb.alb.dns_name
    origin_id   = "app-lb"
      }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "app-lb"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  restrictions {
    geo_restriction {
        restriction_type = "whitelist"
        locations = ["CA","DE"]
    }
    
  }
}

# Route 53

resource "aws_route53_zone" "primary" {
  name = "jfc.com"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

#  WAF
resource "aws_waf_web_acl" "waf" {
  name        = "app-waf"
  metric_name = "appWAF"

  default_action {
    type = "ALLOW"
  }

  rules {
    action {
      type = "BLOCK"
    }
    priority = 1
    rule_id  = aws_waf_rule.sql_injection.id
  }
}

resource "aws_waf_rule" "sql_injection" {
  name        = "SQLInjectionRule"
  metric_name = "SQLInjection"

  predicates {
    data_id = aws_waf_sql_injection_match_set.sql_injection.id
    negated = false
    type    = "SqlInjectionMatch"
  }
}

resource "aws_waf_sql_injection_match_set" "sql_injection" {
  name = "SQLInjectionMatchSet"

  sql_injection_match_tuples {
    field_to_match {
      type = "QUERY_STRING"
    }
    text_transformation = "URL_DECODE"
  }
}

resource "aws_wafv2_web_acl_association" "waf_association" {
    resource_arn = aws_cloudfront_distribution.cdn.arn
    web_acl_arn = aws_waf_web_acl.waf.arn
  
}

# AWS Shield 


resource "aws_secretsmanager_secret" "app_secret" {
  name = "app-secret"
}

resource "aws_secretsmanager_secret_version" "app_secret_version" {
  secret_id     = aws_secretsmanager_secret.app_secret.id
  secret_string = "{\"username\":\"admin\",\"password\":\"SuperSecretPassword\"}"
}