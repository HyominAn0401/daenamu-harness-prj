# observability Terraform Module

This module is intentionally not implemented yet.

Planned responsibility:

- install Jaeger through Helm,
- optionally install Prometheus and Grafana,
- expose trace/metric endpoints for the Agent Harness,
- provide values that can be compared against README observability sections.

Reason for deferring:

- The current MVP first needs a stable local cluster, Harbor image flow, and
  DAENAMU Helm release.
- Jaeger should be added after service deployment is repeatable.
