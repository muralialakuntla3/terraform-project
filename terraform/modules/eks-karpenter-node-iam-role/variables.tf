variable "ssm_managed_instance_policy" {
  type = string
}

variable "worker_iam_role_name" {
  type = string
}

variable "cluster_name" {
  type = string
  default = "muse-elevar-eks-dev"
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