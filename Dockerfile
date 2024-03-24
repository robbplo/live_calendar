# Builder
FROM hexpm/elixir:1.15.6-erlang-26.0.2-alpine-3.17.4

ARG APP_NAME=live_calendar

ENV MIX_ENV=prod TERM=xterm

WORKDIR /opt/app

RUN apk update \
  && apk add --no-cache git \
  && mix local.rebar --force \
  && mix local.hex --force

COPY . .

RUN mix do deps.get, deps.compile
RUN mix compile
RUN mix phx.digest
RUN mix release --overwrite \
  && mv _build/prod/rel/${APP_NAME} /opt/release \
  && mv /opt/release/bin/${APP_NAME} /opt/release/bin/${APP_NAME}

# Release
FROM alpine:3.17.4

RUN apk update \
  && apk add --no-cache bash openssl-dev libstdc++ ca-certificates git shadow \
  && apk add --upgrade zlib

ENV PORT=4000 REPLACE_OS_VARS=true

WORKDIR /opt/app

EXPOSE ${PORT}

COPY --from=0 /opt/release .

# Add and use non-root user (default::1005:1005)
RUN groupadd -g 1005 default
RUN useradd -s /bin/sh -d /opt/app -r -u 1005 -g default default
RUN chown default:default -R /opt/app

USER default

CMD ["./bin/live_calendar", "start"]
