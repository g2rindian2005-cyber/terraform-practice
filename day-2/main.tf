resource "aws_instance" "my-ec2" { 
    ami = var.ami_id
  instance_type = var.instance_type
    tags = {
    Name = "gokul-ec2"
  }
}