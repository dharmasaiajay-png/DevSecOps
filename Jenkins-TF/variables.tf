# AWS Region
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

# AMI ID
variable "ami_id" {
  description = "Amazon Linux 2 AMI ID"
  type        = string
}

# Instance Type
variable "instance_type" {
  description = "EC2 instance type for Jenkins server"
  type        = string
  default     = "t2.medium"
}

# Key Pair
variable "key_name" {
  description = "Name of the existing AWS key pair to SSH into the instance"
  type        = string
}

# VPC CIDR
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Subnet CIDR
variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Tags
variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {
    Project = "DevSecOps"
    Owner   = "Ajay-Magneq"
  }
}

