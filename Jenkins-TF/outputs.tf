output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = aws_instance.jenkins_bastion_server.public_ip
}

output "jenkins_public_dns" {
  description = "Public DNS of Jenkins server"
  value       = aws_instance.jenkins_bastion_server.public_dns
}

output "jenkins_instance_id" {
  description = "Jenkins EC2 instance ID"
  value       = aws_instance.jenkins_bastion_server.id
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${aws_instance.jenkins_bastion_server.public_ip}:8080"
}

output "sonarqube_url" {
  description = "SonarQube URL"
  value       = "http://${aws_instance.jenkins_bastion_server.public_ip}:9000"
}
