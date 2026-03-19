package routes

import (
	"github.com/MaximovIlya/chat_app/internal/controllers"
	"github.com/MaximovIlya/chat_app/internal/db"
	"github.com/gofiber/fiber/v2"
)

func AuthRoutes(router fiber.Router, queries *db.Queries) {
	authRoutes := router.Group("/auth")
	authController := controllers.AuthController{DB: queries}

	authRoutes.Post("/register", authController.Register)
	authRoutes.Post("/login", authController.Login)
}