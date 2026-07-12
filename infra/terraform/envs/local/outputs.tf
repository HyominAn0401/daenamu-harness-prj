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
