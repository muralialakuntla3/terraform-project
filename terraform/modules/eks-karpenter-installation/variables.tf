variable "kubeconfig" {
  type = string
}

variable "iam_assumable_role_karpenter_iam_role_arn" {
  type = string
}

variable "cluster_name" {
  type = string
  default = "muse-elevar-eks-dev"
}

variable "cluster_endpoint" {
  type = string
  }

variable "instance_profile" {
  type = string
  default = "KarpenterNodeInstanceProfile-muse-elevar-eks-dev"
}

variable "karpenter_version" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}
 variable "namespace" {
   default =  "karpenter"
 }
 variable "name" {
   default = "karpenter"
 }
 variable "chart" {
   default = "karpenter"
 }
