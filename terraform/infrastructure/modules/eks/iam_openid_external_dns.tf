data "aws_iam_policy_document" "external_dns_policy_document" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.my_cluster.arn]
    }

    condition {
      test = "StringEquals"
      values = [
        "system:serviceaccount:kube-system:external-dns"
      ]
      variable = "${replace(aws_iam_openid_connect_provider.my_cluster.url, "https://", "")}:sub"
    }

    condition {
      test = "StringEquals"
      values = [
        "sts.amazonaws.com"
      ]
      variable = "${replace(aws_iam_openid_connect_provider.my_cluster.url, "https://", "")}:aud"
    }
  }
}

resource "aws_iam_role" "external_dns_role" {
  name               = "${var.short_name}-eks-external-dns-role"
  assume_role_policy = data.aws_iam_policy_document.external_dns_policy_document.json

  tags = merge(var.default_tags, {})

  depends_on = [
    aws_iam_openid_connect_provider.my_cluster
  ]
}

resource "aws_iam_policy" "external_dns_policy" {
  name   = "${var.short_name}-eks-external-dns-policy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "external_dns_external_dns_policy" {
  role       = aws_iam_role.external_dns_role.name
  policy_arn = aws_iam_policy.external_dns_policy.arn

  depends_on = [
    aws_iam_role.external_dns_role,
    aws_iam_policy.external_dns_policy
  ]
}
