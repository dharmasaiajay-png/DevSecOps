#!/bin/bash
# Update system
sudo dnf update -y

# Install Java, Git, Docker, wget, unzip
sudo dnf install -y java-21-amazon-corretto git docker wget unzip
sudo dnf install -y java-21-amazon-corretto-devel

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Add ec2-user to docker group
sudo usermod -aG docker ec2-user

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io.key
sudo dnf install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install Terraform
TERRAFORM_VERSION="1.9.5"
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version

# Install kubectl (official Kubernetes release)
sudo rm -f /usr/local/bin/kubectl
curl -LO "https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# Install eksctl
curl --silent --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Trivy (via Docker)
sudo docker run --rm aquasec/trivy:latest --version

# Run SonarQube in Docker (avoid duplicate container names)
if [ "$(sudo docker ps -aq -f name=sonar)" ]; then
  echo "SonarQube container already exists, skipping..."
else
  sudo docker run -d --name sonar -p 9000:9000 -v sonarqube_data:/opt/sonarqube/data sonarqube:lts
fi
