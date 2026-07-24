#!/bin/bash
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk git docker
sudo systemctl enable docker && sudo systemctl start docker

# Install Jenkins
wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install -y jenkins
sudo systemctl enable jenkins && sudo systemctl start jenkins

# Install Terraform, kubectl, eksctl, Helm, Trivy
curl -fsSL https://get.terraform.io/install.sh | bash
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.27.3/2023-07-05/bin/linux/amd64/kubectl
chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/
curl --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
sudo yum install -y trivy

# Run SonarQube in Docker
docker run -d --name sonar -p 9000:9000 sonarqube:lts
