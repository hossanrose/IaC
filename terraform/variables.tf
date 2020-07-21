# Input variable definitions


variable "profile" {
  description = "AWS Profile"
}

variable "region" {
  description = "AWS region"
}

variable "vpc_name" {
  description = "Dev CMS VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "vpc_azs" {
  description = "Availability zones for VPC"
  type        = list
}

variable "vpc_private_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway for VPC"
  type        = bool
}


variable "ec2_cluster_name" {
  description = "Name of cluster created by EC2 module"
  type        = string
}

variable "ec2_ami" {
  description = "AMI of ec2 cluster"
  type        = string
}

variable "ec2_type" {
  description = "Instance tyoe of ec2 cluster"
  type        = string
}

variable "ec2_cms_volume" {
  description = "Instance root volume size"
  type        = string
}

variable "key_name" {
  description = "EC2 key name"
  type        = string
}


variable "alb_name" {
  description = "Name of ALB"
  type        = string
}

variable "alb_name_prefix" {
  description = "Name prefix of ALB"
  type        = string
}


variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}

variable "cms_logs" {
  description = "Bucket for CMS logs"
  type        = string
}

