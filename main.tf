# Terraform state will be stored in S3
terraform {
  backend "s3" {
    bucket = "terraform-bucket-olga"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}

# Use AWS Terraform provider
provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"

}
# Create EC2 instance
resource "aws_instance" "default" {
  ami                    = "${var.ami}"
  count                  = "1"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  source_dest_check      = false
  instance_type          = "${var.instance_type}"
  subnet_id              = "${aws_subnet.main.id}"
}



# Create Security Group for EC2
resource "aws_security_group" "default" {
  name = "terraform-default-sg"
  vpc_id      = "${aws_vpc.main.id}"


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
