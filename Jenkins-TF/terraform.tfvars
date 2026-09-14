region        = "ap-south-1"
ami_id        = "ami-08188a5a4dfdbd573"   # Replace with latest Amazon Linux 2 AMI
instance_type = "t3.medium"
key_name      = "ajaybalakeypairproject"
vpc_cidr      = "10.0.0.0/16"
subnet_cidr   = "10.0.1.0/24"
tags = {
  Project = "DevSecOps"
  Owner   = "Ajay-Magneq"
}
