#!/bin/bash

set -e

# -------------------------------------------------------
# System Update
# -------------------------------------------------------

dnf update -y

# -------------------------------------------------------
# Base Packages
# -------------------------------------------------------

dnf install -y \
  java-21-amazon-corretto \
  git \
  docker \
  wget \
  curl \
  unzip \
  tar \
  gzip \
  yum-utils \
  fontconfig

# -------------------------------------------------------
# Docker
# -------------------------------------------------------

systemctl enable docker
systemctl start docker

# Allow Jenkins user to use Docker later
# Jenkins user is created during Jenkins installation

# -------------------------------------------------------
# Jenkins LTS
# -------------------------------------------------------

wget -O /etc/yum.repos.d/jenkins.repo \
  https://pkg.jenkins.io/rpm-stable/jenkins.repo

rpm --import \
  https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key

dnf install -y jenkins

systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

# Add Jenkins to Docker group
usermod -aG docker jenkins

# Restart Jenkins so group membership is refreshed
systemctl restart jenkins

# -------------------------------------------------------
# AWS CLI v2
# -------------------------------------------------------

cd /tmp

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o "awscliv2.zip"

unzip -q awscliv2.zip

./aws/install --update

rm -rf aws awscliv2.zip

# -------------------------------------------------------
# Terraform
# -------------------------------------------------------

yum-config-manager \
  --add-repo \
  https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

dnf install -y terraform

# -------------------------------------------------------
# kubectl
# -------------------------------------------------------

KUBECTL_VERSION=$(curl -L -s \
  https://dl.k8s.io/release/stable.txt)

curl -LO \
  "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

chmod +x kubectl

mv kubectl /usr/local/bin/kubectl

# -------------------------------------------------------
# eksctl
# -------------------------------------------------------

ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

curl -sLO \
  "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"

tar -xzf \
  "eksctl_${PLATFORM}.tar.gz" \
  -C /tmp

mv /tmp/eksctl /usr/local/bin/eksctl

rm -f \
  "eksctl_${PLATFORM}.tar.gz"

# -------------------------------------------------------
# Helm
# -------------------------------------------------------

curl -fsSL \
  https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
  | bash

# -------------------------------------------------------
# Trivy
# -------------------------------------------------------

curl -sfL \
  https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
  | sh -s -- -b /usr/local/bin

# -------------------------------------------------------
# SonarQube
# -------------------------------------------------------

docker rm -f sonar || true

docker pull sonarqube:lts-community

docker run -d \
  --name sonar \
  --restart unless-stopped \
  -p 9000:9000 \
  sonarqube:lts-community

# -------------------------------------------------------
# Verify installations
# -------------------------------------------------------

echo "========== JAVA =========="
java -version

echo "========== GIT =========="
git --version

echo "========== DOCKER =========="
docker --version

echo "========== AWS CLI =========="
aws --version

echo "========== TERRAFORM =========="
terraform --version

echo "========== KUBECTL =========="
kubectl version --client

echo "========== EKSCTL =========="
eksctl version

echo "========== HELM =========="
helm version

echo "========== TRIVY =========="
trivy --version

echo "========== JENKINS =========="
systemctl status jenkins --no-pager || true

echo "========== SONARQUBE =========="
docker ps
