output "ecr_backend_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "app_url" {
  value = "http://${aws_lb.main.dns_name}"
}

output "backend_url" {
  value = "http://${aws_lb.main.dns_name}:5000"
}
