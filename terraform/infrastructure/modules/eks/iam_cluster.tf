data "aws_iam_policy_document" "cluster_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "eks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "cluster_role" {
  name               = "${var.short_name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_policy_document.json

  tags = merge(var.default_tags, {})
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
