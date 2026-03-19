-- name: GetMessages :many 
SELECT m.id, m.content, m.sender_id, m.conversation_id, m.created_at
FROM messages m
WHERE m.conversation_id = $1
ORDER BY m.created_at ASC;


-- name: SaveMessage :one 
INSERT INTO messages (conversation_id, sender_id, content)
VALUES ($1, $2, $3)
RETURNING *;