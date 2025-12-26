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

## Building assets
Run `npm run build` to output compiled assets to `app/assets/builds`. The Rails asset pipeline will serve them in production when `RAILS_SERVE_STATIC_FILES=1` is set.

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
