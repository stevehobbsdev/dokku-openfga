package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"

	"github.com/docker/docker/api/types/image"
	"github.com/docker/docker/client"
	"github.com/fatih/color"
)

type DockerEvent struct {
	Status   string `json:"status"`
	Error    string `json:"error"`
	Progress string `json:"progress"`
}

func main() {
	fmt.Println("Setting up..")

	dockerClient, err := client.NewClientWithOpts(client.FromEnv)

	if err != nil {
		panic(err)
	}

	defer dockerClient.Close()

	events, err := dockerClient.ImagePull(context.Background(), "openfga/openfga", image.PullOptions{})
	if err != nil {
		panic(err)
	}

	decoder := json.NewDecoder(events)
	defer events.Close()

	var event *DockerEvent
	for {
		if err := decoder.Decode(&event); err != nil {
			if err == io.EOF {
				break
			}
			panic(err)
		}

		if event.Error != "" {

		} else {
			log("image pull: %+v", event.Status)
		}
	}
}

func log(msg string, args ...any) {
	fmt.Printf("%s %s\n", color.CyanString("[setup]"), fmt.Sprintf(msg, args...))
}
