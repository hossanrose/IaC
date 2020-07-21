# Terraform CMS configuration

provider "aws" {
  profile = var.profile
  region  = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway

  tags = var.common_tags
}

module "ec2_cms" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.12.0"

  name           = var.ec2_cluster_name
  instance_count = 2

  ami                         = var.ec2_ami
  instance_type               = var.ec2_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [module.cms_sec.this_security_group_id]
  subnet_ids                  = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  associate_public_ip_address = false
  user_data                   = data.template_file.script.rendered
  root_block_device = [{
    volume_size = var.ec2_cms_volume
  }]

  tags = var.common_tags
}



module "efs_cms" {
  source          = "./modules/aws-efs"
  token           = "EFS CMS"
  security_groups = [module.cms_efs_sec.this_security_group_id]
  subnet          = module.vpc.private_subnets[0]
  tags            = var.common_tags
}

data "template_file" "script" {
  template = "${file("userdata.tpl")}"
  vars = {
    efs_id = module.efs_cms.efs_id
  }
}


module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "QLALB"

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
  security_groups = [module.cms_alb_sec.this_security_group_id]

  access_logs = {
    bucket = var.cms_logs
  }

  target_groups = [
    {
      name_prefix      = var.alb_name_prefix
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    },
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  tags = var.common_tags
}

resource "aws_lb_target_group_attachment" "alb-ec2_cms" {
  for_each = toset(module.ec2_cms.id)

  target_group_arn = module.alb.target_group_arns[0]
  #  target_id        = module.ec2_cms.id[0]
  target_id = each.value
  port      = 80
}

module "cms_sec" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "CMS security group"
  description = "Security group for CMS open for CIDR"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = var.vpc_cidr
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = var.common_tags
}

module "cms_alb_sec" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "CMS ALB"
  description = "Security group for CMS ALB publicly open"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.cms_sec.this_security_group_id
    },
  ]
  tags = var.common_tags
}

module "cms_efs_sec" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "CMS EFS"
  description = "Security group for CMS EFS publicly open"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "nfs-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  tags = var.common_tags
}



module "s3_bucket_for_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.cms_logs
  acl    = "log-delivery-write"

  # Allow deletion of non-empty bucket
  force_destroy = true

  attach_elb_log_delivery_policy = true
  tags                           = var.common_tags
}


terraform {
  backend "s3" {
    bucket = "cmstest-terraform"
    key    = "env"
    region = "us-west-2"
  }
}
