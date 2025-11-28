import path from 'path'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

const entry = path.resolve(__dirname, 'frontend/entrypoints/application.jsx')

export default defineConfig(() => ({
  plugins: [react()],
  build: {
    manifest: true,
    outDir: 'public/vite',
    emptyOutDir: true,
    rollupOptions: {
      input: entry,
      output: {
        entryFileNames: 'assets/[name].js',
        chunkFileNames: 'assets/[name].js',
        assetFileNames: 'assets/[name].[ext]',
      },
    },
  },
  server: {
    origin: 'http://localhost:5173',
  },
}))
