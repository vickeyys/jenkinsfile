provider "aws" {
  region = "us-east-1"
}

# 1. Get VPC by name tag
data "aws_vpc" "myvpc" {
  filter {
    name   = "tag:Name"
    values = ["myvpc"]
  }
}

# 2. Get public subnet(s)
data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["public"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.myvpc.id]
  }
}

# 3. Get private subnet(s)
data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["private"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.myvpc.id]
  }
}

# 4. Security group in myvpc
data "aws_security_group" "app_sg" {
  filter {
    name   = "group-name"
    values = ["my-sg"] # your SG name
  }
  vpc_id = data.aws_vpc.myvpc.id
}

# 5a. EC2 in Public subnet (pick 1st public subnet)
resource "aws_instance" "public_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  subnet_id              = data.aws_subnets.public.ids[0]
  vpc_security_group_ids = [data.aws_security_group.app_sg.id]

  associate_public_ip_address = true

  tags = {
    Name = "EC2-in-Public"
  }
}

# 5b. EC2 in Private subnet (pick 1st private subnet)
resource "aws_instance" "private_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  subnet_id              = data.aws_subnets.private.ids[0]
  vpc_security_group_ids = [data.aws_security_group.app_sg.id]

  associate_public_ip_address = false

tags = {
    Name = "EC2-in-Private"
  }
}
