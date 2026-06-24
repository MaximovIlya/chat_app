package main

import (
	"context"
	"fmt"
	"log"
	"os"

	_ "github.com/MaximovIlya/chat_app/docs"
	"github.com/MaximovIlya/chat_app/internal/controllers"
	"github.com/MaximovIlya/chat_app/internal/db"
	"github.com/MaximovIlya/chat_app/internal/routes"
	"github.com/MaximovIlya/chat_app/middleware"
	ws "github.com/MaximovIlya/chat_app/websocket"
	swagger "github.com/arsmn/fiber-swagger/v2"
	fiberws "github.com/gofiber/contrib/websocket"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

// @title Chat App API
// @version 1.0
// @description API for chat app
// @host localhost:8080
// @BasePath /api/v1
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
func main() {
	err := godotenv.Load()
	if err != nil {
		log.Println("No .env file found")
	}
	connStr := os.Getenv("DATABASE_URL")
	fmt.Println(connStr)

	pool, err := pgxpool.New(context.Background(), connStr)
	if err != nil {
		log.Fatal("DB connection error:", err)
	}
	defer pool.Close()

	queries := db.New(pool)

	app := fiber.New()

	hub := ws.NewHub()

	messageController := &controllers.MessageController{
		DB: queries,
	}

	app.Use("/ws", func(c *fiber.Ctx) error {
		if fiberws.IsWebSocketUpgrade(c) {
			return c.Next()
		}
		return fiber.ErrUpgradeRequired
	})

	app.Get("/ws", fiberws.New(ws.ServeWS(hub, messageController)))

	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
	}))

	app.Get("/swagger/*", swagger.HandlerDefault)

	api := app.Group("/api")
	v1 := api.Group("/v1")

	routes.AuthRoutes(v1, queries)
	api.Use(middleware.Protected())
	routes.ContactsRoutes(v1, queries)
	routes.ConversationsRoutes(v1, queries)

	log.Fatal(app.Listen(":8080"))

}
