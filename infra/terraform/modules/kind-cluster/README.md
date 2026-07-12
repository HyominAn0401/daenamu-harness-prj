# kind-cluster Terraform Module

This module creates a local KinD cluster for DAENAMU.

It owns:

- KinD cluster lifecycle,
- kubeconfig context creation,
- containerd mirror configuration for the local Harbor registry,
- a simple host port mapping for future HTTP ingress experiments.

It assumes:

- Docker is running.
- `kind` is available on the local machine.
- Harbor is already installed or reachable at `harbor_registry`.
- The local machine can resolve `hub.daenamu.local`.

It does not own:

- Harbor installation,
- Docker image build,
- Docker image push,
- Jaeger/Prometheus/Grafana installation.

Create this cluster before running `infra/terraform/envs/local`.
