package controllers

import (
	"errors"
	"time"

	"github.com/MaximovIlya/chat_app/internal/db"
	database "github.com/MaximovIlya/chat_app/internal/db"
	"github.com/gofiber/fiber/v2"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

type ConversationsController struct {
	DB database.Querier
}

type ConversationResponse struct {
	ID                    string  `json:"conversation_id"`
	ParticipantFirstName  string  `json:"participant_name"`
	ParticipantSecondName string  `json:"participant_surname"`
	LastMessage           string  `json:"last_message"`
	LastMessageTime       string  `json:"last_message_time"`
	ParticipantImage      string `json:"participant_image"`
}

type ConversationRequest struct {
	ID string `json:"contact_id"`
}

// @Summary Получить список переписок для пользователя
// @Description Возвращает список переписок пользователя по его ID
// @Tags Conversations
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 201 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /conversations/ [get]
func (cc *ConversationsController) FetchConversations(c *fiber.Ctx) error {
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

	conversations, err := cc.DB.FetchConversationsByUserId(c.Context(), userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":  "could not get conversations",
			"detail": err.Error(),
		})
	}

	resp := make([]ConversationResponse, len(conversations))
	for i, c := range conversations {
		resp[i] = ConversationResponse{
			ID:                    c.ConversationID.String(),
			ParticipantFirstName:  c.ParticipantName,
			ParticipantSecondName: c.ParticipantSurname,
			ParticipantImage:      c.ParticipantImage,
			LastMessage:           c.LastMessage.String,
			LastMessageTime:       c.LastMessageTime.Time.UTC().Format(time.RFC3339),
		}
	}

	return c.JSON(resp)

}

// @Summary Добавить новую переписку
// @Description Создает новую переписку
// @Tags Conversations
// @Accept json
// @Produce json
// @Param request body ConversationRequest true "ID контакта"
// @Security BearerAuth
// @Success 201 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /conversations/ [post]
func (cc *ConversationsController) CheckOrCreateConversation(c *fiber.Ctx) error {
	var req ConversationRequest

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
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid user id",
		})
	}

	var contactID pgtype.UUID
	if err := contactID.Scan(req.ID); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid contact id",
		})
	}

	conversation, err := cc.DB.ExistingConversation(c.Context(), db.ExistingConversationParams{
		ParticipantOne: userID,
		ParticipantTwo: contactID,
	})
	if err == nil {
		return c.JSON(fiber.Map{
			"conversationId": conversation,
		})
	}

	if !errors.Is(err, pgx.ErrNoRows) {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":  "failed to check conversation",
			"detail": err.Error(),
		})
	}

	newConversation, err := cc.DB.CreateConversation(c.Context(), db.CreateConversationParams{
		ParticipantOne: userID,
		ParticipantTwo: contactID,
	})
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":  "failed to create conversation",
			"detail": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"conversationId": newConversation,
	})
}
