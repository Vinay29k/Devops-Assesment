output "db_instance_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "db_instance_id" {
  value = aws_db_instance.this.id
}

output "db_security_group_id" {
  value = aws_security_group.rds.id
}

output "db_password" {
  value     = var.db_password != null ? var.db_password : random_password.db[0].result
  sensitive = true
}
