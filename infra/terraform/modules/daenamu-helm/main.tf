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
    name  = "defaults.probes.enabled"
    value = "true"
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

  set {
    name  = "services.catalog.env.MANAGEMENT_OTLP_TRACING_ENDPOINT"
    value = "http://jaeger-collector.observability:4318/v1/traces"
  }

  set {
    name  = "services.catalog.env.MANAGEMENT_TRACING_SAMPLING_PROBABILITY"
    value = "1.0"
  }

  set {
    name  = "services.catalog.env.JAVA_TOOL_OPTIONS"
    value = "-javaagent:/app/opentelemetry-javaagent.jar"
  }

  set {
    name  = "services.catalog.env.OTEL_SERVICE_NAME"
    value = "catalog"
  }

  set {
    name  = "services.catalog.env.OTEL_TRACES_EXPORTER"
    value = "otlp"
  }

  set {
    name  = "services.catalog.env.OTEL_EXPORTER_OTLP_ENDPOINT"
    value = "http://jaeger-collector.observability:4318"
  }

  set {
    name  = "services.catalog.env.OTEL_EXPORTER_OTLP_PROTOCOL"
    value = "http/protobuf"
  }

  set {
    name  = "services.catalog.env.OTEL_METRICS_EXPORTER"
    value = "none"
  }

  set {
    name  = "services.catalog.env.OTEL_LOGS_EXPORTER"
    value = "none"
  }

  set {
    name  = "services.catalog.env.OTEL_PROPAGATORS"
    value = "tracecontext\\,baggage"
  }

  set {
    name  = "services.episode.env.MANAGEMENT_OTLP_TRACING_ENDPOINT"
    value = "http://jaeger-collector.observability:4318/v1/traces"
  }

  set {
    name  = "services.episode.env.MANAGEMENT_TRACING_SAMPLING_PROBABILITY"
    value = "1.0"
  }

  set {
    name  = "services.episode.env.JAVA_TOOL_OPTIONS"
    value = "-javaagent:/app/opentelemetry-javaagent.jar"
  }

  set {
    name  = "services.episode.env.OTEL_SERVICE_NAME"
    value = "episode"
  }

  set {
    name  = "services.episode.env.OTEL_TRACES_EXPORTER"
    value = "otlp"
  }

  set {
    name  = "services.episode.env.OTEL_EXPORTER_OTLP_ENDPOINT"
    value = "http://jaeger-collector.observability:4318"
  }

  set {
    name  = "services.episode.env.OTEL_EXPORTER_OTLP_PROTOCOL"
    value = "http/protobuf"
  }

  set {
    name  = "services.episode.env.OTEL_METRICS_EXPORTER"
    value = "none"
  }

  set {
    name  = "services.episode.env.OTEL_LOGS_EXPORTER"
    value = "none"
  }

  set {
    name  = "services.episode.env.OTEL_PROPAGATORS"
    value = "tracecontext\\,baggage"
  }

  set {
    name  = "services.playback.env.MANAGEMENT_OTLP_TRACING_ENDPOINT"
    value = "http://jaeger-collector.observability:4318/v1/traces"
  }

  set {
    name  = "services.playback.env.MANAGEMENT_TRACING_SAMPLING_PROBABILITY"
    value = "1.0"
  }

  set {
    name  = "services.playback.env.JAVA_TOOL_OPTIONS"
    value = "-javaagent:/app/opentelemetry-javaagent.jar"
  }

  set {
    name  = "services.playback.env.OTEL_SERVICE_NAME"
    value = "playback"
  }

  set {
    name  = "services.playback.env.OTEL_TRACES_EXPORTER"
    value = "otlp"
  }

  set {
    name  = "services.playback.env.OTEL_EXPORTER_OTLP_ENDPOINT"
    value = "http://jaeger-collector.observability:4318"
  }

  set {
    name  = "services.playback.env.OTEL_EXPORTER_OTLP_PROTOCOL"
    value = "http/protobuf"
  }

  set {
    name  = "services.playback.env.OTEL_METRICS_EXPORTER"
    value = "none"
  }

  set {
    name  = "services.playback.env.OTEL_LOGS_EXPORTER"
    value = "none"
  }

  set {
    name  = "services.playback.env.OTEL_PROPAGATORS"
    value = "tracecontext\\,baggage"
  }

  depends_on = [
    kubernetes_namespace.this,
    kubernetes_secret.harbor_pull,
  ]
}
