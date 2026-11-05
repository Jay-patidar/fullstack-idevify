variable "aws_region" {
  description = "AWS region for provisioning resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "production"
}

variable "instance_type" {
  description = "EC2 instance type (Free Tier eligible: t2.micro or t3.micro)"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing AWS SSH Key Pair to attach to the instance"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "CIDR block permitted to connect via SSH (Port 22)"
  type        = string
  default     = "0.0.0.0/0"
}
