resource "aws_iam_role" "eks_cluster_role" {

name = "${var.cluster_name}-cluster-role"
assume_role_policy = jsonencode({

Version="2012-10-17"

Statement=[{

Effect="Allow"

Principal={
 Service="eks.amazonaws.com"
}

Action="sts:AssumeRole"}]

})

}




resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {

role = aws_iam_role.eks_cluster_role.name
policy_arn ="arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

}


resource "aws_eks_cluster" "cluster" {
name = var.cluster_name
role_arn = aws_iam_role.eks_cluster_role.arn

vpc_config {
subnet_ids = var.private_subnet_ids
 endpoint_private_access = true
 endpoint_public_access = true
}


depends_on=[
aws_iam_role_policy_attachment.eks_cluster_policy
]

}

resource "aws_iam_role" "node_role" {

name="${var.cluster_name}-node-role"
assume_role_policy=jsonencode({

Version="2012-10-17"
Statement=[{
Effect="Allow"
Principal={
Service="ec2.amazonaws.com"
}
Action="sts:AssumeRole" }]

})

}


resource "aws_iam_role_policy_attachment" "node_worker" {


role = aws_iam_role.node_role.name
for_each = toset([

"arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
"arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
"arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

])

policy_arn = each.value


}


resource "aws_eks_node_group" "main" {
 for_each = var.node_groups

 cluster_name = aws_eks_cluster.cluster.name
  node_group_name = each.key
 node_role_arn = aws_iam_role.node_role.arn
 subnet_ids = var.private_subnet_ids

 instance_types = each.value.instance_types
capacity_type = each.value.capacity_type

scaling_config {
  desired_size =  each.value.scaling_config.desired_size
  max_size = each.value.scaling_config.max_size
  min_size = each.value.scaling_config.min_size
}

depends_on = [ aws_iam_role_policy_attachment.node_worker ]

}

