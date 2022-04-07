FROM --platform=linux/arm64 alpine:3 AS add-arm64
ENV OCTANT_VERSION=0.25.1
ENV OCTANT_CHECKSUM=a3eb4973a0c869267e3916bd43e0b41b2bbc73b898376b795a617299c7b2a623
ADD https://github.com/vmware-tanzu/octant/releases/download/v${OCTANT_VERSION}/octant_${OCTANT_VERSION}_Linux-arm64.tar.gz /tmp/octant.tar.gz

FROM --platform=linux/arm64 alpine:3 AS add-amd64
ENV OCTANT_VERSION=0.25.1
ENV OCTANT_CHECKSUM=b12bb6752e43f4e0fe54278df8e98dee3439c4066f66cdb7a0ca4a1c7d8eaa1e
ADD https://github.com/vmware-tanzu/octant/releases/download/v${OCTANT_VERSION}/octant_${OCTANT_VERSION}_Linux-64bit.tar.gz /tmp/octant.tar.gz

ARG TARGETARCH

FROM add-${TARGETARCH} as builder
RUN sha256sum /tmp/octant.tar.gz | grep "$OCTANT_CHECKSUM" && \
    if [[ $? -ne 0 ]]; then echo "Bad checksum"; exit 444; fi && \
    tar -xzvf /tmp/octant.tar.gz --strip 1 -C /opt

FROM alpine:3
RUN addgroup -g 2000 -S octant && adduser -u 1000 -h /home/octant -G octant -S octant
COPY --from=builder /opt/octant /opt/octant
COPY docker-entrypoint.sh /
ENTRYPOINT /docker-entrypoint.sh