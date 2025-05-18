output "instance_info" {
  value = [aws_instance.webserver.public_ip, aws_instance.webserver.id]
}


