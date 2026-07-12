variable "kubeconfig_path" {
  description = "Path to the kubeconfig used by Terraform providers."
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context for the local cluster."
  type        = string
  default     = "kind-daenamu"
}

variable "namespace" {
  description = "Kubernetes namespace for DAENAMU."
  type        = string
  default     = "daenamu"
}

variable "observability_namespace" {
  description = "Kubernetes namespace for Jaeger and observability tools."
  type        = string
  default     = "observability"
}

variable "create_observability_namespace" {
  description = "Whether Terraform should create the observability namespace."
  type        = bool
  default     = true
}

variable "jaeger_image" {
  description = "Jaeger all-in-one image with OTLP collector enabled."
  type        = string
  default     = "jaegertracing/all-in-one:1.57"
}

variable "create_namespace" {
  description = "Whether Terraform should create the DAENAMU namespace."
  type        = bool
  default     = true
}

variable "release_name" {
  description = "Helm release name for DAENAMU."
  type        = string
  default     = "daenamu"
}

variable "chart_path" {
  description = "Relative path to the DAENAMU Helm chart."
  type        = string
  default     = "../../../helm/daenamu"
}

variable "image_registry" {
  description = "Harbor registry host used by the Helm chart."
  type        = string
  default     = "hub.daenamu.local:8083"
}

variable "image_project" {
  description = "Harbor project used by DAENAMU images."
  type        = string
  default     = "daenamu"
}

variable "image_tag" {
  description = "Image tag deployed for all DAENAMU services in local."
  type        = string
  default     = "local"
}

variable "image_pull_policy" {
  description = "Kubernetes imagePullPolicy used by DAENAMU services."
  type        = string
  default     = "IfNotPresent"
}

variable "image_pull_secret_name" {
  description = "Optional imagePullSecret name for Harbor authentication. Leave empty for no secret."
  type        = string
  default     = "harbor-regcred"
}

variable "harbor_username" {
  description = "Harbor username used for image pulls."
  type        = string
  default     = "admin"
}

variable "harbor_password" {
  description = "Harbor password used for image pulls."
  type        = string
  default     = ""
  sensitive   = true
}

variable "service_type" {
  description = "Default Kubernetes Service type for DAENAMU services."
  type        = string
  default     = "ClusterIP"
}

variable "helm_timeout_seconds" {
  description = "Timeout for Helm release operations."
  type        = number
  default     = 300
}
