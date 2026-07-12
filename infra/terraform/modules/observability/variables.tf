variable "namespace" {
  description = "Namespace for observability tools."
  type        = string
}

variable "create_namespace" {
  description = "Whether to create the observability namespace."
  type        = bool
}

variable "jaeger_image" {
  description = "Jaeger all-in-one image."
  type        = string
}
