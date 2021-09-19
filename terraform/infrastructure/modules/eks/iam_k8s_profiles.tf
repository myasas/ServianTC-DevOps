data "aws_iam_policy_document" "masters_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.eks_arn_user_list_with_masters_role
    }
  }
}

resource "aws_iam_role" "masters_role" {
  name               = "${var.short_name}-k8s-masters-role"
  assume_role_policy = data.aws_iam_policy_document.masters_policy_document.json

  tags = merge(var.default_tags, {})
}

data "aws_iam_policy_document" "readonly_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.eks_arn_user_list_with_readonly_role
    }
  }
}

resource "aws_iam_role" "readonly_role" {
  name               = "${var.short_name}-k8s-readonly-role"
  assume_role_policy = data.aws_iam_policy_document.readonly_policy_document.json

  tags = merge(var.default_tags, {})
}
