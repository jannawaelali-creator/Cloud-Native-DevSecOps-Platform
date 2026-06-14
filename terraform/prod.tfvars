region= "us-east-1"
vpc_cidr= "10.0.0.0/16"

subnet_map=[
{  name="public_subnet_1"
   cidr= "10.0.5.0/24"
   type= "public"
    az= "us-east-1a"

},
{
 name="public_subnet_2"
   cidr= "10.0.2.0/24"
   type= "public"
    az= "us-east-1b"
},
{
  name="private_subnet_1"
   cidr= "10.0.3.0/24"
   type= "private"
    az= "us-east-1a"
},

{
   name="private_subnet_2"
   cidr= "10.0.4.0/24"
   type= "private"
    az= "us-east-1b"
}
]

cluster_name = "my-eks-cluster"

node_groups = {
  general = {
    instance_types = ["t3.small"]
    capacity_type   = "ON_DEMAND"

    scaling_config = {
      desired_size = 2
      max_size     = 3
      min_size     = 1
    }
  }

  spot = {
    instance_types = ["t3.small"]
    capacity_type   = "SPOT"

    scaling_config = {
      desired_size = 1
      max_size     = 2
      min_size     = 1
    }
  }
}