variable "release_name" {
  description = "Helm release name."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the release."
  type        = string
}

variable "chart_path" {
  description = "Path to the DAENAMU Helm chart."
  type        = string
}

variable "image_registry" {
  description = "Harbor registry host."
  type        = string
}

variable "image_project" {
  description = "Harbor project name."
  type        = string
}

variable "image_tag" {
  description = "Image tag used for DAENAMU services."
  type        = string
}

variable "image_pull_policy" {
  description = "Kubernetes imagePullPolicy used by DAENAMU services."
  type        = string
}

variable "image_pull_secret_name" {
  description = "Optional imagePullSecret name for Harbor authentication. Leave empty for no secret."
  type        = string
}

variable "service_type" {
  description = "Default Kubernetes Service type for DAENAMU services."
  type        = string
}

variable "helm_timeout_seconds" {
  description = "Timeout for Helm release operations."
  type        = number
}

variable "create_namespace" {
  description = "Whether to create the namespace."
  type        = bool
}
