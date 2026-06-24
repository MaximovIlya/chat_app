package routes

import (
	"github.com/MaximovIlya/chat_app/internal/controllers"
	"github.com/MaximovIlya/chat_app/internal/db"
	"github.com/gofiber/fiber/v2"
)

func ConversationsRoutes(router fiber.Router, queries *db.Queries) {
	conversationsRoutes := router.Group("/conversations")
	conversationsController := controllers.ConversationsController{DB: queries}

	conversationsRoutes.Get("/", conversationsController.FetchConversations)
	conversationsRoutes.Post("/", conversationsController.CheckOrCreateConversation)
}