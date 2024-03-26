output "fluentbit_namespace_id" {
  description = "ID of the created Kubernetes namespace for Fluent Bit"
  value       = kubernetes_namespace.fluentbit_namespace.id
}

output "fluentbit_config_map_id" {
  description = "ID of the created Kubernetes ConfigMap for Fluent Bit"
  value       = kubernetes_config_map.fluentbit_config_map.id
}

output "fluentbit_service_account_id" {
  description = "ID of the created Kubernetes service account for Fluent Bit"
  value       = kubernetes_service_account.fluentbit_service_account.id
}

output "fluentbit_cluster_role_id" {
  description = "ID of the created Kubernetes cluster role for Fluent Bit"
  value       = kubernetes_cluster_role.fluentbit_cluster_role.id
}

output "fluentbit_cluster_role_binding_id" {
  description = "ID of the created Kubernetes cluster role binding for Fluent Bit"
  value       = kubernetes_cluster_role_binding.fluentbit_cluster_role_binding.id
}



