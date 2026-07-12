# DAENAMU Terraform Infra

Terraform is the infrastructure orchestration layer for DAENAMU.

The current project direction is:

```text
source code -> docker build -> Harbor -> Helm values -> Kubernetes runtime
```

Terraform does not replace Harbor or Helm. Terraform coordinates the runtime
environment and installs the DAENAMU Helm chart after images are available in
Harbor.

## Responsibility Split

| Layer | Responsibility |
| --- | --- |
| Harbor | Local private image registry for DAENAMU images. |
| Helm | Kubernetes application packaging for catalog, episode, playback, and frontend. |
| Terraform | Environment wiring, namespace creation, Helm release installation, and infra state. |
| Agent Harness | Detects drift between code, Helm/Terraform config, and README. |

## Environments

```text
infra/terraform/envs/local
infra/terraform/envs/local-kind
infra/terraform/envs/dev
```

### local-kind

The local-kind environment creates the local KinD cluster.

Terraform owns:

- KinD cluster lifecycle.
- kubeconfig context creation.
- KinD containerd mirror configuration for Harbor.

Terraform does not own:

- Harbor installation.
- Docker image build.
- Docker image push.
- Jaeger/Prometheus/Grafana installation.

### local

The local environment deploys DAENAMU into an existing local cluster.

It assumes:

- `infra/terraform/envs/local-kind` already created the local KinD cluster, or
  an equivalent Kubernetes cluster already exists.
- Harbor is already installed or reachable.
- DAENAMU images are already built and pushed to Harbor.
- Terraform installs the Helm chart into the selected namespace.

Terraform owns:

- Kubernetes namespace.
- Helm release for `infra/helm/daenamu`.
- Values passed from Terraform into Helm.

Terraform does not own yet:

- Harbor installation.
- Docker image build.
- Docker image push.
- Jaeger/Prometheus/Grafana installation.

### dev

The dev environment is planned for a future cloud or shared cluster setup.
It should reuse modules where possible, but it is intentionally not implemented
in the current MVP.

## Execution Order

1. Start or connect Harbor.
2. Run Terraform from `infra/terraform/envs/local-kind` to create the KinD cluster.
3. Build DAENAMU service images.
4. Push images to Harbor.
5. Run Terraform from `infra/terraform/envs/local`.
6. Terraform installs or updates the DAENAMU Helm release.
7. Run the Agent Harness to compare README, code, Helm, and Terraform state.

## Local Commands

```bash
cd infra/terraform/envs/local-kind
terraform init
terraform plan
terraform apply

cd infra/terraform/envs/local
terraform init
terraform plan
terraform apply
```

Use `terraform.tfvars.example` as the starting point for local values.

## Drift Harness Notes

The Agent Harness should treat these files as infra ground truth:

- `infra/helm/daenamu/values.yaml`
- `infra/terraform/envs/local-kind/*.tf`
- `infra/terraform/envs/local/*.tf`
- `infra/terraform/modules/**/*.tf`

README text is not ground truth. README should be corrected only after code,
Helm, or Terraform evidence proves drift.
