provider "aws" {
  
}


resource "aws_instance" "name" {
  ami           = "ami-0c3389a4fa5bddaad"   # dummy bhi chalega
  instance_type = "t3.micro"
  tags = {
    Name = "gokul"
  }
}
   # command this line for adding in state file 
 #terraform import aws_instance.name i-062e246fc44ad4953