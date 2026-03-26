resource "aws_instance" "name" {
  ami = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.micro"
  tags = {
    Name= "my-jawan-instance"
  }
  lifecycle {
    #if you use this line so 1will added and 1 exiteing will be destroy
  #create_before_destroy = true
  #   if you use this line not destroy 
     # if  you use  false it will destroy 

   prevent_destroy =  true
    

    # this is if someone changed manualy inside console so it will show but but whta you have  puted in  maint.tf 

   ignore_changes = [tags["nanan"]]

} 

} 


