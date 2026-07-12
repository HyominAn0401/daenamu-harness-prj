terraform {
  required_version = ">= 1.6.0"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.6"
    }
  }
}

module "kind_cluster" {
  source = "../../modules/kind-cluster"

  cluster_name     = var.cluster_name
  node_image       = var.node_image
  kubeconfig_path  = var.kubeconfig_path
  harbor_registry  = var.harbor_registry
  expose_http_port = var.expose_http_port
}
