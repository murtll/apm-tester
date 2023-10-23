FROM --platform=linux/amd64 golang:1.21.1-alpine AS BUILDER

WORKDIR /usr/src/apm-tester

RUN apk add --no-cache ca-certificates && update-ca-certificates

COPY go.* ./
RUN go mod download

COPY . .

ENV GOARCH="amd64" \
    GOOS="linux" \
    GOHOSTARCH="arm64" \
    GOHOSTOS="darvin"
# idk why with any other GOHOSTOS build fails on apple m2

RUN go build -o /apm-tester main.go


FROM --platform=linux/amd64 scratch

ARG APP_VERSION 0.1.0
ENV APP_VERSION=$APP_VERSION
LABEL app-version=$APP_VERSION

WORKDIR /var/lib/apm-tester

COPY --from=BUILDER /apm-tester /usr/bin/
COPY --from=BUILDER /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT ["/usr/bin/apm-tester"]