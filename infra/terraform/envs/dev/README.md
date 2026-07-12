# DAENAMU dev Terraform Environment

The dev environment is reserved for a future shared or cloud Kubernetes target.

Do not copy local-only assumptions here blindly. The dev environment should make
explicit decisions about:

- cluster provider,
- remote Terraform state,
- image registry endpoint,
- secrets management,
- observability stack,
- ingress and DNS.

Current MVP work should happen in `infra/terraform/envs/local`.
