# Output variable definitions

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_public_subnets" {
  description = "IDs of the VPC's public subnets"
  value       = module.vpc.public_subnets
}

output "vpc_private_subnets" {
  description = "IDs of the VPC's private subnets"
  value       = module.vpc.private_subnets
}

output "ec2_cms_private_ips" {
  description = "Private IP addresses of CMS EC2 instances"
  value       = module.ec2_cms.private_ip
}


output "alb_dns_name" {
  description = "Public DNS addresses of ALB"
  value       = module.alb.this_lb_dns_name
}
