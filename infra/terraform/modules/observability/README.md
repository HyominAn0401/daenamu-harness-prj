# observability Terraform Module

Installs local observability components for DAENAMU.

Current scope:

- Jaeger all-in-one deployment,
- Jaeger query service for the UI,
- Jaeger collector service with OTLP HTTP and gRPC ports.

Spring Boot services export traces to:

```text
http://jaeger-collector.observability:4318/v1/traces
```
