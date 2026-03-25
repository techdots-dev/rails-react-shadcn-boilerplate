// Placeholder service worker to satisfy /sw.js requests during development.
// Customize this file when adding offline support or push notifications.
self.addEventListener('install', () => {
  // Skip waiting to activate immediately after installation.
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  // Claim clients so the service worker starts controlling pages right away.
  event.waitUntil(self.clients.claim());
});