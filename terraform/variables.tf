variable "vpc_cidr" {
  type    = string
  
}

variable "subnet_map"{
    type=list(object ( {
        name=string,
        cidr=string,
        type=string,
        az=string


    }))

}


variable "region" {
  type    = string
  
}

variable "cluster_name" {
  type = string
}

variable "node_groups" {
  type = map(object({
    instance_types = list(string)
    capacity_type  = string

    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
  }))
}


