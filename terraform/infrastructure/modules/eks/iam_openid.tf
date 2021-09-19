data "tls_certificate" "my_cluster" {
  url = aws_eks_cluster.my_cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "my_cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = concat([data.tls_certificate.my_cluster.certificates.0.sha1_fingerprint])
  url             = aws_eks_cluster.my_cluster.identity.0.oidc.0.issuer
}
