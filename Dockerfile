FROM golang:1.25.0-alpine AS builder 

WORKDIR /app


COPY go.mod go.sum ./
RUN go mod download


COPY . .


RUN go build -o backend ./cmd/server/main.go


FROM alpine:latest

WORKDIR /app


COPY --from=builder /app/backend .



COPY .env .


EXPOSE 8080


CMD ["./backend"]