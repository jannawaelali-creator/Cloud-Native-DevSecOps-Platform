module "network" {
    source= "/home/janna/terrlab1/terraform/network"
    subnet_map=var.subnet_map
    vpc_cidr=var.vpc_cidr

}

module "eks" {
    source= "./modules/EKS"
    cluster_name=var.cluster_name
    private_subnet_ids=module.network.private_subnet_ids
    vpc_id=module.network.vpc_id
    node_groups=var.node_groups
    
}

