output "namespace" {
  description = "Namespace used by the Helm release."
  value       = var.namespace
}

output "release_name" {
  description = "Helm release name."
  value       = helm_release.this.name
}
