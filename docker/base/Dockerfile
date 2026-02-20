# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.3.4
FROM ruby:${RUBY_VERSION}-slim

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      curl \
      git \
      libjemalloc2 \
      libpq-dev \
      libvips \
      nodejs \
      npm \
      postgresql-client && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

ENV BUNDLE_PATH=/usr/local/bundle \
    RAILS_LOG_TO_STDOUT=1

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

COPY docker/base/entrypoint.sh /usr/local/bin/app-entrypoint
RUN chmod +x /usr/local/bin/app-entrypoint

ENTRYPOINT ["app-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
