output "namespace" {
  description = "Observability namespace."
  value       = var.namespace
}

output "jaeger_query_service" {
  description = "Jaeger UI service name."
  value       = kubernetes_service.jaeger_query.metadata[0].name
}

output "jaeger_collector_otlp_http_endpoint" {
  description = "In-cluster OTLP HTTP endpoint for applications."
  value       = "http://${kubernetes_service.jaeger_collector.metadata[0].name}.${var.namespace}:4318/v1/traces"
}
