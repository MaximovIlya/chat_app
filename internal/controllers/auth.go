package controllers

import (
	"log"

	"github.com/MaximovIlya/chat_app/internal/config"
	database "github.com/MaximovIlya/chat_app/internal/db"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"golang.org/x/crypto/bcrypt"
)

type AuthController struct {
	DB database.Querier
}

type RegisterRequest struct {
	Username    string `json:"username"`
	PhoneNumber string `json:"phone_number"`
	Password    string `json:"password"`
	FirstName   string `json:"first_name"`
	SecondName  string `json:"second_name"`
}

type LoginRequest struct {
	PhoneNumber string `json:"phone_number"`
	Password    string `json:"password"`
}

// @Summary Регистрация пользователя
// @Description Создаёт нового пользователя в системе
// @Tags Auth
// @Accept json
// @Produce json
// @Param request body RegisterRequest true "Данные для регистрации"
// @Success 201 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /auth/register [post]
func (ac *AuthController) Register(c *fiber.Ctx) error {
	var req RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request"})
	}

	if req.Password == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "password cannot be empty"})

	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to hash password"})
	}

	user, err := ac.DB.CreateUser(c.Context(), database.CreateUserParams{
		Username:    req.Username,
		PhoneNumber: req.PhoneNumber,
		Password:    string(hashedPassword),
		FirstName:   pgtype.Text{String: req.FirstName, Valid: true},
		SecondName:  pgtype.Text{String: req.SecondName, Valid: true},
	})
	if err != nil {
		log.Printf("Failed to create user: %+v\n", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":  "failed to create user",
			"detail": err.Error(),
		})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "user created successfully",
		"id":      user.ID,
	})

}

// @Summary Авторизация пользователя
// @Description Проверяет логин и возвращает успешный ответ
// @Tags Auth
// @Accept json
// @Produce json
// @Param request body LoginRequest true "Данные для входа"
// @Success 201 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /auth/login [post]
func (ac *AuthController) Login(c *fiber.Ctx) error {
	var req LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request"})
	}

	user, err := ac.DB.GetUserByPhone(c.Context(), req.PhoneNumber)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "invalid credentials"})
	}
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "invalid credentials"})
	}

	token, err := createToken(user.ID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "could not create token"})
	}
	return c.JSON(fiber.Map{
		"token":        token,
		"id":           user.ID,
		"username":     user.Username,
		"phone_number": user.PhoneNumber,
	})
}

func createToken(id pgtype.UUID) (string, error) {
	claims := jwt.MapClaims{
		"id": id.String(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(config.JWTSecret)
}