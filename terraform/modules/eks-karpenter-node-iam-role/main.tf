data "aws_iam_policy" "ssm_managed_instance" {
  arn = var.ssm_managed_instance_policy
   tags = {
    Project      = var.project
    Terraform    = "true"
    Applicati_CI = var.Applicati_CI
    UAI          = var.UAI
    Email_ID     = var.email_id
  }
}

resource "aws_iam_role_policy_attachment" "karpenter_ssm_policy" {
  role       = var.worker_iam_role_name
  policy_arn = data.aws_iam_policy.ssm_managed_instance.arn
  
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
  role = var.worker_iam_role_name
   tags = {
    Project      = var.project
    Terraform    = "true"
    Applicati_CI = var.Applicati_CI
    UAI          = var.UAI
    Email_ID     = var.email_id
  }
}
