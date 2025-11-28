import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import '../index.css'
import App from '../App.jsx'
import { initPostHog } from '../lib/posthog.js'

initPostHog()

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('root')
  if (!container) return

  createRoot(container).render(
    <StrictMode>
      <App />
    </StrictMode>,
  )
})
