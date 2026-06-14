variable "cluster_name" {

type=string

}


variable "private_subnet_ids" {

type=list(string)

}


variable "vpc_id" {

type=string

}


variable "node_groups" {

type = map(object({

instance_types=list(string)

capacity_type=string


scaling_config=object({

desired_size=number

max_size=number

min_size=number

})


}))

}