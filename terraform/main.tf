# Terraform CMS configuration

provider "aws" {
  profile = var.profile
  region  = var.region
}

## Create VPC for CMS
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway   = var.vpc_enable_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.common_tags
}

## Create Instances for CMS
module "ec2_cms" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.12.0"

  name           = var.ec2_cluster_name
  instance_count = var.ec2_instance_count

  ami           = var.ec2_ami
  instance_type = var.ec2_type
  key_name      = var.key_name

  vpc_security_group_ids      = [module.cms_sec.this_security_group_id]
  subnet_ids                  = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  associate_public_ip_address = false

  user_data = data.template_file.script.rendered

  root_block_device = [{
    volume_size = var.ec2_cms_volume
  }]

  tags = var.common_tags
}

## Create Bastion instance
module "ec2_jump" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.12.0"

  name           = var.ec2_jump_name
  instance_count = 1

  ami           = var.ec2_ami
  instance_type = var.ec2_jump_type
  key_name      = var.key_name

  vpc_security_group_ids      = [module.cms_jump_sec.this_security_group_id]
  subnet_ids                  = [module.vpc.public_subnets[0]]
  associate_public_ip_address = true

  root_block_device = [{
    volume_size = var.ec2_jump_volume
  }]

  tags = var.common_tags
}



## Create Shared storage 
module "efs_cms" {
  source = "./modules/aws-efs"
  token  = "EFS CMS"

  security_groups = [module.cms_efs_sec.this_security_group_id]
  subnet          = module.vpc.private_subnets[0]

  tags = var.common_tags
}

data "template_file" "script" {
  template = "${file("userdata.tpl")}"

  vars = {
    efs_id = module.efs_cms.efs_id
    name   = var.rds_cms_name
    user   = var.rds_cms_user
    addr   = module.rds_cms.this_db_instance_address
    pass   = var.rds_cms_pass
  }
}

## Create Load balancer
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name               = "CMSALB"
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

## Create RDS
module "rds_cms" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier           = var.rds_cms_name
  engine               = var.rds_cms_engine
  engine_version       = var.rds_cms_version
  instance_class       = var.rds_cms_type
  family               = var.rds_cms_family
  major_engine_version = var.rds_cms_enversion
  allocated_storage    = var.rds_cms_volume

  name     = var.rds_cms_name
  username = var.rds_cms_user
  password = var.rds_cms_pass
  port     = var.rds_cms_port

  vpc_security_group_ids = [module.cms_rds_sec.this_security_group_id]
  subnet_ids             = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  multi_az               = true

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  tags = var.common_tags

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "character_set_server"
      value = "utf8"
    }
  ]

}

## Attach Instance to target group
resource "aws_lb_target_group_attachment" "alb-ec2_cms" {
  for_each = toset(module.ec2_cms.id)

  target_group_arn = module.alb.target_group_arns[0]
  target_id        = each.value
  port             = 80
}

## Security group for CMS
module "cms_sec" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "CMS security group"
  description = "Security group for CMS open for Loadbalancer only"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.cms_alb_sec.this_security_group_id
    },
  ]

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = var.vpc_cidr
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

## Security group for Bastion
module "cms_jump_sec" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "Bastion security group"
  description = "Security group for Bastion host"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
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

## Security group for Loadbalancer
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

## Security group for Shared storage
module "cms_efs_sec" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "CMS EFS"
  description = "Security group for CMS EFS open in CIDR"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "nfs-tcp"
      cidr_blocks = var.vpc_cidr
    },
  ]

  tags = var.common_tags
}

## Security group for RDS
module "cms_rds_sec" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "CMS RDS"
  description = "Security group for CMS RDS open to CMS instance only"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.cms_sec.this_security_group_id
    },
  ]

  tags = var.common_tags
}

## Object storage for Loadbalancer logs
module "s3_bucket_for_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket                         = var.cms_logs
  acl                            = "log-delivery-write"
  force_destroy                  = true
  attach_elb_log_delivery_policy = true

  tags = var.common_tags
}

## Terraform state remote store
terraform {
  backend "s3" {
    bucket = "cmstest-terraform"
    key    = "env"
    region = "us-west-2"
  }
}
