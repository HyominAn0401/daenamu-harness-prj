# DAENAMU Frontend

React UI for testing the DAENAMU catalog -> episode -> playback call chain.

## Run

```bash
npm install
npm run dev
```

By default, Vite proxies API calls:

```text
/api/catalog  -> http://localhost:8080
/api/episodes -> http://localhost:8081
/api/playback -> http://localhost:8082
```

You can still override direct service URLs with `VITE_CATALOG_API_URL` and
`VITE_PLAYBACK_API_URL`.

Open:

```text
http://localhost:5173
```
