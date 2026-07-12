variable "cluster_name" {
  description = "KinD cluster name."
  type        = string
  default     = "daenamu"
}

variable "node_image" {
  description = "KinD node image."
  type        = string
  default     = "kindest/node:v1.30.0"
}

variable "kubeconfig_path" {
  description = "Path where KinD writes kubeconfig."
  type        = string
  default     = "~/.kube/config"
}

variable "harbor_registry" {
  description = "Local Harbor registry host:port used by KinD containerd mirrors."
  type        = string
  default     = "hub.daenamu.local:8083"
}

variable "harbor_mirror_endpoint" {
  description = "Harbor endpoint reachable from KinD node containers. Docker Desktop resolves host.docker.internal to the host machine."
  type        = string
  default     = "host.docker.internal:8083"
}

variable "harbor_host_alias_ip" {
  description = "Host IP mapped to hub.daenamu.local inside KinD node containers."
  type        = string
  default     = "192.168.65.254"
}

variable "expose_http_port" {
  description = "Host port mapped to the KinD control-plane HTTP ingress port."
  type        = number
  default     = 8089
}
