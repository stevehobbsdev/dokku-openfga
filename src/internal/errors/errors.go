package errors

import "fmt"

type PluginError struct {
	Message string
}

func NewPluginError(msg string, args ...any) PluginError {
	return PluginError{
		Message: fmt.Sprintf(msg, args...),
	}
}

func (e PluginError) Error() string {
	return e.Message
}
