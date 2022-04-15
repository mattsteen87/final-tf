terraform {
backend "s3" {
     bucket         = "msteentest-tf-state" # REPLACE WITH YOUR BUCKET NAME
     key            = "terraform.tfstate"
     region         = "us-east-1"
    #dynamodb_table = "terraform-state-locking"
    encrypt        = true
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
  resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.new-cow.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet-1"
  }
}
}
resource "aws_instance" "car" {
  ami           = "ami-03ededff12e34e59e"
  instance_type = "t2.micro"
  tags= {
    Name = "cow"
  }
}
