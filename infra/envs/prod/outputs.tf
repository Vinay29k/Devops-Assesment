output "alb_dns_name" {
  value = module.network.alb_dns_name
}

output "ecs_cluster_id" {
  value = module.ecs.cluster_id
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "db_endpoint" {
  value = module.rds.db_instance_endpoint
}
