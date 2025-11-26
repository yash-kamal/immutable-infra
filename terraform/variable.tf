variable "aws_region" { default = "us-east-1" }
variable "vpc_id" { }
variable "public_subnets" { type = list(string) }
variable "ami_id" { description = "AMI/image id built by packer" }
variable "instance_type" { default = "t3.micro" }
