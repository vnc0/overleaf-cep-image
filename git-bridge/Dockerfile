# syntax=docker/dockerfile:1
# Overleaf git-bridge built from the pinned yu-i-i/overleaf-cep source so it
# can ship for amd64 and arm64 (quay.io/sharelatex/git-bridge is amd64 only).
# Mirrors Overleaf's own image: jar + envsubst + start scripts, user "node".
FROM --platform=$BUILDPLATFORM maven:3.9-eclipse-temurin-21 AS jar
WORKDIR /src
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn -q -B dependency:go-offline
COPY src src
RUN --mount=type=cache,target=/root/.m2 mvn -q -B package -DskipTests \
 && cp target/*jar-with-dependencies.jar /git-bridge.jar

FROM --platform=$BUILDPLATFORM golang:1.23-alpine AS envsubst
ARG TARGETOS TARGETARCH
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go install github.com/a8m/envsubst/cmd/envsubst@v1.4.2 \
 && (cp /go/bin/envsubst /envsubst 2>/dev/null || cp /go/bin/${TARGETOS}_${TARGETARCH}/envsubst /envsubst)

FROM eclipse-temurin:24-jre-alpine
RUN apk add --update --no-cache bash git sqlite procps htop net-tools jemalloc util-linux \
 && adduser -D node
ENV LD_PRELOAD=/usr/lib/libjemalloc.so.2 LANG=C.UTF-8
COPY --from=jar /git-bridge.jar /
COPY --from=envsubst /envsubst /opt/envsubst
COPY conf/envsubst_template.json /envsubst_template.json
COPY start.sh server-pro-start.sh /
RUN chmod +x /opt/envsubst /start.sh /server-pro-start.sh \
 && mkdir /conf && chown node:node /conf
USER node
CMD ["/start.sh"]
