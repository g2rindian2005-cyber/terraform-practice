terraform {
  backend "s3" {
    bucket = "config-bucket-739013795335"
    key    = "jawan-folder/terraform.tf"
    region = "us-east-1"
    dynamodb_table = "gokul-lock-table"
  }
}