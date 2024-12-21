package log

import (
	"fmt"

	"github.com/fatih/color"
)

// Info prints an informational message to stdout
func Info(msg string, args ...any) {
	fmt.Printf("%s %s\n", color.CyanString("[info]"), fmt.Sprintf(msg, args...))
}

// Error prints an error message to stdout
func Error(msg string, err error) {
	fmt.Printf("%s %s: %v", color.RedString("[error]"), msg, err)
}
