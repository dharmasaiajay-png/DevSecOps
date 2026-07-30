region        = "ap-south-2"
ami_id        = "ami-0c8dc555a7e1ca7a3"   # Replace with latest Amazon Linux 2 AMI
instance_type = "t3.medium"
key_name      = "ajaybalakeypair"
vpc_cidr      = "10.0.0.0/16"
subnet_cidr   = "10.0.1.0/24"
tags = {
  Project = "DevSecOps"
  Owner   = "Ajay-Magneq"
}
