package controllers

import (
	"database/sql"

	"github.com/MaximovIlya/chat_app/internal/db"
	database "github.com/MaximovIlya/chat_app/internal/db"
	"github.com/gofiber/fiber/v2"
	"github.com/jackc/pgx/v5/pgtype"
)

type ContactsController struct {
	DB database.Querier
}

type AddContactRequest struct {
	PhoneNumber string `json:"phone_number"`
}

type ContactResponce struct {
	ID          string `json:"contact_id"`
	FirstName   string `json:"first_name"`
	SecondName  string `json:"second_name"`
	PhoneNumber string `json:"phone_number"`
	Image       string `json:"image"`
}

// @Summary Получить список контактов для пользователя
// @Description Возвращает список контактов пользователя по его ID
// @Tags Contacts
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 201 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /contacts/ [get]
func (cc *ContactsController) FetchContacts(c *fiber.Ctx) error {

	user_id, ok := c.Locals("userID").(string)
	if !ok || user_id == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "unauthorized",
		})
	}

	var userID pgtype.UUID
	if err := userID.Scan(user_id); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid user_id"})
	}

	contacts, err := cc.DB.GetContacts(c.Context(), userID)
	if err != nil {
		if err == sql.ErrNoRows {
			return c.Status(fiber.StatusOK).JSON([]db.Contact{})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "could not get contacts"})
	}

	resp := make([]ContactResponce, len(contacts))
	for i, c := range contacts {
		resp[i] = ContactResponce{
			ID: c.ContactID.String(),
			FirstName: c.FirstName.String,
			SecondName: c.SecondName.String,
			PhoneNumber: c.PhoneNumber,
			Image: c.Image.String,
		}
	}

	return c.JSON(resp)
}

// @Summary Добавить новый контакт
// @Description Добавляет контакт по номеру телефона
// @Tags Contacts
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body AddContactRequest true "Номер телефона"
// @Success 201 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /contacts/ [post]
func (cc *ContactsController) AddContact(c *fiber.Ctx) error {
	var req AddContactRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "cannot parse request",
		})
	}

	userIDStr, ok := c.Locals("userID").(string)
	if !ok || userIDStr == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "unauthorized",
		})
	}

	var userID pgtype.UUID
	if err := userID.Scan(userIDStr); err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "invalid user id",
		})
	}

	contact, err := cc.DB.GetUserByPhone(c.Context(), req.PhoneNumber)
	if err != nil {
		if err == sql.ErrNoRows {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"error": "contact not found",
			})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "failed to find contact",
		})
	}

	err = cc.DB.AddContact(c.Context(), db.AddContactParams{
		UserID:    userID,
		ContactID: contact.ID,
	})
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "failed to add contact",
		})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "contact added successfully",
	})
}
