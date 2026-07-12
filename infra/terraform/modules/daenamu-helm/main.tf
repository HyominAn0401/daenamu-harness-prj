resource "kubernetes_namespace" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/part-of"    = "daenamu"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "this" {
  name      = var.release_name
  namespace = var.namespace
  chart     = var.chart_path

  dependency_update = false
  wait              = true
  timeout           = var.helm_timeout_seconds

  set {
    name  = "global.imageRegistry"
    value = var.image_registry
  }

  set {
    name  = "global.imageProject"
    value = var.image_project
  }

  set {
    name  = "global.imagePullPolicy"
    value = var.image_pull_policy
  }

  dynamic "set" {
    for_each = var.image_pull_secret_name == "" ? [] : [var.image_pull_secret_name]

    content {
      name  = "global.imagePullSecrets[0]"
      value = set.value
    }
  }

  set {
    name  = "defaults.service.type"
    value = var.service_type
  }

  set {
    name  = "services.catalog.image.tag"
    value = var.image_tag
  }

  set {
    name  = "services.episode.image.tag"
    value = var.image_tag
  }

  set {
    name  = "services.playback.image.tag"
    value = var.image_tag
  }

  set {
    name  = "services.frontend.image.tag"
    value = var.image_tag
  }

  depends_on = [kubernetes_namespace.this]
}
