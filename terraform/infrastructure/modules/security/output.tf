output "security_group_front_id" {
  value = aws_security_group.front.id
}

output "security_group_storage_id" {
  value = aws_security_group.storage.id
}

output "security_group_bastion_id" {
  value = aws_security_group.bastion.id
}

output "security_group_eks_cluster_id" {
  value = aws_security_group.eks_cluster.id
}

output "security_group_eks_nodes_id" {
  value = aws_security_group.eks_nodes.id
}
