FROM golang:1.15.1 AS build-env

ENV CGO_ENABLED 0
ENV GOOS "linux"
ENV GOARCH "amd64"
ADD . /gin_scaffold

WORKDIR /gin_scaffold
RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN go build  -o ./bin/gin_scaffold  main.go

FROM alpine:3.9 as builder

RUN set -ex; \
  apk add --no-cache libcap \
                        libpcap-dev \
  && apk add --virtual .deps build-base \
                          linux-headers \
                          git \
                          clang \
                          clang-dev 
RUN  git clone https://github.com/robertdavidgraham/masscan.git \
  && cd masscan \
  && make

FROM jovistar/service-base:latest

WORKDIR /

RUN apk add ca-certificates && \
    apk add --no-cache libpcap-dev  &&\
    apk add libssh2 --no-cache && \
	apk add nmap && \
	rm -rf /var/cache/apk/* 

EXPOSE 8023

LABEL org.opencontainers.image.title="nmap" \
    org.opencontainers.image.description="Nmap integration for wondersoft" \
    org.opencontainers.image.authors="liu.huidong" 

COPY --from=builder /masscan/bin/masscan /bin/masscan
COPY --from=build-env /gin_scaffold/bin/gin_scaffold /

COPY run.sh /run.sh
RUN chmod +x /gin_scaffold && chmod +x /run.sh

CMD  [ "/run.sh" ]
