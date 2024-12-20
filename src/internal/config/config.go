package config

import "github.com/joho/godotenv"

func ReadConfig() error {
	return godotenv.Load("config")
}
