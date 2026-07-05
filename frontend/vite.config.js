import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api/catalog': 'http://localhost:8080',
      '/api/episodes': 'http://localhost:8081',
      '/api/playback': 'http://localhost:8082',
    },
  },
});
