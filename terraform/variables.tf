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

variable "ec2_instance_count" {
  description = "Number of instances in cluster"
  type        = string
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

variable "ec2_jump_name" {
  description = "Bastion instance name"
  type        = string
}

variable "ec2_jump_type" {
  description = "Instance tyoe of Bastion"
  type        = string
}

variable "ec2_jump_volume" {
  description = "Bastion root volume size"
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

variable "rds_cms_name" {
  description = "Name for DB"
  type        = string
}

variable "rds_cms_engine" {
  description = "Engine for DB"
  type        = string
}

variable "rds_cms_user" {
  description = "User for DB"
  type        = string
}

variable "rds_cms_pass" {
  description = "Password for DB"
  type        = string
}

variable "rds_cms_type" {
  description = "Instance type for DB"
  type        = string
}

variable "rds_cms_version" {
  description = "Version of DB engine"
  type        = string
}

variable "rds_cms_enversion" {
  description = "Version of DB engine"
  type        = string
}

variable "rds_cms_family" {
  description = "Family of DB engine"
  type        = string
}

variable "rds_cms_volume" {
  description = "RDS volume size"
  type        = string
}

variable "rds_cms_port" {
  description = "RDS port"
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

