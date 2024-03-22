variable "cluster_name" {
  default = "muse-elevar-eks-dev"
}

variable "cluster_oidc_issuer_url" {
  type = string
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
