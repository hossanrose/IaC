resource "aws_kms_key" "kms" {
  description = "Yo-kms"
}


resource "aws_msk_cluster" "msk" {
  cluster_name           = "Yo-kafka-cluster"
  kafka_version          = "2.4.1"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    ebs_volume_size = 100
    client_subnets = [
      module.vpc.public_subnets[0],
      module.vpc.public_subnets[1],
      module.vpc.public_subnets[2],
    ]
    security_groups = [aws_security_group.msk_sec_group.id]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kms.arn
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }
}
resource "aws_security_group" "msk_sec_group" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = [
      "0.0.0.0/8",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.6.0"

  name                 = "eks-vpc"
  cidr                 = "10.3.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]
  public_subnets       = ["10.3.4.0/24", "10.3.5.0/24", "10.3.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

}

terraform {
  backend "s3" {
    bucket = "terraform-misc"
    key    = "yomsk"
    region = "eu-west-1"
  }
}

