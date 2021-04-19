# VPC
resource "aws_vpc" "web_vpc" {
  cidr_block = local.vpc_cidr_block

  tags = {
    Name = local.resource_name_tag
  }
}

# Subnet
resource "aws_subnet" "web_subnet" {
  vpc_id            = aws_vpc.web_vpc.id
  cidr_block        = local.subnet_cidr_block
  availability_zone = "us-east-2c" #us-east-2

  tags = {
    Name = local.resource_name_tag
  }
}

# Security Group
resource "aws_security_group" "allow_443_22" {
  name        = "allow_web_ssh"
  description = "Allow Ports 22 and 443 inbound traffic"
  vpc_id      = aws_vpc.web_vpc.id

  ingress {
    description = "TLS to VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.web_vpc.cidr_block]
  }

  ingress {
    description = "SSH to VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.web_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.resource_name_tag
  }
}

# Public key
resource "aws_key_pair" "pub_key" {
  key_name   = "dj-pub"
  public_key = "${file("publickey.crt")}"
}

# AWS Server
resource "aws_instance" "web" {
  ami           = "ami-08962a4068733a2b6" #us-east-2
  instance_type = "t2.micro"
  key_name = aws_key_pair.pub_key.key_name
  subnet_id = aws_subnet.web_subnet.id

	user_data = "${file("post_provision.sh")}"

  tags = {
    Name = local.resource_name_tag
  }
}
