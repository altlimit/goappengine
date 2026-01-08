# Use the latest Debian Slim (Bookworm)
FROM debian:bookworm-slim

# Environment Variables
ENV GOPATH=/root/go \
    CLOUDSDK_PYTHON=/opt/venv/bin/python3 \
    # We MUST include the SDK's platform folders in PYTHONPATH so it finds its own stubs
    PYTHONPATH=/opt/venv/lib/python3.11/site-packages:/root/google-cloud-sdk/platform/google_appengine:/root/google-cloud-sdk/lib \
    PATH=/opt/venv/bin:/go/bin:/usr/local/go/bin:/root/google-cloud-sdk/bin:/root/google-cloud-sdk/platform/google_appengine:$PATH \
    DEBIAN_FRONTEND=noninteractive

ARG GOLANG_VERSION=1.25.1

# 1. Install system dependencies
RUN apt-get update -yq && apt-get install -yq \
    curl wget gnupg ca-certificates build-essential lsb-release \
    python3 python3-dev python3-venv python-is-python3

# 2. Setup Virtual Environment and gRPC
# We install exactly what the SDK needs to avoid the "service definition not found" error
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install grpcio==1.60.0 grpcio-tools==1.60.0 protobuf==4.25.1

# 3. Install JDK 21
RUN mkdir -p /etc/apt/keyrings && \
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc && \
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/adoptium.list && \
    apt-get update -yq && apt-get install -yq temurin-21-jdk

# 4. Install Go 1.25
RUN wget https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    rm go${GOLANG_VERSION}.linux-amd64.tar.gz

# 5. Install Google Cloud SDK
RUN curl https://sdk.cloud.google.com > install.sh && \
    bash install.sh --disable-prompts --install-dir=/root && \
    /root/google-cloud-sdk/bin/gcloud components install \
    cloud-datastore-emulator app-engine-go app-engine-python beta -q && \
    rm install.sh

# 6. Patch dev_appserver for Go 1.25
RUN sed -i "s/'go123',/'go123','go125',/g" /root/google-cloud-sdk/platform/google_appengine/google/appengine/tools/devappserver2/http_runtime.py

VOLUME ["/root/.config"]
WORKDIR /root