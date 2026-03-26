provider "aws" {
  
}



# security sg
resource "aws_security_group" "gokul" {
  name        = "gokul"
  description = "allow TLS inbound traffic"


  #"allowed_ports ke har item ke liye rule bana"
  dynamic "ingress" {
    for_each = var.allowed_ports

    content {
      description = "Allow access to port ${ingress.key}"
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }
# Server bahar sab jagah connect kar sakta hai
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




variable "allowed_ports" {
  type = map(string)
  default = {
    #key =value 
     22 = "203.0.113.0/24"
     80 = "0.0.0.0/0"
     443 =  "0.0.0.0/0"
     8080 = "10.0.0.0/16"
     9000 = "192.168.1.0/24"
     3389  = "10.0.1.0/24"
     3000  = "10.0.2.0/24"

       }


     }
