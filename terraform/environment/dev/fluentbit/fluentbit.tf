resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }
}

resource "aws_iam_role" "fluentbit_role" {
  name = "fluentbit-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks-fargate-pods.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "fluentbit_policy" {
  name        = "fluentbit-policy"
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
          "arn:aws:s3:::muse-elevar-terraform-backend/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fluentbit_policy_attachment" {
  role       = aws_iam_role.fluentbit_role.name
  policy_arn = aws_iam_policy.fluentbit_policy.arn
}

resource "kubernetes_config_map" "fluentbit_config_map" {
  metadata {
    name      = "fluent-bit"
    namespace = kubernetes_namespace.logging.metadata[0].name

    labels = {
      app.kubernetes.io/instance = "fluent-bit"
      app.kubernetes.io/managed-by = "Helm"
      app.kubernetes.io/name = "fluent-bit"
      app.kubernetes.io/version = "1.7.9"
      helm.sh/chart = "fluent-bit-0.15.15"
    }
    annotations = {
      meta.helm.sh/release-name = "fluent-bit-config"
      meta.helm.sh/release-namespace = "default"
    }
  }

  data = {
    parsers.conf = <<-EOF
      [PARSER]
      Name        docker
      Format      json
      Time_Key    time
      Time_Format %Y-%m-%dT%H:%M:%S.%L
    EOF

    custom_parsers.conf = <<-EOF
      [PARSER]
      Name docker_no_time
      Format json
      Time_Keep Off
      Time_Key time
      Time_Format %Y-%m-%dT%H:%M:%S.%L
    EOF

    fluent-bit.conf = <<-EOF
      [SERVICE]
      Flush 1
      Daemon Off
      Log_Level info
      Parsers_File parsers.conf
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
      Name es
      Match kube.*
      Host ${FLUENT_ELASTICSEARCH_HOST}
      Port  ${FLUENT_ELASTICSEARCH_PORT}
      Index my_index

      [OUTPUT]
      Name s3
      Match kube.* muse-elevar-terraform-backend
      S3_Key_Format ${tag}/%Y/%m/%d/%H
    EOF
  }
}

resource "kubernetes_service_account" "fluentbit_service_account" {
  metadata {
    name      = "fluent-bit"
    namespace = kubernetes_namespace.logging.metadata[0].name
  }
}

resource "kubernetes_role" "fluentbit_read_role" {
  metadata {
    name      = "fluent-bit-read"
    namespace = kubernetes_namespace.logging.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "fluentbit_read_role_binding" {
  metadata {
    name      = "fluent-bit-read"
    namespace = kubernetes_namespace.logging.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.fluentbit_read_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.fluentbit_service_account.metadata[0].name
    namespace = kubernetes_namespace.logging.metadata[0].name
  }
}

resource "kubernetes_daemonset" "fluentbit_ds" {
  metadata {
    name      = "fluent-bit"
    namespace = kubernetes_namespace.logging.metadata[0].name
  }

  spec {
    selector {
      match_labels = {
        k8s-app = "fluent-bit-logging"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "fluent-bit-logging"
          version = "v1"
          kubernetes.io/cluster-service = "true"
       
        }
      }
    }
  }
}