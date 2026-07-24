region        = "ap-south-1"
ami_id        = "ami-0b910d1016287a5e7"   # Replace with latest Amazon Linux 2 AMI
instance_type = "t2.medium"
key_name      = "ajaybala-mainkey"
vpc_cidr      = "10.0.0.0/16"
subnet_cidr   = "10.0.1.0/24"
tags = {
  Project = "DevSecOps"
  Owner   = "Ajay-Magneq"
}
