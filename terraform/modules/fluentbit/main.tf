provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = var.cluster_ca_certificate
    
# aws eks get-token --cluster-name muse-elevar-eks-dev | jq '.apiVersion'    # Note: Install the lastest version of terraform & awscli is must 
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}

# Define the Kubernetes namespace for Fluent Bit
resource "kubernetes_namespace" "fluentbit_namespace" {
  metadata {
    name = var.namespace_name
  }
}

#########################################################################################
# Use the correct UAI Tag to be informed by updates or vulnerabilities in your resources
#########################################################################################
resource "aws_s3_bucket" "museelevar_fluentbit_logs_bucket" {
  bucket = "fluentbit-logs-muse-elever"
  tags = {
      Project      = var.project
      Terraform    = var.Terraform
      Applicati_CI = var.Applicati_CI
      UAI          = var.UAI
      Email_ID     = var.email_id
  }
}


# Define the AWS IAM role for Fluent Bit
resource "aws_iam_role" "fluentbit_role" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

##################################################
# Restrict premissions to S3 bucket appropriately
##################################################

resource "aws_iam_policy" "fluentbit_policy" {
  name        = var.iam_policy_name
  description = "Policy for Fluent Bit to access S3"
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetBucketLocation"
        ],
        "Resource": [
          "${aws_s3_bucket.museelevar_fluentbit_logs_bucket.arn}",
          "${aws_s3_bucket.museelevar_fluentbit_logs_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Define the AWS IAM policy for Fluent Bit to access CloudWatch Logs
resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "fluentbit-cloudwatch-logs-policy"
  description = "Policy for Fluent Bit to access CloudWatch Logs"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource":  "arn:aws:logs:ap-south-1:339263341917:log-group:/aws/eks/muse-elevar-eks-dev/cluster:*"
      }
    ]
  })
}


# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "fluentbit_policy_attachment" {
  role       = aws_iam_role.fluentbit_role.name
  policy_arn = aws_iam_policy.fluentbit_policy.arn
}

resource "aws_iam_role_policy_attachment" "fluentbit_cloudwatch_logs_policy_attachment" {
  role       = aws_iam_role.fluentbit_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}
# Define the Fluent Bit configuration as a Kubernetes ConfigMap
resource "kubernetes_config_map" "fluentbit_config_map" {
  metadata {
    name      = "fluent-bit"
    namespace = kubernetes_namespace.fluentbit_namespace.metadata[0].name
  }

  data = {
    fluent_bit_conf = <<-EOF
      [SERVICE]
          Flush 1
          Daemon Off
          Log_Level info
          HTTP_Server On
          HTTP_Listen 0.0.0.0
          HTTP_Port 2020
  

      [INPUT]
          Name tail
          Path /var/log/containers/*.log
          Parser docker
          Tag kube.*
          Mem_Buf_Limit 5MB
          Skip_Long_Lines On

      [FILTER]
        Name kubernetes
        Match kube.*
        Merge_Log On
        Merge_Log_Trim On
        Labels On
        Annotations Off
        K8S-Logging.Parser Off
        K8S-Logging.Exclude Off

      [INPUT]
        Name systemd
        Tag host.*
        Systemd_Filter _SYSTEMD_UNIT=kubelet.service
        Read_From_Tail On

      [OUTPUT]
        Name s3
        Match kube.* 
        bucket fluentbit-logs-muse-elever
        S3_Key_Format /%Y/%m/%d/%H 
    EOF
  }
}



# Define the Fluent Bit service account
resource "kubernetes_service_account" "fluentbit_service_account" {
  metadata {
    name      = var.service_account_name
    namespace = kubernetes_namespace.fluentbit_namespace.metadata[0].name
  }
}

# Define the Fluent Bit cluster role and binding
resource "kubernetes_cluster_role" "fluentbit_cluster_role" {
  metadata {
    name = var.cluster_role_name
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "fluentbit_cluster_role_binding" {
  metadata {
    name = var.cluster_role_binding_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.fluentbit_cluster_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.fluentbit_service_account.metadata[0].name
    namespace = kubernetes_namespace.fluentbit_namespace.metadata[0].name
  }
}

resource "helm_release" "fluentbit" {
  name       = var.helm_release_name
#   repository = "https://fluent.github.io/helm-charts"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  version    = "0.1.32"
#   chart      = "fluent-bit"
  namespace  = kubernetes_namespace.fluentbit_namespace.metadata[0].name

  values = [
    <<-EOF
      service:
        Flush: 1
        Daemon: Off
        Log_Level: info
        Parsers_File: parsers.conf
        set:
          - name: "backend.s3.region"
            value: "ap-south-1"
      input:
        Name: tail
        Path: /var/log/containers/*.log
        Parser: docker
        Tag: kube.*
      output:
        Name: s3
        Match: kube.* fluentbit-logs-muse-elever
        S3_Key_Format: "/%Y/%m/%d/%H"
    EOF
  ]
}

