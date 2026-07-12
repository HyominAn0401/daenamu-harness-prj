terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
    }
  }
}

locals {
  harbor_registry_host = split(":", var.harbor_registry)[0]
  node_names = toset([
    "${var.cluster_name}-control-plane",
    "${var.cluster_name}-worker",
  ])
}

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
        endpoint = ["http://${var.harbor_mirror_endpoint}"]
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

resource "terraform_data" "harbor_host_alias" {
  for_each = local.node_names

  input = {
    node_name = each.value
    host      = local.harbor_registry_host
    ip        = var.harbor_host_alias_ip
  }

  provisioner "local-exec" {
    command = "docker exec ${self.input.node_name} sh -c 'grep -q \" ${self.input.host}$\" /etc/hosts || echo \"${self.input.ip} ${self.input.host}\" >> /etc/hosts'"
  }

  depends_on = [kind_cluster.this]
}
