variable "deployment_strategy" {
  description = "Deployment strategy: blue-green | canary | rolling"
  type        = string
  default     = "blue-green"
}

variable "canary_percent" {
  description = "Percentage of traffic to route to canary in canary deployments"
  type        = number
  default     = 10
}

variable "rolling_batch_size" {
  description = "MinHealthyPercentage or batch size for instance refresh"
  type        = number
  default     = 90
}
variable "aws_region" { default = "us-east-1" }
variable "vpc_id" { }
variable "public_subnets" { type = list(string) }
variable "ami_id" { description = "AMI/image id built by packer" }
variable "instance_type" { default = "t3.micro" }
