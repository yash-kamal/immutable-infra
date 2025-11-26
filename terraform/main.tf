provider "aws" {
  region = "ap-south-1"
}

variable "ami_id" {}

resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = "t2.micro"

  tags = {
    Name = "Immutable-Server"
  }
}

output "public_ip" {
  value = aws_instance.app.public_ip
}
