resource "aws_eks_cluster" "my_cluster" {
  name     = var.short_name
  role_arn = aws_iam_role.cluster_role.arn
  version  = var.eks_version

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    security_group_ids = [var.security_group_eks_cluster_id]
    subnet_ids         = concat(var.vpc_subnet_public_ids, var.vpc_subnet_private_ids)

    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]

  tags = merge(var.default_tags, {
    "Name" = "${var.short_name}-cluster"
  })
}

resource "aws_security_group_rule" "eks_front_ingress_all" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = var.security_group_front_id

  security_group_id = aws_eks_cluster.my_cluster.vpc_config[0].cluster_security_group_id

  description = "Auto assigned by code."
}
