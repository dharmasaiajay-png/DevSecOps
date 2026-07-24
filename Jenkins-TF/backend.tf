terraform {
  backend "s3" {
    bucket        = "dharma-terraform-state"
    key           = "jenkins/terraform.tfstate"
    region        = "ap-south-1"
    encrypt       = true
    use_lockfile  = true
  }
}
