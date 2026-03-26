module "rds" {
  source = "../../day-11-RDS-module"

  environment = "dev"
  vpc_cidr    = "10.0.0.0/16"

  subnets = {
    private_1 = {
      cidr = "10.0.1.0/24"
      az   = "us-east-1a"
    }
    private_2 = {
      cidr = "10.0.2.0/24"
      az   = "us-east-1b"
    }
  }

  db_identifier        = "mydb"
  db_name              = "mydb"
  db_engine            = "mysql"
  db_engine_version    = "8.0"
  db_instance_class    = "db.t3.micro"
  db_allocated_storage = 20
  db_username          = "admin"

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"
  deletion_protection     = false
  skip_final_snapshot     = true

  bucket = "my-gokul-secure-bucket-unique-12345877"
}