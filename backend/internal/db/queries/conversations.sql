-- name: FetchConversationsByUserId :many
SELECT  
    c.id AS conversation_id,  

    (
        CASE  
            WHEN u1.id = $1 THEN u2.first_name  
            ELSE u1.first_name  
        END
    )::text AS participant_name,

    (
        CASE  
            WHEN u1.id = $1 THEN u2.second_name  
            ELSE u1.second_name  
        END
    )::text AS participant_surname,

    (
    COALESCE(
        CASE
            WHEN u1.id = $1 THEN u2.image
            ELSE u1.image
        END,
        ''
    )
)::text AS participant_image,

    m.content AS last_message,  
    m.created_at AS last_message_time  

FROM conversations c  
JOIN users u1 ON u1.id = c.participant_one  
JOIN users u2 ON u2.id = c.participant_two  
LEFT JOIN LATERAL (  
    SELECT content, created_at  
    FROM messages  
    WHERE conversation_id = c.id  
    ORDER BY created_at DESC  
    LIMIT 1  
) m ON true  
WHERE c.participant_one = $1 OR c.participant_two = $1  
ORDER BY m.created_at DESC;


-- name: ExistingConversation :one 
SELECT id from conversations 
WHERE (participant_one = $1 AND participant_two = $2)
    OR (participant_one = $2 AND participant_two = $1)
LIMIT 1;

-- name: CreateConversation :one 
INSERT INTO conversations (participant_one, participant_two)
VALUES ($1, $2)
RETURNING id;