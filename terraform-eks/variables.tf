variable "region" {
  default     = "us-west-2"
  description = "AWS region"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = "us-west-2"
  profile = "default"
}

