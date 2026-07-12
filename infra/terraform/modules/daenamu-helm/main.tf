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

resource "kubernetes_secret" "harbor_pull" {
  count = var.image_pull_secret_name != "" && var.harbor_username != "" && var.harbor_password != "" ? 1 : 0

  metadata {
    name      = var.image_pull_secret_name
    namespace = var.namespace
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        (var.image_registry) = {
          username = var.harbor_username
          password = var.harbor_password
          auth     = base64encode("${var.harbor_username}:${var.harbor_password}")
        }
      }
    })
  }

  depends_on = [kubernetes_namespace.this]
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

  depends_on = [
    kubernetes_namespace.this,
    kubernetes_secret.harbor_pull,
  ]
}
