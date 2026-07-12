resource "kind_cluster" "this" {
  name            = var.cluster_name
  node_image      = var.node_image
  kubeconfig_path = pathexpand(var.kubeconfig_path)
  wait_for_ready  = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    containerd_config_patches = [
      <<-TOML
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors."${var.harbor_registry}"]
        endpoint = ["http://${var.harbor_registry}"]
      TOML
    ]

    node {
      role = "control-plane"

      extra_port_mappings {
        container_port = 80
        host_port      = var.expose_http_port
        protocol       = "TCP"
      }
    }

    node {
      role = "worker"
    }
  }
}
