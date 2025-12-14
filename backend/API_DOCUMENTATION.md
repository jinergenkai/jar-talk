# API Documentation - Jar Talk

## 📋 Overview

Base URL: `http://localhost:8000`

API Docs (Swagger): `http://localhost:8000/docs`

---

## 🔐 Authentication

All endpoints except `/auth/firebase` require JWT authentication.

**Header:**
```
Authorization: Bearer <jwt_token>
```

### POST /auth/firebase

Authenticate with Firebase token

**Request:**
```json
{
  "firebase_token": "firebase_id_token_from_client",
  "username": "johndoe" // optional
}
```

**Response:**
```json
{
  "access_token": "eyJhbGc...",
  "token_type": "bearer",
  "user": {
    "user_id": 1,
    "username": "johndoe",
    "email": "john@example.com",
    "profile_picture_url": null,
    "created_at": "2024-01-01T00:00:00"
  }
}
```

### GET /auth/me

Get current user info (requires JWT)

### GET /auth/check

Check auth status (requires JWT)

---

## 📦 Containers (Jars)

### POST /containers

Create a new container

**Request:**
```json
{
  "name": "My Travel Journal",
  "jar_style_settings": "{\"theme\": \"blue\", \"icon\": \"plane\"}" // JSON string
}
```

**Response:**
```json
{
  "container_id": 1,
  "name": "My Travel Journal",
  "owner_id": 1,
  "jar_style_settings": "{\"theme\": \"blue\"}",
  "created_at": "2024-01-01T00:00:00",
  "user_role": "admin",
  "member_count": 1
}
```

### GET /containers

Get all containers user is member of

**Response:**
```json
[
  {
    "container_id": 1,
    "name": "My Travel Journal",
    "owner_id": 1,
    "jar_style_settings": null,
    "created_at": "2024-01-01T00:00:00",
    "user_role": "admin",
    "member_count": 3
  },
  {
    "container_id": 2,
    "name": "Family Memories",
    "owner_id": 5,
    "jar_style_settings": null,
    "created_at": "2024-01-02T00:00:00",
    "user_role": "member",
    "member_count": 5
  }
]
```

### GET /containers/{container_id}

Get container by ID

### PUT /containers/{container_id}

Update container (admin only)

**Request:**
```json
{
  "name": "Updated Name",
  "jar_style_settings": "{\"theme\": \"red\"}"
}
```

### DELETE /containers/{container_id}

Delete container (owner only)

### POST /containers/{container_id}/members

Add member to container (admin only)

**Query Parameters:**
- `member_user_id` (required): User ID to add
- `role` (optional): "admin" or "member" (default: "member")

**Response:**
```json
{
  "message": "Member added successfully",
  "membership": {
    "participant_id": 5,
    "user_id": 3,
    "container_id": 1,
    "role": "member",
    "joined_at": "2024-01-01T00:00:00"
  }
}
```

### DELETE /containers/{container_id}/members/{member_user_id}

Remove member from container
- Admin can remove anyone
- Users can remove themselves (leave)

---

## 📝 Slips (Journal Entries)

### POST /slips

Create a new slip

**Request:**
```json
{
  "container_id": 1,
  "title": "Grand Canyon Adventure", // optional
  "text_content": "Today was an amazing day! We visited the Grand Canyon.",
  "location_data": "Grand Canyon, AZ" // optional
}
```

**Response:**
```json
{
  "slip_id": 1,
  "container_id": 1,
  "author_id": 1,
  "title": "Grand Canyon Adventure",
  "text_content": "Today was an amazing day!...",
  "created_at": "2024-01-01T12:00:00",
  "location_data": "Grand Canyon, AZ",
  "author_username": "johndoe",
  "author_email": "john@example.com",
  "author_profile_picture": null,
  "media": [],
  "emotion": null
}
```

### GET /slips

Get slips from a container

**Query Parameters:**
- `container_id` (required): Container ID
- `skip` (optional, default: 0): Pagination offset
- `limit` (optional, default: 50, max: 100): Number of slips to return

**Response:**
```json
[
  {
    "slip_id": 10,
    "container_id": 1,
    "author_id": 2,
    "title": "Amazing Day",
    "text_content": "Latest entry...",
    "created_at": "2024-01-05T12:00:00",
    "location_data": null,
    "author_username": "alice",
    "author_email": "alice@example.com",
    "author_profile_picture": "https://...",
    "media": [],
    "emotion": null
  },
  {
    "slip_id": 9,
    "container_id": 1,
    "author_id": 1,
    "title": "Tokyo Trip",
    "text_content": "Previous entry...",
    "created_at": "2024-01-04T12:00:00",
    "location_data": "Tokyo, Japan",
    "author_username": "johndoe",
    "author_email": "john@example.com",
    "author_profile_picture": null,
    "media": [],
    "emotion": null
  }
]
```

### GET /slips/{slip_id}

Get slip by ID

### GET /slips/author/{author_id}

Get all slips by a specific author
- Only returns slips in containers current user has access to

**Query Parameters:**
- `skip` (optional, default: 0)
- `limit` (optional, default: 50, max: 100)

### PUT /slips/{slip_id}

Update slip (author only)

**Request:**
```json
{
  "title": "Updated Title",
  "text_content": "Updated content...",
  "location_data": "New Location"
}
```

### DELETE /slips/{slip_id}

Delete slip
- Author can delete their own slip
- Container admin can delete any slip

---

## 🎯 Common Workflows

### 1. User Login & Create First Journal

```javascript
// 1. Firebase authentication
const firebaseToken = await user.getIdToken();

// 2. Backend authentication
const { access_token } = await POST('/auth/firebase', {
  firebase_token: firebaseToken
});

// 3. Create container
const container = await POST('/containers', {
  name: "My First Journal"
}, {
  headers: { Authorization: `Bearer ${access_token}` }
});

// 4. Create first entry
const slip = await POST('/slips', {
  container_id: container.container_id,
  title: "Day One",
  text_content: "My first journal entry!"
}, {
  headers: { Authorization: `Bearer ${access_token}` }
});
```

### 2. Share Container with Friend

```javascript
// Admin adds friend as member
await POST(`/containers/${container_id}/members?member_user_id=5&role=member`, null, {
  headers: { Authorization: `Bearer ${access_token}` }
});

// Friend can now view and create slips
const slips = await GET(`/slips?container_id=${container_id}`, {
  headers: { Authorization: `Bearer ${friend_token}` }
});
```

### 3. Read Journal Entries

```javascript
// Get user's containers
const containers = await GET('/containers', {
  headers: { Authorization: `Bearer ${access_token}` }
});

// Get slips from first container
const slips = await GET(`/slips?container_id=${containers[0].container_id}&limit=20`, {
  headers: { Authorization: `Bearer ${access_token}` }
});
```

---

## 🔒 Access Control

### Containers
- **Create**: Any authenticated user
- **View**: Members only
- **Update**: Admins only
- **Delete**: Owner only
- **Add Members**: Admins only
- **Remove Members**: Admins (anyone), Self (leave)

### Slips
- **Create**: Container members only
- **View**: Container members only
- **Update**: Author only
- **Delete**: Author or container admin

---

## ⚠️ Error Responses

### 400 Bad Request
```json
{
  "detail": "User is already a member"
}
```

### 401 Unauthorized
```json
{
  "detail": "Could not validate credentials"
}
```

### 403 Forbidden
```json
{
  "detail": "You don't have access to this container"
}
```

### 404 Not Found
```json
{
  "detail": "Container not found"
}
```

### 500 Internal Server Error
```json
{
  "detail": "Failed to delete container"
}
```

---

## 📊 Pagination

All list endpoints support pagination:

```
GET /slips?container_id=1&skip=20&limit=10
```

- Returns slips 21-30
- Default: skip=0, limit=50
- Max limit: 100

---

## 🎨 JSON Formats

### jar_style_settings

Free-form JSON string for UI customization:

```json
{
  "theme": "blue",
  "icon": "heart",
  "backgroundColor": "#ffffff",
  "fontFamily": "Arial"
}
```

Store as string in database:
```json
{
  "jar_style_settings": "{\"theme\":\"blue\",\"icon\":\"heart\"}"
}
```

---

## 🚀 Quick Start with curl

```bash
# 1. Authenticate (get token from Firebase first)
TOKEN=$(curl -X POST http://localhost:8000/auth/firebase \
  -H "Content-Type: application/json" \
  -d '{"firebase_token":"YOUR_FIREBASE_TOKEN"}' \
  | jq -r '.access_token')

# 2. Create container
curl -X POST http://localhost:8000/containers \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"My Journal"}'

# 3. Create slip
curl -X POST http://localhost:8000/slips \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"container_id":1,"title":"First Entry","text_content":"Hello world!"}'

# 4. Get slips
curl http://localhost:8000/slips?container_id=1 \
  -H "Authorization: Bearer $TOKEN"
```
