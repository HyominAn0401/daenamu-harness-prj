# README.md 드리프트 탐지 및 자동 패치 Skill

이 skill은 DAENAMU Agent Harness의 정적 MVP 절차서다. 목적은 코드와 인프라
상태가 바뀌었을 때 루트 `README.md`가 실제 프로젝트와 어긋나는지 확인하고,
필요한 경우 최소 범위로 수정하는 것이다.

한국어로 작성해도 괜찮다. 단, 파일 경로, 클래스명, 환경 변수명, API 경로, 명령어,
코드 식별자는 원문 그대로 유지한다.

## 1. 적용 범위

이 skill은 다음 상황에서 사용한다.

- Spring Boot 컨트롤러가 변경된 경우
- `application.properties` 또는 환경 변수 기본값이 변경된 경우
- 서비스 간 호출 클라이언트 코드가 변경된 경우
- Kubernetes manifest가 추가되거나 변경된 경우
- README의 서비스 이름, API 경로, 포트, 호출 흐름이 실제 코드와 맞지 않는 경우

MVP 단계에서 자동 패치 대상은 루트 `README.md` 하나뿐이다. 단, README 내부에서는
특정 관리 구간만이 아니라 전체 문서가 드리프트 검사와 수정 대상이다.

## 2. 입력

가능하면 아래 정보를 입력으로 사용한다.

- `git diff`
- 변경 파일 목록
- 현재 루트 `README.md`
- 루트 `CLAUDE.md`
- 백엔드 컨트롤러 코드
- 백엔드 설정 파일
- 서비스 클라이언트 코드
- Kubernetes manifest, 존재하는 경우

변경 파일 목록이 없으면 전체 대상 파일을 스캔한다.

## 3. 정답 근거 우선순위

값이 서로 충돌하면 아래 순서대로 신뢰한다.

1. `backend/*/src/main/java/**/controller/*.java`
2. `backend/*/src/main/resources/application.properties`
3. `backend/*/src/main/java/**/client/*.java`
4. `infra/k8s/base/*.yaml` 또는 `infra/k8s/base/*.yml`
5. MCP를 통해 확인한 런타임 상태
6. OpenAPI 또는 live endpoint 메타데이터
7. 기존 `README.md`

README는 정답이 아니라 수정 대상이다.

## 4. 분석 대상 파일

현재 정적 MVP에서 우선 확인할 파일은 다음과 같다.

```text
backend/catalog/src/main/java/com/daenamu/catalog/controller/CatalogController.java
backend/episode/src/main/java/com/daenamu/episode/controller/EpisodeController.java
backend/playback/src/main/java/com/daenamu/playback/controller/PlaybackController.java
backend/catalog/src/main/resources/application.properties
backend/episode/src/main/resources/application.properties
backend/playback/src/main/resources/application.properties
backend/catalog/src/main/java/com/daenamu/catalog/client/EpisodeClient.java
backend/episode/src/main/java/com/daenamu/episode/client/PlaybackClient.java
```

`infra/k8s/base/`가 존재하면 그 안의 YAML도 함께 확인한다.

## 5. 추출해야 하는 정보

### 5.1 서비스 정보

각 서비스에서 다음 값을 추출한다.

- 서비스 디렉터리 이름
- `spring.application.name`
- `server.port`
- 주요 controller class
- base request mapping
- 하위 HTTP mapping

예시:

```text
service= catalog
spring.application.name= catalog
server.port= 8080
baseMapping= /api/catalog/dramas
methodMapping= GET /
methodMapping= GET /{dramaId}
```

### 5.2 API 경로

컨트롤러에서 다음 annotation을 확인한다.

- `@RequestMapping`
- `@GetMapping`
- `@PostMapping`
- `@PutMapping`
- `@PatchMapping`
- `@DeleteMapping`

base mapping과 method mapping을 합쳐 최종 API 경로를 만든다.

예시:

```text
@RequestMapping("/api/episodes")
@GetMapping("/{episodeId}")
=> GET /api/episodes/{episodeId}
```

`@GetMapping`처럼 값이 비어 있으면 base mapping 자체가 최종 경로다.

### 5.3 서비스 호출 흐름

서비스 간 호출 흐름은 설정 파일과 client 코드를 함께 확인한다.

확인 항목:

- `daenamu.episode.base-url`
- `daenamu.playback.base-url`
- `RestClient`의 `.uri(...)`
- 클라이언트 클래스 이름

현재 예상되는 흐름은 코드 근거로만 판단한다.

```text
catalog -> episode -> playback
```

### 5.4 인프라 정보

`infra/k8s/base/`가 존재하면 다음을 추출한다.

- `kind: Deployment`
- `kind: Service`
- metadata name
- labels
- container image
- container port
- service port
- targetPort

해당 디렉터리가 없으면 README에 Kubernetes 세부값을 새로 만들어 쓰지 않는다.
대신 "현재 repository에는 `infra/k8s/base`가 없다"라고 보고한다.

## 6. README 비교 절차

1. 루트 `README.md`를 읽는다.
2. `CLAUDE.md`의 규칙을 확인한다.
3. README 전체에서 실제 코드/인프라와 비교 가능한 문장을 찾는다.
4. 수정은 명확한 사실 오류에만 제한한다.
5. 다음 유형의 드리프트를 찾는다.
   - 서비스 이름 불일치
   - API path 불일치
   - port 불일치
   - 호출 흐름 불일치
   - 존재하지 않는 인프라 구성 설명
   - 현재 코드에 없는 옛 서비스명

## 7. 패치 원칙

패치는 다음 원칙을 지킨다.

1. 루트 `README.md`만 수정한다.
2. 코드나 설정 파일은 수정하지 않는다.
3. 검증 가능한 사실만 반영한다.
4. 문장 전체를 갈아엎기보다 필요한 문장, 목록, 표만 바꾼다.
5. README 전체를 자동 수정할 수 있지만, 각 수정에는 근거 파일이 있어야 한다.
6. 프로젝트 배경, 팀 설명, 의도적으로 남긴 역사적 설명은 함부로 삭제하지 않는다.
7. 불확실한 내용은 README에 쓰지 말고 리포트에 남긴다.

## 8. README 수정 예시

README 전체 수정이 가능하므로 반드시 관리 구간을 만들 필요는 없다. 다만 서비스 요약
표를 둘 경우에는 다음처럼 실제 코드 기준 값을 사용한다.

````markdown
| Service | Port | Main APIs | Downstream |
| --- | ---: | --- | --- |
| catalog | 8080 | `GET /api/catalog/dramas`, `GET /api/catalog/dramas/{dramaId}` | episode |
| episode | 8081 | `GET /api/episodes`, `GET /api/episodes/{episodeId}` | playback |
| playback | 8082 | `GET /api/playback/{episodeId}` | - |

```text
frontend -> catalog -> episode -> playback
```
````

주의: 위 예시는 현재 코드에서 확인 가능한 값과 맞는지 다시 검증한 뒤 사용한다.

## 9. 드리프트 리포트 형식

작업 후에는 다음 형식으로 리포트를 남긴다.

```text
README 드리프트 검사 결과

수정 여부:
- README.md 수정함 / 수정하지 않음

감지한 드리프트:
- 항목: 서비스 이름
  README 값: drama-service
  실제 값: catalog
  근거: backend/catalog/src/main/resources/application.properties

사용한 근거 파일:
- backend/catalog/src/main/java/com/daenamu/catalog/controller/CatalogController.java
- backend/catalog/src/main/resources/application.properties

불확실한 항목:
- infra/k8s/base 디렉터리가 없어 Kubernetes manifest 검증은 수행하지 못함
```

드리프트가 없으면 다음처럼 보고한다.

```text
README 드리프트 검사 결과

수정 여부:
- README.md 수정하지 않음

감지한 드리프트:
- 없음

사용한 근거 파일:
- ...
```

## 10. 실패 처리

다음 상황에서는 README를 자동 수정하지 않는다.

- README가 없거나 읽을 수 없는 경우
- 동일한 항목에 대해 코드 근거가 서로 충돌하는 경우
- API path를 안정적으로 추출할 수 없는 경우
- 사용자가 README 수정을 허용하지 않은 경우
- 수정 범위가 너무 넓어져 사실상 README 전체 재작성에 가까워지는 경우

이 경우에는 패치하지 말고 리포트만 작성한다.

## 11. 금지 사항

다음 작업은 하지 않는다.

- README 외 파일을 임의로 수정
- build output 삭제 또는 재생성
- Harbor runtime 파일 수정
- `node_modules` 수정
- `.git` 내부 수정
- 시크릿 또는 로컬 인증 정보 출력
- 근거 없는 아키텍처 다이어그램 생성
- 현재 repository에 없는 K8s/Jaeger/Harbor 상태를 있는 것처럼 작성

## 12. 향후 확장

정적 README 드리프트 탐지가 안정화되면 다음 skill로 분리할 수 있다.

- Kubernetes 상태 검증 skill
- Jaeger trace 병목 분석 skill
- Harbor image metadata 검증 skill
- OpenAPI snapshot 비교 skill
- PR comment 작성 skill

확장 skill도 동일하게 "근거 우선, 최소 수정, 불확실성 보고" 원칙을 따른다.
