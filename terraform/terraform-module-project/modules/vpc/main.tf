resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr
  tags = var.vpc_tags
}
resource "aws_subnet" "websubnet"{
    cidr_block = var.subnet_cidr
    vpc_id = aws_vpc.myvpc.id
    tags = var.subnet_tags
}
~
~

