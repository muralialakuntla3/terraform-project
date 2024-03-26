output "vpc" {
  value = module.eks_vpc
}

output "karpenter_controller_iam_role" {
  value = module.karpenter_controller_iam_role.iam_assumable_role_karpenter_iam_role_arn
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = var.cluster_name
}


