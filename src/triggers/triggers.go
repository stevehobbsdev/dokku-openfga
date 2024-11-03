package main

import (
	"fmt"
	"os"
	"strings"

	flag "github.com/spf13/pflag"
)

func main() {
	parts := strings.Split(os.Args[0], "/")
	trigger := parts[len(parts)-1]
	flag.Parse()

	fmt.Printf("Triggered: %s\n", trigger)
	fmt.Println(os.Args)
}
