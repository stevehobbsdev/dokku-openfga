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

start:
	@$(DOCKER_BIN) run --rm \
		-w $(WORK_DIR) \
		--name $(DOCKER_CONTAINER_NAME) \
		--volume /var/run/docker.sock:/var/run/docker.sock \
		-d \
		$(DEV_IMAGE)
		
stop:
	@$(DOCKER_BIN) stop $(DOCKER_CONTAINER_NAME)

# Build the testing image, start the container, and install the plugin
run: 
	@$(MAKE) build-image
	$(DOCKER_BIN) ps -q --filter "name=$(DOCKER_CONTAINER_NAME)" | xargs -r $(DOCKER_BIN) stop
	@sleep 1
	@$(MAKE) start
	@echo "Waiting 5 sec for Dokku to start.."
	@sleep $(DOKKU_START_WAIT)
	@$(MAKE) install-plugin

# For development; copy the plugin source to the container and build it
sync:
	@docker cp src/ $(DOCKER_CONTAINER_NAME):/var/lib/dokku/plugins/available/$(PLUGIN_NAME)
	@docker cp support/Makefile $(DOCKER_CONTAINER_NAME):/var/lib/dokku/plugins/available/$(PLUGIN_NAME)
	@docker exec -it -w $(DOKKU_PLUGIN_PATH) $(DOCKER_CONTAINER_NAME) bash -c "make build clean-src"

# Builds the testing docker image to test the plugin in a Dokku environment
build-image:
	@$(DOCKER_BIN) build -f support/Dockerfile -t $(DEV_IMAGE) .

# Used by the `install` hook to install the plugin into a dokku instance
build-in-docker:
	@echo "Building plugin natively.."
	$(DOCKER_BIN) run --rm \
		-v $(PWD):$(GO_BUILD_ROOT) \
		-w $(GO_BUILD_ROOT) \
		-e CGO_ENABLED=0 \
		$(GO_BUILD_IMAGE) \
		bash -c "make build" || exit $?
	
# Cleans up the build artifacts
clean-output:
	rm -rf commands subcommands

# Starts a shell in the container for testing
shell:
	@$(DOCKER_BIN) exec -it -w $(DOKKU_PLUGIN_PATH) $(DOCKER_CONTAINER_NAME) /bin/bash

# Installs the plugin into the running Dokku instance
install-plugin:
	@$(DOCKER_EXEC) bash -c "dokku plugin:install file://$(WORK_DIR)/$(PLUGIN_NAME)"

# Various test functions that can be run in the container
test-$(PLUGIN_NAME):
	@$(DOCKER_EXEC) dokku ${PLUGIN_NAME}

test-$(PLUGIN_NAME)-help:
	@$(DOCKER_EXEC) dokku ${PLUGIN_NAME}:help

test-dokku:
	@$(DOCKER_EXEC) dokku

include support/Makefile