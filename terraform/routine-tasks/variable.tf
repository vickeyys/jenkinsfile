variable "ami_id" {
    type = string
}
variable "instance_type" {
    type = string

}
variable "vpc_cidr" {
  type = string
}
variable "subnet_cidr" {
  type = string
}
variable "key_name" {
  type = string
}
variable "ec2_tags" {
  type = map(string)
  default = {}
}
variable "vpc_tags" {
  type = map(string)
  default = {}
}
variable "subnet_tags"{
  type = map(string)
  default = {}
}
variable "security_group_tags" {
  type = map(string)
  default = {}
}
variable "igw_tags" {
  type = map(string)
  default = {}
}
variable "route_table_tags" {
  type = map(string)
  default = {}
}

