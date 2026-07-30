terraform {
  backend "s3" {
    bucket         = "dharma-terraform-state"
    key            = "jenkins/terraform.tfstate"
    region         = "ap-south-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
