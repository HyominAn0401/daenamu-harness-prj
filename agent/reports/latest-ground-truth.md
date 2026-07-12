Ground Truth 추출 결과

서비스 정보:
- catalog: port 8080, APIs GET /api/catalog/dramas, GET /api/catalog/dramas/{dramaId}, downstream episode
- episode: port 8081, APIs GET /api/episodes, GET /api/episodes/{episodeId}, downstream playback
- playback: port 8082, APIs GET /api/playback/{episodeId}, downstream -

호출 흐름:
- frontend -> catalog -> episode -> playback

근거 파일:
- backend/catalog/src/main/java/com/daenamu/catalog/controller/CatalogController.java
- backend/catalog/src/main/resources/application.properties
- backend/episode/src/main/java/com/daenamu/episode/controller/EpisodeController.java
- backend/episode/src/main/resources/application.properties
- backend/playback/src/main/java/com/daenamu/playback/controller/PlaybackController.java
- backend/playback/src/main/resources/application.properties

Helm 배포 정보:
- catalog: image hub.daenamu.local:8083/daenamu/catalog:local, service port 8080, targetPort 8080
- episode: image hub.daenamu.local:8083/daenamu/episode:local, service port 8081, targetPort 8081
- playback: image hub.daenamu.local:8083/daenamu/playback:local, service port 8082, targetPort 8082
- frontend: image hub.daenamu.local:8083/daenamu/frontend:local, service port 80, targetPort 80

Terraform 구성 파일:
- infra/terraform/envs/local/main.tf
- infra/terraform/envs/local/outputs.tf
- infra/terraform/envs/local/variables.tf
- infra/terraform/envs/local-kind/main.tf
- infra/terraform/envs/local-kind/outputs.tf
- infra/terraform/envs/local-kind/variables.tf
- infra/terraform/modules/daenamu-helm/main.tf
- infra/terraform/modules/daenamu-helm/outputs.tf
- infra/terraform/modules/daenamu-helm/variables.tf
- infra/terraform/modules/kind-cluster/main.tf
- infra/terraform/modules/kind-cluster/outputs.tf
- infra/terraform/modules/kind-cluster/variables.tf
- infra/terraform/modules/observability/main.tf
- infra/terraform/modules/observability/outputs.tf
- infra/terraform/modules/observability/variables.tf
