terraform {
  backend "s3" {
    bucket = "msteentest-tf-state" # REPLACE WITH YOUR BUCKET NAME
    key    = "terraform.tfstate"
    region = "us-east-1"
    #dynamodb_table = "terraform-state-locking"
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "new-cow" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "cowwww"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.new-cow.id

  tags = {
    Name = "main"
  }
}
resource "aws_route_table" "cow-route-tb" {
  vpc_id = aws_vpc.new-cow.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  /*route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }*/

  tags = {
    Name = "test-test-cow"
  }
}
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.new-cow.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-1"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.cow-route-tb.id
}
resource "aws_security_group" "allow_web" {
  name        = "allows_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.new-cow.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["73.83.181.56/32"]
  }
  ingress {
    description = "Http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["73.83.181.56/32"]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["73.83.181.56/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}
resource "aws_instance" "car" {
  ami               = "ami-03ededff12e34e59e"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "mattssandbox"

  network_interface {
    network_interface_id = aws_network_interface.web-server-nic.id
    device_index         = 0
  }
  user_data = <<-EOF
              #!/bin/bash
              EOF
  tags = {
    Name = "cow"
  }            
}
