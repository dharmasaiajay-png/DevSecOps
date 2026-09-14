# -------------------------------------------------------
# Availability Zones
# -------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

# -------------------------------------------------------
# VPC
# -------------------------------------------------------

resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "jenkins-vpc"
    }
  )
}

# -------------------------------------------------------
# Public Subnet
# -------------------------------------------------------

resource "aws_subnet" "jenkins_subnet" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "jenkins-subnet"
    }
  )
}

# -------------------------------------------------------
# Internet Gateway
# -------------------------------------------------------

resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = merge(
    var.tags,
    {
      Name = "jenkins-igw"
    }
  )
}

# -------------------------------------------------------
# Route Table
# -------------------------------------------------------

resource "aws_route_table" "jenkins_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }

  tags = merge(
    var.tags,
    {
      Name = "jenkins-rt"
    }
  )
}

# -------------------------------------------------------
# Route Table Association
# -------------------------------------------------------

resource "aws_route_table_association" "jenkins_rta" {
  subnet_id      = aws_subnet.jenkins_subnet.id
  route_table_id = aws_route_table.jenkins_rt.id
}

# -------------------------------------------------------
# Security Group
# -------------------------------------------------------

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins DevSecOps server"
  vpc_id      = aws_vpc.jenkins_vpc.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins
  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SonarQube
  ingress {
    description = "SonarQube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "jenkins-sg"
    }
  )
}

# -------------------------------------------------------
# IAM Role for Jenkins EC2
# -------------------------------------------------------

resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# -------------------------------------------------------
# Jenkins IAM Policy
# -------------------------------------------------------

resource "aws_iam_policy" "jenkins_policy" {
  name        = "jenkins-devsecops-policy"
  description = "Permissions required by Jenkins DevSecOps server"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:CreateRepository",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:CreateCluster",
          "eks:DeleteCluster",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:CreateNodegroup",
          "eks:DeleteNodegroup"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "ec2:Describe*",
          "ec2:CreateTags"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "iam:GetRole",
          "iam:ListRoles",
          "iam:PassRole"
        ]

        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# -------------------------------------------------------
# Attach IAM Policy to Jenkins Role
# -------------------------------------------------------

resource "aws_iam_role_policy_attachment" "jenkins_policy_attachment" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_policy.arn
}

# -------------------------------------------------------
# IAM Instance Profile
# -------------------------------------------------------

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-profile"
  role = aws_iam_role.jenkins_role.name

  tags = var.tags
}

# -------------------------------------------------------
# Jenkins EC2 Instance
# -------------------------------------------------------

resource "aws_instance" "jenkins_bastion_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = aws_subnet.jenkins_subnet.id

  vpc_security_group_ids = [
    aws_security_group.jenkins_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name

  key_name = var.key_name

  associate_public_ip_address = true

  user_data = file("${path.module}/install.sh")

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  tags = merge(
    var.tags,
    {
      Name = "Jenkins_Bastion_Server"
    }
  )

  depends_on = [
    aws_internet_gateway.jenkins_igw,
    aws_iam_role_policy_attachment.jenkins_policy_attachment
  ]
}
