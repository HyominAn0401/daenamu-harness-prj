# daenamu-helm Terraform Module

This module installs the DAENAMU Helm chart into an existing Kubernetes cluster.

It owns:

- optional namespace creation,
- `helm_release` for `infra/helm/daenamu`,
- image registry/project/tag overrides.

It does not own:

- Kubernetes cluster creation,
- Harbor installation,
- Docker image build/push,
- observability stack installation.

Those responsibilities can be added as separate modules later.
