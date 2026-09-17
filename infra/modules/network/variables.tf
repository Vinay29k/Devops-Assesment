variable "project_name" {
  type        = string
  description = "Name prefix used for tagging and naming resources"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones to spread subnets across"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets, one per AZ"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets, one per AZ"
}

variable "container_port" {
  type        = number
  description = "Port the application container listens on; used by the ALB target group"
  default     = 80
}

variable "tags" {
  type    = map(string)
  default = {}
}
