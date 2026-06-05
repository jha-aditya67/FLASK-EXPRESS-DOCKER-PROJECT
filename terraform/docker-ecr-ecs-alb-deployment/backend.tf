terraform {
  backend "s3" {
    bucket         = "aditya-terraform-state-240797211937"
    key            = "flask-express-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
