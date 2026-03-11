resource "aws_vpc" "name" { 
    cidr_block = "10.0.0.0/24"
    tags = {
      Name = "gokul-vpc"
    }
  # this ec2 i have created in this vpc
} 
resource "aws_instance" "myserver" {
    ami           = "ami-02dfbd4ff395f2a1b"
    instance_type = "t3.micro"
    tags = {
      Name = "gokul-ec2"
    }
}
# this is stoped state fileresource
resource "aws_ec2_instance_state" "stop_instance" {
  instance_id = aws_instance.myserver.id
               # stopped
  state       = "running"
  
  depends_on = [aws_instance.myserver]
} 


