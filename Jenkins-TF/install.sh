#!/bin/bash

set -euo pipefail

# -------------------------------------------------------
# Logging
# -------------------------------------------------------

exec > >(tee /var/log/devsecops-bootstrap.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "======================================================="
echo "Starting DevSecOps Jenkins Server Bootstrap"
echo "======================================================="

# -------------------------------------------------------
# System Update
# -------------------------------------------------------

dnf update -y

# -------------------------------------------------------
# Base Packages
# -------------------------------------------------------
# IMPORTANT:
# Do NOT install the full 'curl' package on Amazon Linux 2023.
# curl-minimal is already present and installing curl causes a conflict.

dnf install -y \
  java-21-amazon-corretto \
  git \
  docker \
  wget \
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

# Allow ec2-user to use Docker
usermod -aG docker ec2-user || true

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

# Allow Jenkins to use Docker
usermod -aG docker jenkins

systemctl start jenkins
systemctl restart jenkins

# -------------------------------------------------------
# AWS CLI v2
# -------------------------------------------------------

cd /tmp

curl -fsSL \
  "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o "awscliv2.zip"

unzip -q awscliv2.zip

./aws/install --update

rm -rf /tmp/aws /tmp/awscliv2.zip

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

curl -fsSLO \
  "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

chmod +x kubectl
mv kubectl /usr/local/bin/kubectl

# -------------------------------------------------------
# eksctl
# -------------------------------------------------------

ARCH=amd64
PLATFORM="$(uname -s)_${ARCH}"

curl -fsSLO \
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
# Final Service Checks
# -------------------------------------------------------

echo ""
echo "======================================================="
echo "Installation Verification"
echo "======================================================="

echo ""
echo "========== JAVA =========="
java -version || true

echo ""
echo "========== GIT =========="
git --version || true

echo ""
echo "========== DOCKER =========="
docker --version || true

echo ""
echo "========== AWS CLI =========="
aws --version || true

echo ""
echo "========== TERRAFORM =========="
terraform --version || true

echo ""
echo "========== KUBECTL =========="
kubectl version --client || true

echo ""
echo "========== EKSCTL =========="
eksctl version || true

echo ""
echo "========== HELM =========="
helm version || true

echo ""
echo "========== TRIVY =========="
trivy --version || true

echo ""
echo "========== JENKINS =========="
systemctl status jenkins --no-pager || true

echo ""
echo "========== DOCKER CONTAINERS =========="
docker ps || true

echo ""
echo "======================================================="
echo "DevSecOps Bootstrap Completed"
echo "======================================================="
