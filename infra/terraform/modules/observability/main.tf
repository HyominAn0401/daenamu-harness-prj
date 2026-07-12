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

resource "kubernetes_deployment" "jaeger" {
  metadata {
    name      = "jaeger"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/name" = "jaeger"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "jaeger"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "jaeger"
        }
      }

      spec {
        container {
          name  = "jaeger"
          image = var.jaeger_image

          env {
            name  = "COLLECTOR_OTLP_ENABLED"
            value = "true"
          }

          port {
            name           = "ui"
            container_port = 16686
          }

          port {
            name           = "otlp-grpc"
            container_port = 4317
          }

          port {
            name           = "otlp-http"
            container_port = 4318
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.this]
}

resource "kubernetes_service" "jaeger_query" {
  metadata {
    name      = "jaeger-query"
    namespace = var.namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "jaeger"
    }

    port {
      name        = "http-query"
      port        = 16686
      target_port = "ui"
    }
  }
}

resource "kubernetes_service" "jaeger_collector" {
  metadata {
    name      = "jaeger-collector"
    namespace = var.namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "jaeger"
    }

    port {
      name        = "otlp-grpc"
      port        = 4317
      target_port = "otlp-grpc"
    }

    port {
      name        = "otlp-http"
      port        = 4318
      target_port = "otlp-http"
    }
  }
}
