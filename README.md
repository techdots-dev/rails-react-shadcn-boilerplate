# Rails 8 + React Monolith

The repository now contains a single Rails 8 application in the `app/` directory. Rails renders the React client directly, so there is no separate backend/frontend split.

## Layout
- `app/` – Rails root containing controllers, models, views, and the React source under `frontend/`.
- `app/frontend/` – React application powered by Vite. Assets are built into `app/public/vite/`.
- `app/config/` – Rails configuration, including routes for both the API and the React entry point.

## Getting Started
1. `cd app`
2. Install Ruby gems: `bundle install`
3. Install Node dependencies: `npm install`
4. Set up the database: `bin/rails db:prepare`

## Running the App
- Start the Rails server: `bin/rails server`
- In another terminal, start the Vite dev server so Rails can load unbundled assets: `npm run dev -- --host`

Rails will render the React root at `/` and fall back to the React app for other HTML routes. For production or test environments, build the assets once with `npm run build`; Rails will serve the compiled files from `public/vite`.

## Tests and Linting
From the `app/` directory:

- Run the Rails test suite: `bin/rails test`
- Lint Ruby code: `bin/rubocop -f github`

## Deployment Notes
Ensure `npm run build` is executed during your deploy process so the React assets are available in `public/vite`, and set `RAILS_SERVE_STATIC_FILES=1` so Rails serves the compiled files.
