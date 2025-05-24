provider "aws" {
    region = "us-east-1"
  
}
data "aws_ami" "ubami"{
    most_recent = true
    owners = ["099720109477"] 
    filter {
      name = "name"
      values = [ var.ubdescribe ]
    }
}
output "ubamivalue" {
    value = data.aws_ami.ubami.id
}
resource "aws_instance" "web" {
    ami = data.aws_ami.ubami.id
    instance_type = "t2.micro"
    key_name = "project"
    tags = {
        name = "ubuntu_instance"
    
    }
}
data "aws_instance" "ids"{
   
    filter {
      name = "tag:name"
      values = ["ubuntu_instance"]
    }
    
}
output "instance_id"{
    value = data.aws_instance.ids.id
}
output "instance_ip" {
    value = data.aws_instance.ids.public_ip
}
data "aws_vpc" "vpc_id"{
    filter {
        name = "tag:name"
        values = ["default"]
    }
}
output "vpc_check" {
  value = data.aws_vpc.vpc_id.id
}
resource "aws_subnet" "sub1" {
    vpc_id = data.aws_vpc.vpc_id.id
    cidr_block = "172.32.0.0/24"
    availability_zone = "us-east-1a"
  
}