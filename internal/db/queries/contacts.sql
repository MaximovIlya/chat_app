-- name: GetContacts :many
SELECT 
    u.id AS contact_id,
    u.first_name,
    u.second_name,
    u.phone_number,
    u.image
FROM contacts c 
JOIN users u ON u.id = c.contact_id
WHERE c.user_id = $1
ORDER BY u.first_name ASC;

-- name: AddContact :exec
INSERT INTO contacts (user_id, contact_id)
VALUES ($1, $2)
ON CONFLICT DO NOTHING;

