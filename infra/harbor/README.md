# Local Harbor

Harbor is used as the local private container registry for DAENAMU images.

## Purpose

The registry sits between local image builds and the KinD cluster.

```text
source code -> docker build -> Harbor -> KinD image pull -> Kubernetes runtime
```

It is also an Agent Harness target because Harbor exposes image tags, digests,
push history, and vulnerability scan metadata.

## Local Registry Plan

Recommended local registry host:

```text
hub.daenamu.local:8088
```

Recommended Harbor project:

```text
daenamu
```

Expected image names:

```text
hub.daenamu.local:8088/daenamu/catalog:local
hub.daenamu.local:8088/daenamu/episode:local
hub.daenamu.local:8088/daenamu/playback:local
hub.daenamu.local:8088/daenamu/frontend:local
```

## Git Policy

Commit documentation and sanitized examples only.

Do not commit:

```text
*.tgz
harbor/
data/
common/
log/
secret/
```

Those paths are installer archives, generated configuration, registry blobs,
database files, logs, and secret material.

## Next Steps

1. Prepare a sanitized `harbor.yml.example`.
2. Register `hub.daenamu.local:8088` as a Docker insecure registry.
3. Build and push DAENAMU images to Harbor.
4. Configure KinD containerd to pull from the HTTP Harbor registry.
5. Create a Kubernetes `imagePullSecret` for Harbor access.
