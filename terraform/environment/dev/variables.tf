variable "cluster_name" {
  default = "muse-elevar-eks-dev"
}
variable "region" {
  default = "ap-south-1"
}
# # Declare the data source
# data "aws_availability_zones" "available_zones" {
#   state = "available"
# }


#Eks vpc
variable "vpc_cidr" {
  default = "10.60.0.0/16"
}
variable "azs" {
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}
variable "private_subnets" {
  default = ["10.60.0.0/23", "10.60.2.0/23", "10.60.4.0/23"]
}
variable "public_subnets" {
  default = ["10.60.100.0/23", "10.60.102.0/24", "10.60.104.0/24"]
}
#Eks cluster
variable "cluster_version" {
  default = "1.29"
}
variable "instance_types" {
  default = ["t3a.medium"]
}
variable "capacity_type" {
  default = "ON_DEMAND"
}
variable "desired_capacity" {
  default = "1"
}
variable "max_capacity" {
  default = "1"
}
variable "min_capacity" {
  default = "1"
}
variable "key_name" {
  default = "terraform-muse-elevar"
}
variable "disk_type" {
  default =  "gp3"
}
variable "disk_size" {
  default = "30"
}
variable "karpenter_version" {
  default = "v0.5.3"
}
variable "workers_role_name" {
  default = "iam-eks-workers-role"
}
variable "node_group_name" {
  default = "muse-elevar-eks-workers"
}
variable "email_id" {
  type = string
  default = "museelevar@aws.com"
}
#Tags
variable "project" {
  default = "Muse-Elevar"
}
variable "Applicati_CI" {
default = "1101229882"
}
variable "UAI" {
  default = "UAI3056925"
}
