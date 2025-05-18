variable "ami_id"{
    type = string
}
variable "instance_type"{
    type = string
}
variable "subnet_id"{
}
variable "key_name"{
    type = string
}
variable "ec2_tags" {
    type = map(string)
    default = {}
}

