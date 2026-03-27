resource "aws_instance" "name" {
  ami           = "ami-02dfbd4ff395f2a1b" 
  instance_type = "t2.micro"

    tags = {
        Name = "gokul_instance"
    }

} 
  # List workspaces
#terraform workspace list

#  Create new workspace
#terraform workspace new dev
#terraform workspace new prod

# Show current workspace
#terraform workspace select dev
