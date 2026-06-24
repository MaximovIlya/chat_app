# Chat App

Мессенджер с реальным временем на Go + Flutter.

## Стек технологий

### Backend
- **Go 1.25** + **Fiber v2** — HTTP-фреймворк
- **PostgreSQL 17** + **pgx/v5** — база данных
- **SQLC** — типобезопасные SQL-запросы
- **JWT** (golang-jwt) — авторизация
- **bcrypt** — хеширование паролей
- **WebSocket** (gofiber/contrib/websocket) — обмен сообщениями в реальном времени
- **Swagger** (swaggo) — документация API
- **Docker / Docker Compose** — контейнеризация

### Frontend
- **Flutter** (Dart) — кроссплатформенное приложение (Android, iOS, Windows, Linux, macOS, Web)
- **flutter_bloc** — управление состоянием (BLoC-паттерн)
- **socket_io_client** — WebSocket-соединение
- **flutter_secure_storage** — безопасное хранение JWT-токена
- **flutter_chat_ui** — готовый UI чата
- **image_picker / photo_manager** — выбор изображений

## Архитектура

Фронтенд использует **Clean Architecture** — каждый модуль разделён на слои:

```
features/
  auth/
    data/        # datasources, repositories, models
    domain/      # entities, usecases, repository interfaces
    presentation/ # BLoC, pages, widgets
  chat/
  contacts/
  conversation/
  profile/
```

## База данных

```
users         — id, username, phone_number, password, first_name, second_name, date_of_birth, image
contacts      — id, user_id, contact_id
conversations — id, participant_one, participant_two
messages      — id, conversation_id, sender_id, content, created_at
```

## API

Base URL: `http://localhost:8080/api/v1`

| Метод | Путь | Описание | Auth |
|-------|------|----------|------|
| POST | `/auth/register` | Регистрация | — |
| POST | `/auth/login` | Вход, возвращает JWT | — |
| GET | `/contacts/` | Список контактов | Bearer |
| POST | `/contacts/` | Добавить контакт по номеру телефона | Bearer |
| GET | `/conversations/` | Список переписок | Bearer |
| POST | `/conversations/` | Получить или создать переписку | Bearer |
| GET | `/{conversationId}` | Сообщения переписки | Bearer |

Swagger UI доступен по адресу: `http://localhost:8080/swagger/`

### WebSocket

Подключение: `ws://localhost:8080/ws`

**Входящие события (клиент → сервер):**

```json
{ "event": "joinConversation", "data": { "conversationId": "..." } }
{ "event": "sendMessage",      "data": { "conversationId": "...", "senderId": "...", "content": "..." } }
```

**Исходящие события (сервер → клиент):**

```json
{ "event": "newMessage",           "data": { ...message } }
{ "event": "conversationUpdated",  "data": { "conversationId": "...", "lastMessage": "...", "lastMessageTime": "..." } }
```

## Быстрый старт

### Backend

Требования: Docker, Docker Compose.

```bash
cd backend
docker-compose up --build
```

Это поднимет PostgreSQL и Go-сервер. База инициализируется схемой из `internal/db/schema.sql`.

Переменные окружения (файл `backend/.env`):

```
DATABASE_URL=postgres://postgres:admin@db:5432/chat_app?sslmode=disable
```

### Frontend

Требования: Flutter SDK ≥ 3.5.2.

Перед запуском укажите адрес бэкенда в `frontend/lib/core/url.dart`:

```dart
class Url {
  static const String baseUrl = 'http://<your-server-ip>:8080';
}
```

```bash
cd frontend
flutter pub get
flutter run
```

## Функциональность

- Регистрация и вход по номеру телефона
- Добавление контактов по номеру телефона
- Список переписок с превью последнего сообщения
- Чат в реальном времени через WebSocket
- Профиль пользователя: аватар, дата рождения
