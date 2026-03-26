resource "aws_instance" "name" {
  ami = var.ami_id
  instance_type = var.instance_type
  for_each = toset(var.env)

  tags = {
    Name = each.key 
  }
} 


variable "ami_id" {
  description = "passing values to ami_id"
  default = ""
  type = string
} 

variable "instance_type" {
  description = "passing  values to instance_type"
   default = ""
   type = string 
}

variable "env" {
  description = "envirement name"
  default = ["dev1","prod1"]
  type = list(string)
}