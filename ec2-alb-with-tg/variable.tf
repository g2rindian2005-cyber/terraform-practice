variable "region" {}
variable "vpc_cidr" {}
variable "public_subnets" {
  type = list(string)
}
variable "instance_type" {}
variable "ami" {}