package main

import "fmt"
import "github.com/gin-gonic/gin"

func main() {
	var Router *gin.Engine
	Router = gin.Default()
    fmt.Println("Starting Todo API...")
	Router.GET("/home", func(c *gin.Context) {
		// map[string]interface{} is a map with string keys and values of any type
		c.JSON(200, gin.H{
			"message": "Todo API is running!",
			"status":  "success",
		})
	})
	Router.Run(":3000")
}