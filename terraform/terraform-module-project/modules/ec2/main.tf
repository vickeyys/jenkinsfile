resource "aws_instance" "webserver" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  tags = var.ec2_tags
}

