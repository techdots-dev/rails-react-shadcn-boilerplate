# Rails + React application

This Rails 8 application renders the React SPA directly from Rails. The React source lives in `frontend/` and is bundled with Vite into `public/vite` for production/test runs.

## Setup
1. Install Ruby gems: `bundle install`
2. Install Node dependencies: `npm install`
3. Prepare the database: `bin/rails db:prepare`

## Development
- Start the Rails server: `bin/rails server`
- In a separate terminal, start the Vite dev server so Rails can load unbundled assets: `npm run dev -- --host`

## Building assets
Run `npm run build` to output compiled assets to `public/vite`. Rails reads the manifest from that directory when not using the dev server. Set `RAILS_SERVE_STATIC_FILES=1` in production so the compiled files are served.

## Tests
- Run all Rails tests: `bin/rails test`
- Lint Ruby files: `bin/rubocop -f github`
