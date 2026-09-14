terraform {
  backend "s3" {
    bucket         = "dharma-terraform-state1"
    key            = "jenkins/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "advanced-devsecops-terraform-lock"
  }
}
