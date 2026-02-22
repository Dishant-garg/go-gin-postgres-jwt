package main

import "fmt"
import "github.com/gin-gonic/gin"
import "go_gin_postgres_jwt/internal/config"
import "go_gin_postgres_jwt/internal/database"
import "github.com/jackc/pgx/v5/pgxpool"
import "go_gin_postgres_jwt/internal/handlers"

func main() {
	var cfg *config.Config
	var err error
	cfg, err = config.LoadConfig()
	if err != nil {
		fmt.Printf("Error loading config: %v\n", err)
		return
	}
	var pool *pgxpool.Pool
	pool, err = database.Connect(cfg.DatabaseURL)
	if err != nil {
		fmt.Printf("Error connecting to database: %v\n", err)
		return
	}
	defer pool.Close()
	var Router *gin.Engine
	Router = gin.Default()
    fmt.Println("Starting Todo API...")
	Router.SetTrustedProxies(nil)
	Router.GET("/home", func(c *gin.Context) {
		// map[string]interface{} is a map with string keys and values of any type
		c.JSON(200, gin.H{
			"message": "Todo API is running!",
			"status":  "success",
			"database" : "connected",
		})
	})
	Router.POST("/todos", handlers.CreateTodoHandler(pool))
	Router.GET("/todos", handlers.GetAllTodosHandler(pool))
	
	Router.Run(":" + cfg.Port)
}