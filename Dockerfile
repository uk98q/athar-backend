# Cobalt API (imputnet/cobalt) pinned to a known commit, run as a private, key-protected instance.
FROM node:24-alpine
ENV PNPM_HOME="/pnpm"
ENV PATH="/pnpm:$PATH"
RUN apk add --no-cache git python3 alpine-sdk
WORKDIR /src
ARG COBALT_COMMIT=a636575b09de1fc55d9b8cd98cac88f5f2f16b42
RUN git clone https://github.com/imputnet/cobalt.git . && git checkout ${COBALT_COMMIT}
RUN corepack enable && pnpm install --prod --frozen-lockfile
RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api && cp -r /src/.git /prod/api/.git
WORKDIR /prod/api
ENV API_LISTEN_ADDRESS=0.0.0.0
ENV API_PORT=10000
ENV API_AUTH_REQUIRED=1
ENV API_KEY_URL=file:///tmp/keys.json
ENV RATELIMIT_MAX=60
ENV TUNNEL_RATELIMIT_MAX=120
ENV CORS_WILDCARD=1
USER node
EXPOSE 10000
CMD ["sh", "-c", "printf '%s' \"$COBALT_KEYS_JSON\" > /tmp/keys.json && exec node src/cobalt"]
