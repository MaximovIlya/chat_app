package routes

import (
	"github.com/MaximovIlya/chat_app/internal/controllers"
	"github.com/MaximovIlya/chat_app/internal/db"
	"github.com/gofiber/fiber/v2"
)

func MessagesRoutes(router fiber.Router, queris *db.Queries) {
	messagesRoutes := router.Group("/messages")
	messagesController := controllers.MessageController{DB: queris}

	messagesRoutes.Get("/:conversationId", messagesController.FecthMessages)
}