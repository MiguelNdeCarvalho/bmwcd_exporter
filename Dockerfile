FROM golang:1.15.2 AS builder

COPY . /build

RUN cd /build && \
    CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} go build -ldflags="-w -s" -o bmwcd_exporter .

# Real image
FROM ubuntu:focal

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install ca-certificates -y && \
    apt-get clean && \
    rm -rf /tmp/*  \
	/var/lib/apt/lists/* \
	/var/tmp/*

COPY --from=builder /build/app .

EXPOSE 9744

CMD ./app -username "$USERNAME" -password "$PASSWORD"

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:9744/
