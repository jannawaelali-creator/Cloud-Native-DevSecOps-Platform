output "cluster_name" {
  value = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}


output "cluster_id" {
  value = aws_eks_cluster.cluster.id
}


output "node_group_names" {
  value = [for ng in aws_eks_node_group.main : ng.node_group_name]
}

output "node_group_arns" {
  value = [for ng in aws_eks_node_group.main : ng.arn]
}


output "node_role_arn" {
  value = aws_iam_role.node_role.arn
}

