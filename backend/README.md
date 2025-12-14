# Jar Talk Backend API

Backend API cho ứng dụng Jar Talk - Shared Journaling Application.

## Công nghệ sử dụng

- **FastAPI**: Web framework hiện đại, nhanh
- **SQLModel**: ORM cho Python với type hints
- **MySQL**: Database
- **Firebase**: Authentication (Google OAuth)
- **JWT**: Token-based authentication

## Cấu trúc thư mục

```
backend/
├── app.py                 # Main FastAPI application
├── requirements.txt       # Python dependencies
├── .env.example          # Environment variables template
└── src/
    ├── controllers/      # API endpoints/routes
    │   └── auth_controller.py
    ├── models/          # Database models và schemas
    │   └── user.py
    ├── repos/           # Repository pattern cho database
    │   └── user_repo.py
    ├── services/        # Business logic
    │   └── auth_service.py
    └── cores/           # Core utilities
        ├── config.py         # Configuration
        ├── database.py       # Database connection
        ├── firebase_config.py # Firebase setup
        └── security.py       # JWT & password hashing
```

## Cài đặt

### Cách 1: Sử dụng Docker (Khuyến nghị cho testing)

**Yêu cầu**: Docker Desktop

```bash
cd backend

# Windows
docker-start.bat

# Linux/Mac
chmod +x docker-start.sh
./docker-start.sh
```

Server sẽ chạy tại `http://localhost:8000`

Chi tiết xem [DOCKER.md](DOCKER.md)

### Cách 2: Local Python Environment

#### 1. Cài đặt dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Cấu hình môi trường

Tạo file `.env` từ `.env.example`:

```bash
cp .env.example .env
```

Cập nhật các giá trị trong file `.env`:

- **Database**: Cấu hình MySQL connection
- **Firebase**: Đặt đường dẫn đến file credentials Firebase
- **SECRET_KEY**: Tạo một secret key mạnh cho JWT

### 3. Cấu hình Firebase

1. Tạo project trên Firebase Console
2. Enable Authentication với Google OAuth
3. Tải về service account credentials (JSON file)
4. Đặt đường dẫn file JSON vào `FIREBASE_CREDENTIALS_PATH` trong `.env`

### 4. Tạo database

```sql
CREATE DATABASE jar_talk CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 5. Chạy server

```bash
# Development mode (auto-reload)
python app.py

# Hoặc dùng uvicorn trực tiếp
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

Server sẽ chạy tại: `http://localhost:8000`

API Documentation: `http://localhost:8000/docs`

## API Endpoints

### Authentication

**Philosophy**: Backend xử lý data, Firebase xử lý authentication.

Tất cả authentication (Email/Password, Google OAuth, etc.) được xử lý bởi Firebase ở client side.
Backend chỉ có **1 endpoint duy nhất** để verify Firebase token và issue JWT.

#### POST /auth/firebase
Authenticate với Firebase token (hỗ trợ TẤT CẢ Firebase auth methods)

```http
POST /auth/firebase
Content-Type: application/json

{
  "firebase_token": "firebase_id_token_from_client",
  "username": "johndoe"  // Optional cho user mới
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
    ...
  }
}
```

#### GET /auth/me
Lấy thông tin user hiện tại (requires JWT)

```http
GET /auth/me
Authorization: Bearer <access_token>
```

#### GET /auth/check
Kiểm tra authentication status (requires JWT)

```http
GET /auth/check
Authorization: Bearer <access_token>
```

## Response Format

### Thành công (Login/Register)
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
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

### Lỗi
```json
{
  "detail": "Error message here"
}
```

## Authentication Flow

**Simplified Architecture:**

```
Client (Firebase SDK) → Authenticate → Get Firebase Token
                                            ↓
Backend ← Verify Token ← POST /auth/firebase
   ↓
Issue JWT Token → Client uses for all API calls
```

### Bước 1: Client Authentication (Firebase)

Client sử dụng Firebase SDK (Email/Password, Google, etc.):

```javascript
// Firebase handles ALL authentication
import { signInWithEmailAndPassword, signInWithPopup } from 'firebase/auth';

// Email/Password
const user = await signInWithEmailAndPassword(auth, email, password);

// Google OAuth
const user = await signInWithPopup(auth, googleProvider);

// Get Firebase token
const firebaseToken = await user.getIdToken();
```

### Bước 2: Backend Verification

```javascript
// Send Firebase token to backend
const response = await fetch('/auth/firebase', {
  method: 'POST',
  body: JSON.stringify({ firebase_token: firebaseToken })
});

const { access_token } = await response.json();
// Use access_token for all API calls
```

### Bước 3: API Calls

```javascript
// All API calls use JWT token
fetch('/api/endpoint', {
  headers: {
    'Authorization': `Bearer ${access_token}`
  }
});
```

Chi tiết xem [AUTHENTICATION.md](AUTHENTICATION.md)

## Security

- Passwords được hash với bcrypt
- JWT tokens expire sau 7 ngày (configurable)
- Firebase tokens được verify với Firebase Admin SDK
- CORS được cấu hình cho security

## Database Models

Hiện tại đã implement:
- **User**: Lưu thông tin người dùng, hỗ trợ cả email/password và Firebase auth

Sẽ implement tiếp (xem `database/db.md`):
- Container (Jar)
- Slip (Journal Entry)
- Media
- Comment
- Tag
- EmotionLog
- Streak
- Membership
- SlipTag
- SlipReaction

## 📖 Documentation

- **[AUTHENTICATION.md](AUTHENTICATION.md)** - ⭐ Authentication architecture (Firebase + JWT)
- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Hướng dẫn setup Firebase từ đầu đến cuối
- **[DOCKER.md](DOCKER.md)** - Hướng dẫn chạy với Docker
