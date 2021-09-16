output "eks_cluster_name" {
  value = aws_eks_cluster.my_cluster.name
}

output "eks_fargate_profile_id" {
  value = aws_eks_fargate_profile.fargate_profile.id
}

output "eks_fargate_role_arn" {
  value = aws_iam_role.fargate_role.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.node_role.arn
}

output "eks_external_dns_role_arn" {
  value = aws_iam_role.external_dns_role.arn
}

output "eks_lb_controller_role_arn" {
  value = aws_iam_role.lb_controller_role.arn
}

output "eks_k8s_masters_role_arn" {
  value = aws_iam_role.masters_role.arn
}

output "eks_k8s_readonly_role_arn" {
  value = aws_iam_role.readonly_role.arn
}

output "security_group_cluster_id" {
  value = aws_eks_cluster.my_cluster.vpc_config[0].cluster_security_group_id
}
