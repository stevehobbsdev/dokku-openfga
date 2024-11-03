FROM dokku/dokku:latest

WORKDIR /plugins

ARG PLUGIN_NAME="openfga"
ARG GO_VERSION="1.23"

# Golang gets installed to /usr/lib/go-1.23
ENV PATH="$PATH:/usr/lib/go-${GO_VERSION}/bin"
ENV PLUGIN_NAME=${PLUGIN_NAME}
ENV DOKKU_PLUGINS_ROOT=/var/lib/dokku/plugins
ENV PLUGIN_ENV=dev

RUN apt-get update && apt-get install -y make golang-${GO_VERSION}

COPY go.mod /plugins/${PLUGIN_NAME}/go.mod
COPY go.sum /plugins/${PLUGIN_NAME}/go.sum

# Cache dependencies
RUN pushd ${PLUGIN_NAME} && go mod download && popd

COPY . /plugins/${PLUGIN_NAME}
COPY ./support/Makefile /plugins/${PLUGIN_NAME}/Makefile

RUN git config --global user.email "dokku@localhost" && \
  git config --global user.name "Dokku" && \
  pushd ${PLUGIN_NAME} && \
  git init && \
  git add . && \
  git commit -m "Initial commit" && \
  popd

SHELL ["/bin/bash", "-c", "/usr/local/bin/.dev"]
