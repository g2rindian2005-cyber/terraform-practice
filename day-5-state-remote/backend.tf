terraform {
  backend "s3" {
    bucket = "gokul-08"
    key    = "jawan-folder/terraform.tf"
    region = "us-east-1"
  }
}