package docker

import (
	"context"
	"encoding/json"
	"io"
	"openfga/src/internal/errors"
	"openfga/src/internal/log"

	"github.com/docker/docker/api/types/image"
	dockerClient "github.com/docker/docker/client"
)

type dockerEvent struct {
	Status   string `json:"status"`
	Error    string `json:"error"`
	Progress string `json:"progress"`
}

// Pulls a new image with the
func PullImage(client *dockerClient.Client, imageWithTag string) error {
	events, err := client.ImagePull(context.Background(), "openfga/openfga", image.PullOptions{})
	if err != nil {
		panic(err)
	}

	decoder := json.NewDecoder(events)
	defer events.Close()

	var event *dockerEvent
	for {
		if err := decoder.Decode(&event); err != nil {
			if err == io.EOF {
				break
			}
			panic(err)
		}

		if event.Error != "" {
			return errors.NewPluginError("could not download image: %v", event.Error)
		} else {
			log.Info("image pull: %+v", event.Status)
		}
	}

	return nil
}
