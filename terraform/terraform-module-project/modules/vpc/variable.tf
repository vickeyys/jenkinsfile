variable "vpc_cidr"{
    type = string
}
variable "subnet_cidr"{
    type = string
}
variable "vpc_tags" {
    type = map(string)
    default = {}
}
variable "subnet_tags" {
    type = map(string)
    default = {}
}

