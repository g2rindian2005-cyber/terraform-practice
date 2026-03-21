resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags ={
    Name = "my-vpc"
  }
}  

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}   

# subnet 

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets[count.index]
 availability_zone = element(
    ["us-east-1a", "us-east-1b"],
    count.index
 )
}
# rout table 
resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.main.id
  
}

resource "aws_route" "internet" {
  route_table_id = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id =  aws_internet_gateway.igw.id

}

# rt asosiation
resource "aws_route_table_association" "assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.rt.id
}

# security 
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # ✅ correct key
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"            # ✅ fixed spelling
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[0].id

  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello from Terraform TFVARS" > /var/www/html/index.html
              EOF
}

resource "aws_lb_target_group" "tg" {
  name     = "my-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}

resource "aws_lb" "alb" {
  name               = "my-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.sg.id]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}