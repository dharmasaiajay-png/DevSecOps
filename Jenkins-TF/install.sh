#!/bin/bash
# Update system
sudo dnf update -y

# Install Java, Git, Docker, Wget
sudo dnf install -y java-21-amazon-corretto git docker wget

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key
sudo dnf install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install Terraform (HashiCorp official repo)
sudo dnf install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo dnf install -y terraform

# Install kubectl (fixed download link)
curl -LO "https://dl.k8s.io/release/v1.27.3/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# Install eksctl
curl --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Trivy (binary method for Amazon Linux 2023)
TRIVY_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep tag_name | cut -d '"' -f4)
curl -L https://github.com/aquasecurity/trivy/releases/download/${TRIVY_VERSION}/trivy_${TRIVY_VERSION#v}_Linux-64bit.tar.gz -o trivy.tar.gz
tar zxvf trivy.tar.gz
sudo mv trivy /usr/local/bin/
rm -f trivy.tar.gz

# Run SonarQube in Docker (remove old container if exists)
sudo docker rm -f sonar || true
sudo docker run -d --name sonar -p 9000:9000 sonarqube:lts
