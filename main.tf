# main.tf - EC2 Configuration

# Key pair data source
data "aws_key_pair" "existing" {
  key_name = "Leeno-pc"  
}

# Secure EC2 instance with encryption and IMDS protection
resource "aws_instance" "Ajay" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = data.aws_key_pair.existing.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  user_data              = base64encode(file("website.sh"))

  # Enable EBS encryption
  root_block_device {
    encrypted = true
  }

  # Secure IMDS configuration
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "Aj-EC2"
  }
}

# Secure security group
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "allow access on ports 80, 22, and 443"

  # SSH access from specific IP only
  ingress {
    description = "ssh access from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["97.116.4.181/32"]
  }

  # HTTPS access from anywhere (for web traffic)
  # tfsec:ignore:aws-ec2-no-public-ingress-sgr
  ingress {
    description = "https web traffic - required for public website"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere (for web traffic)
  # tfsec:ignore:aws-ec2-no-public-ingress-sgr
  ingress {
    description = "http web traffic - required for public website"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access for updates and dependencies
  # tfsec:ignore:aws-ec2-no-public-egress-sgr
  egress {
    description = "outbound internet access - required for system updates"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Aj_sg"
  }
}

# s3.tf - S3 Configuration

# Create KMS key for S3 encryption
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "s3-encryption-key"
  }
}

# KMS key alias
resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/s3-bucket-key"
  target_key_id = aws_kms_key.s3_key.key_id
}