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
    cidr_blocks = local.cloud_flare_allow_list
  }

  ingress {
    description = "SSH to VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

# internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.web_vpc.id

  tags = {
    Name = local.resource_name_tag
  }
}

# manage default routing table for our vpc
resource "aws_default_route_table" "web_vpc" {
  default_route_table_id = aws_vpc.web_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = local.resource_name_tag
  }
}

# Public key
resource "aws_key_pair" "pub_key" {
  key_name   = "dj-pub"
  public_key = file("publickey.crt")
}

# AWS Server
resource "aws_instance" "web" {
  ami                         = "ami-05d72852800cbf29e" #ec2 on us-east-2
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.pub_key.key_name
  subnet_id                   = aws_subnet.web_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_443_22.id]

  user_data = file("post_provision_ec2.sh")

  tags = {
    Name = local.resource_name_tag
  }

  depends_on = [aws_internet_gateway.gw]
}
