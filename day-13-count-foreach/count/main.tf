resource "aws_instance" "dev" {
     ami = var.ami_id
     instance_type = var.instance_type
     
     count = length(var.env)
       tags = {
         Name = var.env[count.index]  #so here we are creating 2 instances with different name
  }

} 


    variable "ami_id" {
        description = "passing values to ami_id"
        default = ""
        type = string      
    } 

    variable "instance_type" {
      description = "passing values to instsnce_type"
      default = ""
      type = string 
    } 

      variable "env" {
    description = "envirement name "
    default = [ "dev","prod"] 
    type = list(string)
      #while remviing test server from this list prod deleted test renamed as a prod this is not recommanded 
      } 


      # resource "aws_instance" "dev" {
#     ami = var.ami_id
#     instance_type = var.instance_type
#     count = 2
# #     tags = {
# #         Name = "dev-instance"  #so here we are creating 2 instances with same name
# #     }
#      tags = {
#         Name = "dev-instance-${count.index}"  #so here we are creating 2 instances with different name
# }
# }
  
