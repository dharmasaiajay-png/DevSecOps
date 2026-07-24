# Public IP of Jenkins Server
output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins Bastion server"
  value       = aws_instance.Jenkins_Bastion_Server.public_ip
}

# Public DNS of Jenkins Server
output "jenkins_public_dns" {
  description = "Public DNS name of the Jenkins Bastion server"
  value       = aws_instance.Jenkins_Bastion_Server.public_dns
}

# VPC ID
output "vpc_id" {
  description = "ID of the VPC created for Jenkins"
  value       = aws_vpc.jenkins_vpc.id
}

# Subnet ID
output "subnet_id" {
  description = "ID of the subnet created for Jenkins"
  value       = aws_subnet.jenkins_subnet.id
}

# Security Group ID
output "security_group_id" {
  description = "ID of the security group attached to Jenkins server"
  value       = aws_security_group.jenkins_sg.id
}
