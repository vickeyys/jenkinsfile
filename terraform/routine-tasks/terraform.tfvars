ami_id = "ami-084568db4383264d4"
instance_type = "t2.micro"
key_name = "project"
vpc_cidr = "192.168.0.0/16"
subnet_cidr = "192.168.0.0/24"
ec2_tags = {
  "name" = "webserver"
}
vpc_tags = {
  "name" = "myvpc"
}
subnet_tags = {
  "name" = "publicsubnet"
}
route_table_tags = {
  "name" = "public_rt"
}
igw_tags = {
  "name" = "myigw"
}
security_group_tags = {
  "name" = "websg"
}

