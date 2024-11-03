# dokku-openfga

This is an [OpenFGA](https://openfga.dev) plugin for Dokku, currently under development.

## Development workflow

During normal development, you can build the go files locally using `make build`.

You can also build them inside the container. Use `make run` to build and spin up the container, and then shell into the container using `make shell`, where you're able to run commands against a Dokku instance.

When you make changes to your go files, use `make sync` _outside_ of the container to copy the go files to the right place inside the container and re-run a build.

## Testing workflow

1. Build the testing Docker images, start the container, and install the plugin:

```
make run
```

This creates a Docker image that runs Dokku, as well as installing Golang so that the plugin can be compiled.

2. Shell into the container:

```
make shell
```

3. Interact with the plugin:

```
# e.g. call the help command
dokku openfga:help
```
