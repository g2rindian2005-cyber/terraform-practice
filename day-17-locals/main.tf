locals {
  instance_id = "t2.micro"
  ami_id = ""
}

resource "aw_instance" "name" {
  ami = local.ami_id
  instance_type = local.instance_type
}