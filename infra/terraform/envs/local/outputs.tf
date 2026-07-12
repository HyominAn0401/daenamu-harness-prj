output "namespace" {
  description = "Namespace used for DAENAMU."
  value       = module.daenamu_helm.namespace
}

output "release_name" {
  description = "Helm release name."
  value       = module.daenamu_helm.release_name
}

output "image_registry" {
  description = "Harbor image registry used by the release."
  value       = var.image_registry
}

output "image_project" {
  description = "Harbor image project used by the release."
  value       = var.image_project
}

output "jaeger_ui_port_forward" {
  description = "Command to open the Jaeger UI locally."
  value       = "kubectl port-forward -n ${module.observability.namespace} svc/${module.observability.jaeger_query_service} 16686:16686"
}

output "jaeger_otlp_http_endpoint" {
  description = "In-cluster OTLP HTTP endpoint used by backend services."
  value       = module.observability.jaeger_collector_otlp_http_endpoint
}
