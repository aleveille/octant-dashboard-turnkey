FROM alpine:3 AS builder

ENV OCTANT_VERSION=0.12.1
ENV OCTANT_CHECKSUM=b56ca09fb92314eb6a7b1a0ddcc65b582990e3fdef6e2a996cacd4a24b4e54bf

RUN apk update && \
    apk add \
      ca-certificates \
      xdg-utils \
      && \
    wget --quiet --output-document /tmp/octant.tar.gz \
        https://github.com/vmware-tanzu/octant/releases/download/v${OCTANT_VERSION}/octant_${OCTANT_VERSION}_Linux-64bit.tar.gz && \
    sha256sum /tmp/octant.tar.gz | grep "$OCTANT_CHECKSUM" && \
    if [[ $? -ne 0 ]]; then echo "Bad checksum"; exit 444; fi && \
    tar -xzvf /tmp/octant.tar.gz --strip 1 -C /opt

COPY docker-entrypoint.sh /


FROM alpine:3

COPY --from=builder /opt/octant /opt/octant
COPY docker-entrypoint.sh /

ENTRYPOINT /docker-entrypoint.sh
