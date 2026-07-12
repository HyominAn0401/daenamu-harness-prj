# DAENAMU Drama Streaming MSA

## 1. 프로젝트 개요

DAENAMU는 드라마 카탈로그, 회차, 재생 정보를 여러 Spring Boot 서비스로 나누어 제공하고, 서비스 간 호출 지연과 오류를 추적하기 위한 MSA 실습 프로젝트다.

현재 저장소는 로컬 KinD Kubernetes 환경, Harbor registry, Helm chart, Terraform 배포 구성, OpenTelemetry Java Agent 기반 Jaeger trace 수집 구성을 포함한다.

---

## 2. 구성 요소

### 서비스

| Service | Port | Main APIs | Downstream |
| --- | ---: | --- | --- |
| catalog | 8080 | `GET /api/catalog/dramas`, `GET /api/catalog/dramas/{dramaId}` | episode |
| episode | 8081 | `GET /api/episodes`, `GET /api/episodes/{episodeId}` | playback |
| playback | 8082 | `GET /api/playback/{episodeId}` | - |
| frontend | 80 | 정적 프론트엔드 컨테이너 | catalog |

현재 서비스 호출 흐름은 다음과 같다.

```text
frontend -> catalog -> episode -> playback
```

`catalog`는 `EPISODE_BASE_URL`로 episode 서비스를 호출하고, `episode`는 `PLAYBACK_BASE_URL`로 playback 서비스를 호출한다. Kubernetes 배포 기본값은 각각 `http://episode:8081`, `http://playback:8082`이다.

### 백엔드 런타임

- 백엔드 서비스는 Spring Boot 애플리케이션이다.
- 각 백엔드 Dockerfile은 Java 21 기반 이미지에서 애플리케이션을 실행한다.
- 컨테이너 이미지에는 OpenTelemetry Java Agent가 `/app/opentelemetry-javaagent.jar`로 포함된다.
- 기본 데이터베이스 설정은 H2 in-memory이며, `application-mysql.properties`를 통해 MySQL용 설정도 분리되어 있다.
- health endpoint는 `/actuator/health`를 사용한다.

---

## 3. 배포 및 실행 관련 파일

### Agent Harness 실행

README 드리프트 판단에 사용할 ground truth는 수동으로 추출할 수 있다.

```bash
scripts/run-agent.sh
scripts/run-agent.sh --json
```

실행 결과는 콘솔에 출력되며, 아래 파일에도 저장된다.

```text
agent/reports/latest-ground-truth.md
agent/reports/latest-ground-truth.json
```

커밋 전에 ground truth 추출을 자동 실행하려면 pre-commit hook을 설치한다.

```bash
scripts/install-commit-hook.sh
```

### Helm chart

DAENAMU 애플리케이션 Helm chart 경로는 다음과 같다.

```text
infra/helm/daenamu
```

기본 이미지 registry와 project는 `values.yaml` 기준으로 아래 값을 사용한다.

```text
hub.daenamu.local:8083/daenamu
```

기본 이미지 태그는 `local`이며, chart에는 다음 서비스가 정의되어 있다.

| Service | Image | Service port | Target port |
| --- | --- | ---: | ---: |
| catalog | `hub.daenamu.local:8083/daenamu/catalog:local` | 8080 | 8080 |
| episode | `hub.daenamu.local:8083/daenamu/episode:local` | 8081 | 8081 |
| playback | `hub.daenamu.local:8083/daenamu/playback:local` | 8082 | 8082 |
| frontend | `hub.daenamu.local:8083/daenamu/frontend:local` | 80 | 80 |

### Terraform

Terraform 구성은 로컬 Kubernetes 클러스터 생성과 애플리케이션 배포 역할이 분리되어 있다.

```text
infra/terraform/envs/local-kind  # KinD cluster 생성
infra/terraform/envs/local       # DAENAMU Helm release와 observability 리소스 배포
```

`local-kind`는 `kind-cluster` 모듈을 사용해 KinD 클러스터와 Harbor registry mirror 관련 설정을 담당한다.

`local`은 다음 모듈을 사용한다.

- `observability`: `observability` namespace와 Jaeger 리소스 생성
- `daenamu-helm`: `infra/helm/daenamu` chart를 Helm release로 배포

배포 흐름은 현재 저장소의 Terraform과 Helm 구성을 기준으로 다음과 같이 정리된다. 이미지 빌드와 Harbor push 자동화는 이 README가 설명하는 Terraform 구성에 포함되어 있지 않으며, Helm values는 Harbor에 존재하는 `local` 태그 이미지를 참조한다.

```text
Terraform local-kind -> KinD cluster
Harbor image 준비
Terraform local -> observability resources + DAENAMU Helm release
Kubernetes runtime -> frontend -> catalog -> episode -> playback
```

---

## 4. 사용 시나리오

사용자가 프론트엔드에서 드라마를 조회하면 `catalog` API가 드라마 목록 또는 상세 정보를 반환한다. 상세 조회 과정에서 `catalog`는 `episode`를 호출해 회차 정보를 가져오고, episode 상세 조회에서는 `episode`가 `playback`을 호출해 재생 정보를 가져온다.

대표 API는 다음과 같다.

```text
GET /api/catalog/dramas
GET /api/catalog/dramas/{dramaId}
GET /api/episodes?dramaId={dramaId}
GET /api/episodes/{episodeId}
GET /api/playback/{episodeId}?delayMs={milliseconds}&fail={true|false}
```

`playback` API는 `delayMs`와 `fail` query parameter를 통해 지연 또는 실패를 주입할 수 있다.

---

## 5. 관측 구조

현재 Jaeger 관측은 Istio나 Envoy sidecar가 아니라 OpenTelemetry Java Agent를 통한 애플리케이션 직접 계측 방식이다.

Helm values는 백엔드 서비스에 다음 설정을 주입한다.

- `JAVA_TOOL_OPTIONS=-javaagent:/app/opentelemetry-javaagent.jar`
- `OTEL_TRACES_EXPORTER=otlp`
- `OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf`
- `OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger-collector.observability:4318`
- `MANAGEMENT_OTLP_TRACING_ENDPOINT=http://jaeger-collector.observability:4318/v1/traces`
- `OTEL_SERVICE_NAME`은 서비스별로 `catalog`, `episode`, `playback`을 사용

Terraform `observability` 모듈은 `observability` namespace에 Jaeger deployment를 만들고, 다음 Kubernetes Service를 생성한다.

| Service | Namespace | Purpose | Port |
| --- | --- | --- | ---: |
| jaeger-query | observability | Jaeger UI/query endpoint | 16686 |
| jaeger-collector | observability | OTLP gRPC/HTTP trace 수집 | 4317, 4318 |

현재 저장소의 인프라 코드는 AWS EKS, IRSA, Istio, Envoy sidecar 구성을 포함하지 않는다.
