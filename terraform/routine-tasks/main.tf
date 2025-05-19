provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr
  tags       = var.vpc_tags
}

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = var.subnet_tags
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  tags   = var.igw_tags
}

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

  tags = var.route_table_tags
}

resource "aws_route_table_association" "publicrtassociation" {
  route_table_id = aws_route_table.publicrt.id
  subnet_id      = aws_subnet.public-subnet.id
}

resource "aws_security_group" "websg" {
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.security_group_tags
}

resource "aws_instance" "webserver" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public-subnet.id
  vpc_security_group_ids      = [aws_security_group.websg.id]
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/project.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "/root/app.py"
    destination = "/home/ubuntu/app.py"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",
      "sudo apt-get install -y python3-pip",
      "cd /home/ubuntu",
      "sudo pip3 install flask",
      "nohup sudo python3 app.py > /home/ubuntu/app.log 2>&1 &"
    ]
  }

  tags = {
    Name = "FlaskWebServer"
  }
}
output "webserver_public_ip" {
  description = "The public IP of the webserver instance"
  value       = aws_instance.webserver.public_ip
}

output "webserver_url" {
  description = "The URL to access the webserver on port 80"
  value       = "http://${aws_instance.webserver.public_ip}:80"
}

