package config

import "log"
import "os"
import "github.com/joho/godotenv"

type Config struct {
	DatabaseURL string
	Port        string
}

func LoadConfig() (*Config, error) {
	var err error = godotenv.Load()
	if err != nil {
		log.Println("Warning: .env file not found")
	}
	config := &Config{
		DatabaseURL: os.Getenv("DATABASE_URL"),
		Port:        os.Getenv("PORT"),
	}
	return config, nil
}