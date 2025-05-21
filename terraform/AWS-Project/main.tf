variable "ami_id" {
  type    = string
  default = "ami-084568db4383264d4"
}

variable "key_name" {
  type    = string
  default = "project"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "sub1_cidr" {
  type    = string
  default = "192.168.0.0/24"
}

variable "sub2_cidr" {
  type    = string
  default = "192.168.1.0/24"
}

variable "availability_zone1" {
  type    = string
  default = "us-east-1a"
}

variable "availability_zone2" {
  type    = string
  default = "us-east-1b"
}

resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.sub1_cidr
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.sub2_cidr
  availability_zone       = var.availability_zone2
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
  }
}

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
}

resource "aws_route_table_association" "RTassociation1" {
  route_table_id = aws_route_table.publicrt.id
  subnet_id      = aws_subnet.sub1.id
}

resource "aws_route_table_association" "RTassociation2" {
  route_table_id = aws_route_table.publicrt.id
  subnet_id      = aws_subnet.sub2.id
}

resource "aws_security_group" "wesg" {
  vpc_id = aws_vpc.myvpc.id

  dynamic "ingress" {
    for_each = [22, 80]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "websg"
  }
}

resource "aws_s3_bucket" "mys3" {
  bucket = "vickeyss123"
}

resource "aws_instance" "web1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.wesg.id]
  subnet_id              = aws_subnet.sub1.id
  user_data              = file("userdata1.sh")
}

resource "aws_instance" "web2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.wesg.id]
  subnet_id              = aws_subnet.sub2.id
  user_data              = file("userdata2.sh")
}

resource "aws_lb" "mylb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.wesg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "mylb"
  }
}

resource "aws_lb_target_group" "mytg" {
  name     = "mytg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "mytgattach1" {
  target_group_arn = aws_lb_target_group.mytg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "mytgattach2" {
  target_group_arn = aws_lb_target_group.mytg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

resource "aws_lb_listener" "mylistener" {
  load_balancer_arn = aws_lb.mylb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.mytg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.mylb.dns_name
}
