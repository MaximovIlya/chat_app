-- name: CreateUser :one
INSERT INTO users (username, phone_number, password, first_name, second_name)
VALUES ($1, $2, $3, $4, $5) 
RETURNING *;

-- name: GetUserByPhone :one
SELECT * FROM users 
WHERE phone_number = $1;