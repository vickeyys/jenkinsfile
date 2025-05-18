module "ec2"{
    source = "./modules/ec2"
    ami_id = var.root_ami_id
    instance_type = var.root_instance_type
    key_name = var.root_key_name
    subnet_id = module.vpc.web_subnet_id
    ec2_tags = var.root_ec2_tags
}
module "vpc"{
    source  =   "./modules/vpc"
    vpc_cidr = var.root_vpc_cidr
    subnet_cidr = var.root_subnet_cidr
    vpc_tags    =   var.root_vpc_tags
    subnet_tags =   var.root_subnet_tags
}

