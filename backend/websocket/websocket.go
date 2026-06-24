package websocket

import (
	"context"
	"encoding/json"
	"log"
	"sync"

	"github.com/MaximovIlya/chat_app/internal/controllers"
	"github.com/gofiber/contrib/websocket"
)

type MessageController interface {
	SaveMessage(conversationID string, senderID string, content string, ctx context.Context) (*controllers.SavedMessage, error)
}



type IncomingEvent struct {
	Event string          `json:"event"`
	Data  json.RawMessage `json:"data"`
}

type JoinConversationPayload struct {
	ConversationID string `json:"conversationId"`
}

type SendMessagePayload struct {
	ConversationID string `json:"conversationId"`
	SenderID       string `json:"senderId"`
	Content        string `json:"content"`
}

type OutgoingEvent struct {
	Event string      `json:"event"`
	Data  interface{} `json:"data"`
}

type Client struct {
	Conn   *websocket.Conn
	Hub    *Hub
	Send   chan []byte
	Rooms  map[string]bool
	UserID string
}

type Hub struct {
	mu    sync.RWMutex
	rooms map[string]map[*Client]bool
}

func NewHub() *Hub {
	return &Hub{
		rooms: make(map[string]map[*Client]bool),
	}
}

func (h *Hub) JoinRoom(roomID string, client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if h.rooms[roomID] == nil {
		h.rooms[roomID] = make(map[*Client]bool)
	}
	h.rooms[roomID][client] = true
	client.Rooms[roomID] = true
}

func (h *Hub) LeaveAllRooms(client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	for roomID := range client.Rooms {
		if clients, ok := h.rooms[roomID]; ok {
			delete(clients, client)
			if len(clients) == 0 {
				delete(h.rooms, roomID)
			}
		}
	}
}

func (h *Hub) BroadcastToRoom(roomID string, payload []byte) {
	h.mu.RLock()
	defer h.mu.RUnlock()

	clients := h.rooms[roomID]
	for client := range clients {
		select {
		case client.Send <- payload:
		default:
			close(client.Send)
			delete(clients, client)
		}
	}
}

func (h *Hub) BroadcastToAll(payload []byte) {
	h.mu.RLock()
	defer h.mu.RUnlock()

	seen := make(map[*Client]bool)
	for _, clients := range h.rooms {
		for client := range clients {
			if seen[client] {
				continue
			}
			seen[client] = true

			select {
			case client.Send <- payload:
			default:
				close(client.Send)
			}
		}
	}
}

func (c *Client) readPump(messageController MessageController) {
	defer func() {
		c.Hub.LeaveAllRooms(c)
		c.Conn.Close()
		log.Println("user disconnected")
	}()

	for {
		_, msg, err := c.Conn.ReadMessage()
		if err != nil {
			log.Println("read error:", err)
			break
		}

		var event IncomingEvent
		if err := json.Unmarshal(msg, &event); err != nil {
			log.Println("invalid event:", err)
			continue
		}

		switch event.Event {
		case "joinConversation":
			var payload JoinConversationPayload
			if err := json.Unmarshal(event.Data, &payload); err != nil {
				log.Println("invalid joinConversation payload:", err)
				continue
			}

			c.Hub.JoinRoom(payload.ConversationID, c)
			log.Println("User joined conversation:", payload.ConversationID)

		case "sendMessage":
			var payload SendMessagePayload
			if err := json.Unmarshal(event.Data, &payload); err != nil {
				log.Println("invalid sendMessage payload:", err)
				continue
			}

			savedMessage, err := messageController.SaveMessage(
				payload.ConversationID,
				payload.SenderID,
				payload.Content,
				context.Background(),
			)
			if err != nil {
				log.Println("failed to save message:", err)
				continue
			}

			log.Println("sendMessage:", savedMessage)

			newMessageEvent, _ := json.Marshal(OutgoingEvent{
				Event: "newMessage",
				Data:  savedMessage,
			})

			c.Hub.BroadcastToRoom(payload.ConversationID, newMessageEvent)

			conversationUpdatedEvent, _ := json.Marshal(OutgoingEvent{
				Event: "conversationUpdated",
				Data: map[string]interface{}{
					"conversationId":  payload.ConversationID,
					"lastMessage":     savedMessage.Content,
					"lastMessageTime": savedMessage.CreatedAt,
				},
			})

			c.Hub.BroadcastToAll(conversationUpdatedEvent)
		}
	}
}

func (c *Client) writePump() {
	defer c.Conn.Close()

	for msg := range c.Send {
		if err := c.Conn.WriteMessage(websocket.TextMessage, msg); err != nil {
			log.Println("write error:", err)
			break
		}
	}
}

func ServeWS(hub *Hub, messageController MessageController) func(*websocket.Conn) {
	return func(conn *websocket.Conn) {
		client := &Client{
			Conn:  conn,
			Hub:   hub,
			Send:  make(chan []byte, 256),
			Rooms: make(map[string]bool),
		}

		log.Println("A user connected:", conn.RemoteAddr().String())

		go client.writePump()
		client.readPump(messageController)
	}
}