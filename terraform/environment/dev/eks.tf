#############
# Eks Cluster
#############
module "eks" {
  source  = "registry.terraform.io/terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_version           = var.cluster_version
  cluster_name              = var.cluster_name
  vpc_id                    = module.eks_vpc.vpc_id
  subnets                   = module.eks_vpc.private_subnets
  workers_role_name         = var.workers_role_name
  create_eks                = true
  manage_aws_auth           = true
  write_kubeconfig          = true
  kubeconfig_output_path    = "/Users/dinesh/.kube/config" # touch /root/.kube/config   # for terraform HELM provider, we neeed this + #  Error: configmaps "aws-auth" already exists 
  kubeconfig_name           = "config"                                                                                         #  Solution: kubectl delete configmap aws-auth -n kube-system
  enable_irsa               = true                 # oidc
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  map_users                 = [
    {
      userarn               = "arn:aws:iam::339263341917:user/Dinesh"
      username              = "dinesh" 
      groups                = ["system:masters"] 
    },
    {
      userarn               = "arn:aws:iam::339263341917:user/vaishnavi"
      username              = "vaishnavi" 
      groups                = ["system:masters"]
    },
    {
      userarn               = "arn:aws:iam::339263341917:user/cdk-pipeline-user"
      username              = "cdk-pipeline-user" 
      groups                = ["system:masters"]
    }
  ]


# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/17.21.0/submodules/node_groups
  node_groups = {
    muse-elevar-eks-workers = {
      create_launch_template = true
      name                   = var.node_group_name  # Eks Workers Node Groups Name
      instance_types         = var.instance_types
      capacity_type          = var.capacity_type
      desired_capacity       = var.desired_capacity
      max_capacity           = var.max_capacity
      min_capacity           = var.min_capacity
      disk_type              = var.disk_type
      disk_size              = var.disk_size
      ebs_optimized          = true
      disk_encrypted         = true
      key_name               = var.key_name
      enable_monitoring      = true
      additional_tags = {
        "Name"                     = "eks-worker"                            # Tags for Cluster Worker Nodes
        "karpenter.sh/discovery"   = var.cluster_name
      }

    }
  }


    tags = {
      Project      = var.project
      Terraform    = "true"
      Applicati_CI = var.Applicati_CI
      UAI          = var.UAI
      Email_ID     = var.email_id
      "karpenter.sh/discovery" = var.cluster_name
    
  }

}


data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

###################################################
# EKS Cluster Auto-Scaling Karpenter Node IAM Role
###################################################
module "karpenter_node_iam_role" {
  source = "../../modules/eks-karpenter-node-iam-role"
  cluster_name                =  var.cluster_name
  ssm_managed_instance_policy =  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  worker_iam_role_name        =  module.eks.worker_iam_role_name
}

##############################
# KarpenterController IAM Role
##############################
module "karpenter_controller_iam_role" {
  source = "../../modules/eks-karpenter-controller-iam-role"
  cluster_name            = var.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
}

########################################################
# Must Install the latest version of aws cli & terraform
########################################################
# aws eks get-token --cluster-name muse-elevar-eks-dev | jq '.apiVersion'    # Note: Install the lastest version of terraform & awscli is must  
########################
# Karpenter installation
########################
module "karpernter_installation" {
  source = "../../modules/eks-karpenter-installation"
  cluster_endpoint                          = module.eks.cluster_endpoint
  cluster_name                              = var.cluster_name
  instance_profile                          = module.eks.worker_iam_role_name
  iam_assumable_role_karpenter_iam_role_arn = module.karpenter_controller_iam_role.iam_assumable_role_karpenter_iam_role_arn
  kubeconfig                                = module.eks.kubeconfig
  cluster_ca_certificate                    = base64decode(module.eks.cluster_certificate_authority_data) 
  karpenter_version                         = var.karpenter_version
}
