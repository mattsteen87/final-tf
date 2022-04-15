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
resource "aws_instance" "car" {
  ami           = "ami-03ededff12e34e59e"
  instance_type = "t2.micro"
  tags= {
    Name = "cow"
  }
}
