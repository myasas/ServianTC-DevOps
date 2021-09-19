resource "tls_private_key" "alb_ing_ssl" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "alb_ing_ssl" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.alb_ing_ssl.private_key_pem

  subject {
    common_name  = var.cert_dns_name
    organization = var.cert_org_name
  }

  validity_period_hours = 8784

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "alb_ing_ssl_cert" {
  private_key      = tls_private_key.alb_ing_ssl.private_key_pem
  certificate_body = tls_self_signed_cert.alb_ing_ssl.cert_pem
}