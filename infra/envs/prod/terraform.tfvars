aws_region   = "us-east-1"
project_name = "bookingapp"
environment  = "prod"

vpc_cidr             = "10.1.0.0/16"
azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs  = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]

container_image = "nginx:latest"
container_port   = 80
task_cpu         = 512
task_memory      = 1024
desired_count    = 3

db_engine                  = "postgres"
db_engine_version          = "16.3"
db_instance_class          = "db.r6g.large"
db_allocated_storage       = 100
db_name                    = "appdb"
db_username                = "appadmin"
db_backup_retention_period = 30
db_deletion_protection     = true
db_multi_az                = true
db_skip_final_snapshot     = false

tags = {
  Project     = "bookingapp"
  Environment = "prod"
  ManagedBy   = "terraform"
}
