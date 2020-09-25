FROM golang:1.15.2 AS builder

COPY . /build

RUN cd /build && \
    CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} go build -ldflags="-w -s" -o bmwcd_exporter .

# Real image
FROM scratch

COPY --from=builder /build/bmwcd_exporter /bin/
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 9744

CMD ./app -username "$USERNAME" -password "$PASSWORD"

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:9744/
