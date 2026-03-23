
data "aws_subnet" "name" {
  filter {
    name   = "tag:Name"
    values = ["dev"]
  }
}




data "aws_ami" "amzlinux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "name" {
  ami           = data.aws_ami.amzlinux.id   # fixed
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.name.id
}