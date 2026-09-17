output "cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "service_name" {
  value = aws_ecs_service.this.name
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_service.id
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.app.arn
}
