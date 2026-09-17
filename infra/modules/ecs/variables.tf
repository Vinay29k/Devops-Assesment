variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type        = string
  description = "VPC the ECS service will run in"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets for the Fargate tasks (no public IP)"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group of the ALB; only this SG may reach the ECS tasks"
}

variable "target_group_arn" {
  type        = string
  description = "ALB target group the ECS service registers with"
}

variable "container_image" {
  type        = string
  description = "Docker image for the application container (placeholder, e.g. nginx:latest)"
  default     = "nginx:latest"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "tags" {
  type    = map(string)
  default = {}
}
