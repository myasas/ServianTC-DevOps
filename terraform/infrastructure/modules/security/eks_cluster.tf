resource "aws_security_group" "eks_cluster" {
  name   = "${var.short_name}-eks-cluster-sg"
  vpc_id = var.vpc_id

  tags = merge(var.default_tags, {
    Name = "${var.short_name}-eks-cluster-sg"
  })

  description = "Auto assigned by code."
}

resource "aws_security_group_rule" "eks_cluster_ingress_443" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id

  security_group_id = aws_security_group.eks_cluster.id

  description = "Auto assigned by code."
}
