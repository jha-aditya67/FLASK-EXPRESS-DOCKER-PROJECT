variable "region" {
  default = "us-east-1"
}

variable "ecs_execution_role_arn" {
  description = "ARN of your existing IAM role for ECS task execution"
  # paste your role ARN here or pass via -var flag
  default = "arn:aws:iam::240797211937:role/ecsTaskExecutionRole"
}
