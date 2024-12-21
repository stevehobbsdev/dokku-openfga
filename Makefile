# Change this to reflect your plugin, should be in sync with support/Dockerfile
PLUGIN_NAME=openfga

WORK_DIR=/plugins

GO_VERSION=1.23
GO_BUILD_IMAGE=golang:$(GO_VERSION)
GO_BUILD_ROOT=/go/src/github.com/stevehobbsdev/dokku-goplugin

DEV_IMAGE=elkdanger/dokku-goplugin:latest
DOKKU_START_WAIT=5
DOKKU_PLUGIN_PATH=/var/lib/dokku/plugins/available/$(PLUGIN_NAME)

DOCKER_BIN=docker
DOCKER_EXEC=$(DOCKER_BIN) exec -w $(WORK_DIR) -it $(DOCKER_CONTAINER_NAME)
DOCKER_CONTAINER_NAME=dokku-plugin-$(PLUGIN_NAME)

.PHONY: start shell stop run build-image install-plugin test-$(PLUGIN_NAME) test-help test-dokku

.PHONY: help
help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {gsub("\\\\n",sprintf("\n%22c",""), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

## -----------------------------------------
## Runtime
## -----------------------------------------

.PHONY: start
start: ## start the development docker container
	@$(DOCKER_BIN) run --rm \
		-w $(WORK_DIR) \
		--name $(DOCKER_CONTAINER_NAME) \
		--volume /var/run/docker.sock:/var/run/docker.sock \
		-d \
		$(DEV_IMAGE)
		
.PHONY: stop
stop: ## stop the development docker container
	@$(DOCKER_BIN) stop $(DOCKER_CONTAINER_NAME)

.PHONY: run
run: ## build the testing image, start the container, and install the plugin
	@$(MAKE) build-image
	$(DOCKER_BIN) ps -q --filter "name=$(DOCKER_CONTAINER_NAME)" | xargs -r $(DOCKER_BIN) stop
	@sleep 1
	@$(MAKE) start
	@echo "Waiting 5 sec for Dokku to start.."
	@sleep $(DOKKU_START_WAIT)
	@$(MAKE) install-plugin

.PHONY: shell
shell: ## start a shell in the container for testing
	@$(DOCKER_BIN) exec -it -w $(DOKKU_PLUGIN_PATH) $(DOCKER_CONTAINER_NAME) /bin/bash

.PHONY: sync
sync: ## copy the plugin source to the container and rebuild
	@docker cp src/ $(DOCKER_CONTAINER_NAME):/var/lib/dokku/plugins/available/$(PLUGIN_NAME)
	@docker cp support/Makefile $(DOCKER_CONTAINER_NAME):/var/lib/dokku/plugins/available/$(PLUGIN_NAME)
	@docker exec -it -w $(DOKKU_PLUGIN_PATH) $(DOCKER_CONTAINER_NAME) bash -c "make build clean-src"

## -----------------------------------------
## Build
## -----------------------------------------

.PHONY: lint
lint: ## run golangci-lint
	@golangci-lint run

.PHONY: build-image
build-image: ## build the testing docker image to test the plugin in a Dokku environment
	@$(DOCKER_BIN) build -f support/Dockerfile -t $(DEV_IMAGE) .

.PHONY: build-in-docker
build-in-docker: ## used by the `install` hook to install the plugin into a dokku instance
	@echo "Building plugin natively.."
	$(DOCKER_BIN) run --rm \
		-v $(PWD):$(GO_BUILD_ROOT) \
		-w $(GO_BUILD_ROOT) \
		-e CGO_ENABLED=0 \
		$(GO_BUILD_IMAGE) \
		bash -c "make build" || exit $?
	
.PHONY: clean-output
clean-output: ## cleans up the build artifacts
	rm -rf commands subcommands setup triggers report

.PHONY: install-plugin
install-plugin: ## install the plugin into the running Dokku instance
	@$(DOCKER_EXEC) bash -c "dokku plugin:install file://$(WORK_DIR)/$(PLUGIN_NAME)"

## -----------------------------------------
## Build
## -----------------------------------------

.PHONY: test-openfga
test-openfga: ## test the 'dokku openfga' command output
	@$(DOCKER_EXEC) dokku ${PLUGIN_NAME}

.PHONY: test-openfga-help
test-openfga-help: ## test the 'dokku openfga:help' command output
	@$(DOCKER_EXEC) dokku ${PLUGIN_NAME}:help

.PHONY: test-dokku
test-dokku: ## test the 'dokku' command output
	@$(DOCKER_EXEC) dokku

include support/Makefile