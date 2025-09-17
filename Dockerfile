FROM debian:bullseye-slim

ENV GOPATH=/root/go \
    PATH=/go/bin:/usr/local/go/bin:/root/google-cloud-sdk/bin:/root/google-cloud-sdk/platform/google_appengine:$PATH \
    CLOUDSDK_PYTHON=/usr/bin/python3 \
    DEBIAN_FRONTEND=noninteractive

ARG GOLANG_VERSION=1.25.1

RUN apt update -yq && apt install curl python python-dev build-essential python3 wget default-jre -yq
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py && python2 get-pip.py
RUN pip install grpcio
RUN curl https://sdk.cloud.google.com > install.sh && \
    bash install.sh --disable-prompts
RUN wget https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz

RUN gcloud components install cloud-datastore-emulator app-engine-go app-engine-python beta -q
RUN sed -i "s/'go121',/'go121','go125',/g" /root/google-cloud-sdk/platform/google_appengine/google/appengine/tools/devappserver2/http_runtime.py
VOLUME ["/root/.config"]