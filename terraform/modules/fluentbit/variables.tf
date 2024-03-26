variable "namespace_name" {
  description = "Name of the Kubernetes namespace for Fluent Bit"
  default     = "fluentbit-logging"
}

variable "iam_role_name" {
  description = "Name of the AWS IAM role for Fluent Bit"
  default     = "fluentbit-role"
}

variable "iam_policy_name" {
  description = "Name of the AWS IAM policy for Fluent Bit"
  default     = "fluentbit-policy"
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Fluent Bit to access"
  default     = "arn:aws:s3:::muse-elevar-terraform-backend/*"
}

# variable "fluentbit_config" {
#   description = "Fluent Bit configuration"
#   default     = <<-EOF
#     [SERVICE]
#         Flush 1
#         Daemon Off
#         Log_Level info
#         Parsers_File parsers.conf

#         # Set AWS S3 region
#         set {
#           name  = "backend.s3.region"
#           value = "ap-south-1"
#         }

#     [INPUT]
#         Name tail
#         Path /var/log/containers/*.log
#         Parser docker
#         Tag kube.*

#     [OUTPUT]
#       Name s3
#       Match kube.* muse-elevar-terraform-backend
#       S3_Key_Format /%Y/%m/%d/%H 
#   EOF
# }


variable "service_account_name" {
  description = "Name of the Kubernetes service account for Fluent Bit"
  default     = "fluent-bit"
}

variable "cluster_role_name" {
  description = "Name of the Kubernetes cluster role for Fluent Bit"
  default     = "fluent-bit-read"
}

variable "cluster_role_binding_name" {
  description = "Name of the Kubernetes cluster role binding for Fluent Bit"
  default     = "fluent-bit-read"
}

variable "helm_release_name" {
  description = "Name of the Helm release for Fluent Bit"
  default     = "fluent-bit"
}

variable "helm_repository" {
  description = "Repository URL for Helm charts"
  default     = "https://fluent.github.io/helm-charts"
}

variable "helm_chart" {
  description = "Name of the Helm chart for Fluent Bit"
  default     = "fluent-bit"
}

variable "helm_chart_version" {
  description = "Version of the Helm chart for Fluent Bit"
  default     = "2.13.0"
}
