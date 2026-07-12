output "cluster_name" {
  description = "KinD cluster name."
  value       = kind_cluster.this.name
}

output "kube_context" {
  description = "Kubeconfig context created by KinD."
  value       = "kind-${kind_cluster.this.name}"
}
