ARG GO_IMAGE=golang:1.24-alpine
ARG RUNTIME_IMAGE=alpine:3.21

FROM node:20-alpine AS loading-stage
WORKDIR /loading
COPY scripts/loading-server.js scripts/loading-page.html scripts/error-page.html ./

FROM ${GO_IMAGE} AS go-stage
RUN apk add --no-cache bash git curl jq

FROM ${RUNTIME_IMAGE}
RUN apk add --no-cache bash git curl jq nodejs npm
COPY --from=go-stage /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:${PATH}"
COPY --from=loading-stage /loading /runner/
WORKDIR /runner
COPY scripts/docker-entrypoint.sh ./
RUN chmod +x /runner/docker-entrypoint.sh
VOLUME /usercontent
ENV PORT=8080
ENV CGO_ENABLED=0
EXPOSE 8080
ENTRYPOINT ["/runner/docker-entrypoint.sh"]
