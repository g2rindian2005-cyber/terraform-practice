terraform {
  backend "s3" {
    bucket = "rathod-gokul01"
    key    = "jawan-folder/terraform.tf"
    region = "us-east-1"
  }
}