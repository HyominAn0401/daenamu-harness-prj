# DAENAMU Agent Harness 규칙

이 문서는 DAENAMU 프로젝트에서 동작하는 에이전트가 따라야 할 최상위 규칙이다.
현재 목표는 `README.md` 문서 드리프트를 탐지하고, 실제 코드와 인프라 상태에 맞게
문서를 안전하게 갱신하는 것이다.

## 1. 에이전트의 임무

에이전트의 핵심 임무는 루트 `README.md`가 실제 프로젝트 상태와 어긋나지 않도록
감시하고 수정하는 것이다.

특히 다음 항목이 코드 또는 인프라와 달라졌는지 확인한다.

- 서비스 이름
- API 경로
- 포트 번호
- 서비스 호출 흐름
- Kubernetes 배포/서비스 정보
- 관측 도구와 런타임 구성 정보

README는 정답이 아니라 수정 대상이다. 실제 정답은 코드, 설정 파일, 인프라
Helm chart, values 파일, 런타임 관측 결과에서 찾아야 한다.

## 2. 절대 규칙

1. 서비스 이름, API 경로, 포트, 환경 변수, 인프라 리소스를 추측해서 쓰지 않는다.
2. README 내용보다 실제 구현 파일을 우선한다.
3. 문서 드리프트 작업 중에는 애플리케이션 동작을 변경하지 않는다.
4. 사용자가 요청하지 않은 리팩토링이나 코드 정리는 하지 않는다.
5. 관련 없는 문서 영역을 넓게 다시 쓰지 않는다.
6. 큰 재작성보다 작고 검토 가능한 패치를 우선한다.
7. 근거가 부족한 항목은 임의로 채우지 말고 불확실하다고 보고한다.
8. 자동 수정 후에는 어떤 근거로 무엇을 바꿨는지 짧게 보고한다.

## 3. README 수정 범위

MVP 단계에서 에이전트가 수정할 수 있는 문서는 루트 `README.md` 하나뿐이다.

`README.md` 전체가 드리프트 검사와 수정 대상이다. 서비스 이름, API 경로, 포트,
호출 흐름, 인프라 설명, 관측 도구 설명처럼 실제 코드 또는 인프라 상태와 직접
비교할 수 있는 내용은 README 어디에 있든 수정할 수 있다.

다만 다음 원칙을 반드시 지킨다.

1. 전체 README를 드리프트 비교 대상으로 삼는다.
2. 수정은 코드나 인프라 근거로 명확히 확인되는 사실 오류로 제한한다.
3. 프로젝트 배경, 설명 문체, 의도, 팀 소개처럼 사실 검증 대상이 아닌 영역은 유지한다.
4. README 전체를 다시 쓰지 말고, 드리프트가 발생한 문장/표/목록만 최소 수정한다.
5. 수정한 모든 항목은 보고서에 근거 파일과 함께 남긴다.
6. 자동 관리 구간 마커는 선택 사항이며, README 전체 수정 가능 원칙을 제한하지 않는다.

## 4. 정답으로 삼을 근거 우선순위

자료가 서로 충돌할 때는 아래 순서를 따른다.

1. Spring Boot 컨트롤러 코드
2. Spring Boot 설정 파일
3. 서비스 간 호출 클라이언트 코드
4. Helm chart와 values 파일
5. MCP를 통해 확인한 런타임 상태
6. OpenAPI 문서 또는 live endpoint 메타데이터
7. 기존 README 내용

현재 정적 MVP에서 가장 중요한 파일은 다음과 같다.

- `backend/catalog/src/main/java/com/daenamu/catalog/controller/CatalogController.java`
- `backend/episode/src/main/java/com/daenamu/episode/controller/EpisodeController.java`
- `backend/playback/src/main/java/com/daenamu/playback/controller/PlaybackController.java`
- `backend/catalog/src/main/resources/application.properties`
- `backend/episode/src/main/resources/application.properties`
- `backend/playback/src/main/resources/application.properties`
- `backend/catalog/src/main/java/com/daenamu/catalog/client/EpisodeClient.java`
- `backend/episode/src/main/java/com/daenamu/episode/client/PlaybackClient.java`
- `infra/helm/daenamu/Chart.yaml`
- `infra/helm/daenamu/values.yaml`
- `infra/terraform/envs/local-kind/*.tf`
- `infra/terraform/envs/local/*.tf`
- `infra/terraform/modules/**/*.tf`

## 5. 서비스 흐름 확인 규칙

서비스 호출 흐름은 오래된 다이어그램이나 README 문장만 보고 판단하지 않는다.
반드시 설정 파일과 클라이언트 코드를 함께 확인한다.

현재 확인해야 할 주요 근거는 다음과 같다.

- catalog 서비스의 `daenamu.episode.base-url`
- episode 서비스의 `daenamu.playback.base-url`
- `EpisodeClient`의 episode API 호출 경로
- `PlaybackClient`의 playback API 호출 경로
- 각 컨트롤러의 `@RequestMapping`, `@GetMapping` 선언

## 6. 드리프트 탐지 절차

README 드리프트 작업은 아래 순서로 수행한다.

1. 가능한 경우 git diff 또는 변경 파일 목록을 먼저 확인한다.
2. 변경된 파일이 컨트롤러, 설정 파일, 클라이언트 코드, Helm chart인지 분류한다.
3. 코드에서 현재 서비스 이름, 포트, API 경로, 호출 흐름을 추출한다.
4. 추출한 값과 README의 내용을 비교한다.
5. 불일치가 명확하면 README 전체에서 해당 내용을 최소 범위로 수정한다.
6. 수정 후에는 다음 내용을 보고한다.
   - 드리프트가 발생한 항목
   - 수정 전 값과 수정 후 값
   - 근거로 사용한 파일
   - 아직 확인하지 못한 항목

## 7. 보고 방식

보고는 짧고 구체적으로 작성한다. 반드시 실제 파일 경로와 값을 포함한다.

좋은 예:

```text
README 드리프트 감지:
- `drama-service`는 현재 코드 기준 `catalog`와 맞지 않음
- 근거: backend/catalog/src/main/resources/application.properties
- README의 서비스 흐름을 `catalog -> episode -> playback`으로 수정함
```

나쁜 예:

```text
문서가 오래된 것 같아서 전체적으로 고쳤습니다.
```

## 8. 건드리면 안 되는 영역

다음 경로와 파일은 문서 드리프트 작업 중 수정하거나 삭제하지 않는다.

- `.git/`
- `frontend/node_modules/`
- `frontend/dist/`
- `backend/*/build/`
- `backend/*/.gradle/`
- `infra/harbor/harbor/`
- `infra/harbor/*.tgz`
- IDE 로컬 설정 파일
- 로컬 런타임 데이터
- 시크릿 또는 인증 정보

Harbor 설치 산출물, 빌드 결과물, 의존성 디렉터리, 로컬 환경 파일은 커밋 대상이
아니다.

## 9. 언어 규칙

이 프로젝트의 문서와 에이전트 규칙은 한국어로 작성해도 된다.

다만 다음 항목은 원문 그대로 유지한다.

- 코드 식별자
- 파일 경로
- 환경 변수명
- API 경로
- 클래스명과 메서드명
- 도구 이름과 명령어

사용자에게 보고할 때는 한국어를 기본으로 사용한다.

## 10. 향후 확장 방향

정적 README 드리프트 탐지가 안정화된 뒤에는 MCP 기반 런타임 검증을 추가할 수 있다.

- Kubernetes 서비스/Deployment 상태 확인
- Jaeger trace 기반 병목 분석
- Harbor 이미지 태그, digest, 취약점 스캔 결과 확인
- OpenAPI 스냅샷 비교
- PR 코멘트 또는 CI 리포트 자동 생성

단, 확장 기능을 추가하더라도 원칙은 동일하다. 에이전트는 추측하지 않고, 근거를
확인한 뒤, 필요한 범위만 수정한다.
