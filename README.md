# Drama Streaming MSA 프로젝트

## 1. 프로젝트 개요

MSA 기반 API 병목 추적 및 시각화 인프라 구축

### 주제 및 배경
Amazon은 100ms의 지연이 매출의 1% 감소로 이어질 수 있다고 보고했으며, Google은 0.5초의 지연이 트래픽을 20% 감소시킨다 밝혔다. 이에 착안해 본 프로젝트는 API 지연을 관측하고 병목부분을 추적할 수 있는 인파를 구축하는 것을 목표로 시작했다.

---
## 2. 설치 및 실행 방법
### 필수 환경
- Java 17
- Spring Boot 3.2.5
- Docker & Kubernetes (Minikube, AWS EKS)
- Node.js 18
- React 19.1.0

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

### Main APIs

| Service | Port | Main APIs                                                  | Downstream |
|---------| ---: |------------------------------------------------------------|------------|
| drama   | 8080 | `GET /api/drama/dramas`, `GET /api/drama/dramas/{dramaId}` | episode    |
| episode | 8081 | `GET /api/episodes`, `GET /api/episodes/{episodeId}`       | stream     |
| stream  | 8082 | `GET /api/stream/{streamId}`                               | -          |

```text
frontend -> catalog -> episode -> playback
```

### Helm/Harbor 배포 방향

로컬 배포 구조는 Harbor registry와 Helm chart를 기준으로 정리한다.

```text
Terraform local-kind -> KinD
source code -> Jenkins build -> Harbor -> Terraform local -> Helm release -> Kubernetes runtime
```

Helm chart 경로:

```text
infra/helm/daenamu
```

기본 이미지 registry:

```text
hub.daenamu.local:8088/daenamu
```

Terraform 역할:

```text
infra/terraform/envs/local-kind  # KinD cluster 생성
infra/terraform/envs/local       # DAENAMU Helm release 배포
```

수동 또는 별도 준비로 남기는 작업:

```text
Harbor 설치/기동
Docker image build/push 자동화는 향후 Jenkins에서 담당
Jaeger/Prometheus/Grafana 설치
```

## 3. 사용 시나리오
### 전체 흐름
1. 사용자가 드라마를 클릭하면 다음과 같은 API 호출 흐름이 발생한다.
2. drama-service가 초기 요청을 수신한다.
3. episode-service로 회차 정보를 요청한다.
4. 이후 stream-service에 S3의 Pre-signed URL을 요청한다.
5. 이 전체 흐름은 Envoy Proxy를 통해 추적되어 Jaeger에서 시각화된다.

```
GET /dramas         # 모든 드라마, 회차. 스트리밍 URL 조회
GET /dramas/{id}    # 특정 드라마의 상세 정보 조회
```

## 4. 아키텍처 및 관측 (Observability)
### 인프라 구성 흐름
1. Terraform을 통해 AWS 주요 리소스 구성
   - VPC, Subnet, IAM Role, EKS 클러스터, OIDC Provider 등
2. Kubernetes의 ServiceAccount에 IAM Role을 연결하는 IRSA를 구한하여 S3, ALB 등 AWS 리소스에 Pod 단위로 권한을 부여한다.
3. Helm을 통해 주요 관측 도구를 클러스터에 설치한다.
   - AWS ALB Controller (Ingress 트래픽 관리)
   - Istio (서비스 메시 및 라우팅)
   - Jaeger (추적)
   - Prometheus & Grafana (메트릭 수집 및 시각화 대시보드)
4. drama, episode, stream 서비스는 각기 독립된 Helm Chart로 배포되며 Istio로 연결된다.
   - Istio Gateway가 AWS ALB로부터의 트래픽 수신
   - VirtualService가 트래픽을 drama > episode > stream으로 분산
   - 모든 Pod에는 Envoy Sidecar가 붙어 트레이스를 수집
   - 트레이스는 Jaeger로 전송
   - 메트릭은 Prometheus로 수집되고 Grafana에서 시각화
   - 인프라는 Terraform으로 구성되고 Helm과 Github Actions로 배포된다.

### IRSA 구성
IRSA(IAM Roles for Service Accounts)를 통해 각 서비스에 필요한 AWS 권한(S3 접근, ALB 권한 등)을 안전하게 부여했다.
Terraform을 통해 OIDC 연결 및 IAM 설정을 자동화하고, Helm Chart 내에서 해당 IAM role이 지정된 ServiceAccount를 사용하도록 구성했다. 
