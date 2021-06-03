FROM alpine:3 AS builder

ENV OCTANT_VERSION=0.20.0
ENV OCTANT_CHECKSUM=6043f9907e47b0d7b8bd0682fbffbd4912f1e5da61069ac4d7c748ba7b39cc65

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

WORKDIR /tmp

RUN addgroup -g 2000 -S octant && adduser -u 1000 -h /home/octant -G octant -S octant

COPY --from=builder /opt/octant /opt/octant
COPY docker-entrypoint.sh /

ENTRYPOINT /docker-entrypoint.sh
