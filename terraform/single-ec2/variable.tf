

variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "eu-north-1"
}



variable "ami_id" {
  description = "AMI ID for Ubuntu EC2 instances"
  type        = string
  default     = "ami-05d62b9bc5a6ca605"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}



# =========================
# Networking (Part 3 - ECS/VPC)
# =========================

variable "vpc_cidr" {
  description = "CIDR block for custom VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# =========================
# ECS Configuration
# =========================

variable "ecs_cluster_name" {
  description = "Name of ECS Cluster"
  type        = string
  default     = "flask-express-cluster"
}

variable "backend_image" {
  description = "ECR image URL for Flask backend"
  type        = string
  default     = ""
}

variable "frontend_image" {
  description = "ECR image URL for Express frontend"
  type        = string
  default     = ""
}

# =========================
# Ports Configuration
# =========================

variable "flask_port" {
  description = "Port on which Flask runs"
  type        = number
  default     = 5000
}

variable "express_port" {
  description = "Port on which Express runs"
  type        = number
  default     = 3000
}

# =========================
# Tags
# =========================

variable "project_name" {
  description = "Project name for tagging resources"
  type        = string
  default     = "Flask-Express-Deployment"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
