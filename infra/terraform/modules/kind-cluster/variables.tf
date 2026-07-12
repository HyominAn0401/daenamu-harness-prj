variable "cluster_name" {
  description = "KinD cluster name."
  type        = string
}

variable "node_image" {
  description = "KinD node image."
  type        = string
}

variable "kubeconfig_path" {
  description = "Path where KinD writes kubeconfig."
  type        = string
}

variable "harbor_registry" {
  description = "Harbor registry host:port configured as an HTTP containerd mirror."
  type        = string
}

variable "expose_http_port" {
  description = "Host port mapped to port 80 on the control-plane node."
  type        = number
}
