data "aws_iam_policy_document" "fargate_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "eks-fargate-pods.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "fargate_role" {
  name               = "${var.short_name}-eks-fargate-role"
  assume_role_policy = data.aws_iam_policy_document.fargate_policy_document.json

  tags = merge(var.default_tags, {})
}

resource "aws_iam_role_policy_attachment" "fargate_AmazonEKSFargatePodExecutionRolePolicy" {
  role       = aws_iam_role.fargate_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}
