package controllers

import (
	"context"
	"errors"
	"time"

	"github.com/MaximovIlya/chat_app/internal/db"
	database "github.com/MaximovIlya/chat_app/internal/db"
	"github.com/gofiber/fiber/v2"
	"github.com/jackc/pgx/v5/pgtype"
)

type MessageController struct {
	DB database.Querier
}

type MessagesRequest struct {
	ConversaionID string `json:"conversation_id"`
}

type MessagesResponse struct {
	ID             string `json:"id"`
	ConversationID string `json:"conversation_id"`
	SenderID       string `json:"sender_id"`
	Content        string `json:"content"`
	CreatedAt      string `json:"created_at"`
}

type SavedMessage struct {
	ID             string    `json:"id"`
	ConversationID string    `json:"conversation_id"`
	SenderID       string    `json:"sender_id"`
	Content        string    `json:"content"`
	CreatedAt      time.Time `json:"created_at"`
}


// @Summary Получить все сообщения 
// @Description Возвращает сообщения по conversation_id
// @Tags Messages
// @Accept json
// @Produce json
// @Param request body MessagesRequest true "conversation ID"
// @Security BearerAuth
// @Success 201 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /{conversationId} [get]
func (mc *MessageController) FecthMessages(c *fiber.Ctx) error {
	conversationId := c.Params("conversationId")
	if conversationId == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "conversationId is required"})
	}

	var conversationID pgtype.UUID
	if err := conversationID.Scan(conversationID); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid user_id"})
	}

	messages, err := mc.DB.GetMessages(c.Context(), conversationID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "failed to fetch messages",
		})
	}
	resp := make([]MessagesResponse, len(messages))
	for i, m := range messages {
		resp[i] = MessagesResponse{
			ID:             m.ID.String(),
			ConversationID: m.ConversationID.String(),
			SenderID:       m.SenderID.String(),
			Content:        m.Content.String,
			CreatedAt:      m.CreatedAt.Time.UTC().Format(time.RFC3339),
		}
	}

	return c.JSON(resp)
}

func (mc *MessageController) SaveMessage(conversationID string, senderID string, content string, ctx context.Context) (*SavedMessage, error) {
	if conversationID == "" || senderID == "" || content == "" {
		return nil, errors.New("invalid message data")
	}

	var conversationIDPg pgtype.UUID
	if err := conversationIDPg.Scan(conversationID); err != nil {
		return nil, errors.New("invalid conversation ID")
	}

	var senderIDPg pgtype.UUID
	if err := senderIDPg.Scan(senderID); err != nil {
		return nil, errors.New("invalid sender ID")
	}

	var contentText pgtype.Text
	if err := contentText.Scan(content); err != nil {
		return nil, errors.New("invalid content")
	}

	msg, err := mc.DB.SaveMessage(ctx, db.SaveMessageParams{
		ConversationID: conversationIDPg,
		SenderID:       senderIDPg,
		Content:        contentText,
	})
	if err != nil {
		return nil, errors.New("failed to save message")
	}

	return &SavedMessage{
		ID:             msg.ID.String(),
		ConversationID: msg.ConversationID.String(),
		SenderID:       msg.SenderID.String(),
		Content:        msg.Content.String,
		CreatedAt:      msg.CreatedAt.Time,
	}, nil
}


