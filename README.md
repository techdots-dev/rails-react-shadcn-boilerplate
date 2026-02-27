<p align="center">
  <a href="https://techdots.dev">
    <img src="public/66e82263582d7179b492b755_Logo.svg" alt="Project Logo" width="180" />
  </a>
</p>

# Rails + React application

This Rails 8 application renders the React SPA directly from Rails. The React source lives in `app/assets/javascript/` and is bundled with esbuild into `app/assets/builds`.

## Setup
1. Install Ruby gems: `bundle install`
2. Install Node 20.19+ (React Router 7 engines require it). With `nvm`, run `nvm install && nvm use` (project includes `.nvmrc`); with `asdf`, run `asdf install` (project includes `.node-version`).
3. Install Node dependencies: `npm install`
4. Prepare the database: `bin/rails db:prepare`

## Development
- Start both Rails and the esbuild watcher with a single command: `bin/dev`. This launches `npm run dev -- --watch` alongside `bin/rails server` so the frontend assets rebuild automatically.
- If you prefer to run esbuild yourself, start `npm run dev -- --watch` in one shell and `bin/rails server` in another.
- Built assets live in `app/assets/builds` and are served through the Rails asset pipeline. Delete the folder if you want a clean rebuild.

## Running locally
After setup, run `bin/dev` and visit `http://localhost:3000`. The Rails server serves the React SPA and API from the same origin.

## Docker setup
The project includes environment-specific Docker Compose files and shared Docker assets:

- `docker/base/`: shared Dockerfile + entrypoint used by all environments.
- `docker/environment/development|staging|production/`: virtual host service config (Caddy).
- `docker-compose.yml`: development stack (required default filename).
- `docker-compose.stage.yml`: staging stack.
- `docker-compose.production.yml`: production stack.

Each stack includes the following services:

- `web`: Rails app
- `worker`: Solid Queue worker (`bin/jobs`)
- `database`: PostgreSQL
- `redis`: Redis
- `virtual_host`: Caddy reverse proxy for web traffic

### Start each environment
- Development: `docker compose up --build`
- Staging: `BACKEND_DATABASE_PASSWORD=your_password docker compose -f docker-compose.stage.yml up --build`
- Production: `BACKEND_DATABASE_PASSWORD=your_password docker compose -f docker-compose.production.yml up --build`

For staging and production compose files, `BACKEND_DATABASE_PASSWORD` is required and is read from the environment (rather than hard-coded in compose).

## Local auth flow (cookie-based)
This app uses Rails signed, httpOnly cookies for session authentication (no JWTs and no localStorage tokens).

- `POST /sign_up` creates a user and returns `{id,email,verified}`.
- `POST /sign_in` sets a signed `session_token` cookie and returns `{id,email,verified}`.
- `GET /current_user` returns `{id,email,verified}` for an authenticated request, otherwise `401`.
- `DELETE /sign_out` clears the cookie and removes the current session (returns `204`).

Frontend requests send cookies by default via `credentials: "include"` in the API wrapper. Use `GET /current_user` to check authentication state.

## Building assets
Run `npm run build` to output compiled assets to `app/assets/builds`. The Rails asset pipeline will serve them in production when `RAILS_SERVE_STATIC_FILES=1` is set.

## Monitoring
The app integrates Rollbar on both the Rails backend and the React client. The frontend reads its access
token from the backend via `GET /rollbar`, so it should only be configured on the server side.

Configure the following environment variables or Rails credentials:

- `ROLLBAR_SERVER_ACCESS_TOKEN`: Server-side Rollbar access token for Rails error reporting.
- `ROLLBAR_CLIENT_ACCESS_TOKEN`: Client-side Rollbar access token returned to the React app.
- `ROLLBAR_ENVIRONMENT`: Rollbar environment name (defaults to `Rails.env`).
- `ROLLBAR_CODE_VERSION`: Optional release identifier for source maps and deployments.

## Tests
- Run all Rails tests: `bin/rails test`
- Lint Ruby files: `bin/rubocop -f github`

## What's RRSB?
RRSB (Rails + React Starter Boilerplate) is a starter kit for building Rails 8 applications with a React single-page app front end. It pairs Rails for backend APIs and tooling with a modern React stack bundled by esbuild so you can get from idea to production quickly.

## Contributing
1. Fork the repository and create your branch from `main`.
2. Make your changes, keeping formatting and tests in mind.
3. Ensure tests and linters pass.
4. Open a pull request describing the change and its motivation.

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.

## About techdots
techdots (https://techdots.dev) is a product and engineering studio that partners with teams to design, build, and scale modern web applications. We focus on pragmatic delivery, clean architecture, and long-term maintainability, providing end-to-end support from discovery and UX to implementation, infrastructure, and ongoing iteration.
