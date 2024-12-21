package main

import (
	"fmt"

	dockerClient "github.com/docker/docker/client"
)

func main() {
	fmt.Println("Setting up..")

	dockerClient, err := dockerClient.NewClientWithOpts(dockerClient.FromEnv)
	if err != nil {
		panic(err)
	}

	defer dockerClient.Close()

	// Pull the main service image
}
