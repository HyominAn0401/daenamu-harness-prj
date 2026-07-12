output "cluster_name" {
  description = "Created KinD cluster name."
  value       = module.kind_cluster.cluster_name
}

output "kube_context" {
  description = "Kubeconfig context created by KinD."
  value       = module.kind_cluster.kube_context
}

output "kubeconfig_path" {
  description = "Kubeconfig path used by the cluster."
  value       = var.kubeconfig_path
}

output "harbor_registry" {
  description = "Harbor registry configured as a KinD containerd mirror."
  value       = var.harbor_registry
}
