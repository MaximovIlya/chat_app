package routes

import (
	"github.com/MaximovIlya/chat_app/internal/controllers"
	"github.com/MaximovIlya/chat_app/internal/db"
	"github.com/gofiber/fiber/v2"
)

func ContactsRoutes(router fiber.Router, queries *db.Queries) {
	contactsRoutes := router.Group("/contacts")
	contactsController := controllers.ContactsController{DB: queries}

	contactsRoutes.Get("/", contactsController.FetchContacts)
	contactsRoutes.Post("/", contactsController.AddContact)
}