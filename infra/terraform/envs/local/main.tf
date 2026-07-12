terraform {
  required_version = ">= 1.6.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
  }
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kube_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = var.kube_context
  }
}

module "daenamu_helm" {
  source = "../../modules/daenamu-helm"

  release_name           = var.release_name
  namespace              = var.namespace
  chart_path             = var.chart_path
  image_registry         = var.image_registry
  image_project          = var.image_project
  image_tag              = var.image_tag
  image_pull_policy      = var.image_pull_policy
  image_pull_secret_name = var.image_pull_secret_name
  service_type           = var.service_type
  helm_timeout_seconds   = var.helm_timeout_seconds
  create_namespace       = var.create_namespace
}
