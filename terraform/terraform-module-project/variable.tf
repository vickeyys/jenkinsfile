variable "root_ami_id"{
    type = string
    default = "ami-084568db4383264d4"
}
variable "root_key_name" {
    type = string
    default = "project"
}
variable "root_instance_type"{
    type = string
    default = "t2.micro"
}
variable "root_vpc_cidr" {
    type = string
    default = "192.168.0.0/16"
}
variable "root_subnet_cidr" {
    type = string
    default = "192.168.0.0/24"
}
variable "root_ec2_tags" {
    type = map(string)
    default = {
      "name" = "webserver"
    }
}
variable "root_vpc_tags" {
    type = map(string)
    default = {
      "name" = "myvpc"
    }
}
              
