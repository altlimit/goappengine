FROM debian:bullseye-slim

ENV GOPATH=/root/go \
  PATH=/go/bin:/usr/local/go/bin:/root/google-cloud-sdk/bin:/root/google-cloud-sdk/platform/google_appengine:$PATH \
  CLOUDSDK_PYTHON=/usr/bin/python3 \
  DEBIAN_FRONTEND=noninteractive

ARG GOLANG_VERSION=1.20.5

RUN apt update -yq && apt upgrade -yq && apt install curl python python3 wget -yq
RUN curl https://sdk.cloud.google.com > install.sh && \
  bash install.sh --disable-prompts
RUN wget https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
  rm -rf /usr/local/go && tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz

RUN gcloud components install cloud-datastore-emulator app-engine-go app-engine-python -q

VOLUME ["/root/.config"]