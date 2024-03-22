########################################################
# Must Install the latest version of aws cli & terraform
########################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
     version = "4.7.0"
    }
  }
}

provider "aws" {
  region = var.region
}

terraform {
  required_version = "~> 1.0"
}


### Backend ###
# S3
###############

terraform {
  backend "s3" {
    bucket         =  "muse-elevar-terraform-backend"
    key            =  "env/dev/muse-elevar-dev.tfstate"
    region         =  "ap-south-1"
  }
}

#  Error: configmaps "aws-auth" already exists
#  Solution: kubectl delete configmap aws-auth -n kube-system



#########
# Eks Vpc
#########
module "eks_vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name            = var.cluster_name

  cidr            = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false // nat ha req or not?

  # create_database_subnet_group           = true
  # create_database_subnet_route_table     = true
  # create_database_internet_gateway_route = false
  # create_database_nat_gateway_route      = true

  enable_dns_hostnames = true
  enable_dns_support   = true

# https://aws.amazon.com/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = "${var.cluster_name}"
    "kubernetes.io/role/internal-elb"           = "1"
  }
  # 

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"       = "1"
  }


}




##RDS Module
module "rds" {
  source = "../../modules/rds"
  db_subnet_groups = module.eks_vpc.private_subnets
  vpc_security_group_ids = [module.eks_vpc.default_security_group_id]
}


#ECR Module
module "ecr" {
  source = "../../modules/ecr"
}
