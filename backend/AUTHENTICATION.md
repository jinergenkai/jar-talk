# Authentication Architecture

**Philosophy**: Backend xử lý data, Firebase xử lý authentication.

## 🏗️ Architecture

```
┌────────────────────────────────────────────────────────────┐
│                     Client (React/Flutter)                 │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐ │
│  │         Firebase Authentication SDK                   │ │
│  │  - Email/Password                                     │ │
│  │  - Google OAuth                                       │ │
│  │  - Facebook, Twitter, etc.                            │ │
│  │  - Forgot Password (Firebase handles email)          │ │
│  │  - Email Verification                                 │ │
│  └──────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────┘
                           │
                           │ Firebase ID Token
                           ▼
┌────────────────────────────────────────────────────────────┐
│                   Backend API (FastAPI)                    │
│                                                             │
│  POST /auth/firebase                                       │
│  ├─ Verify Firebase token with Firebase Admin SDK         │
│  ├─ Create/Get user from database                         │
│  └─ Return JWT token for API access                       │
│                                                             │
│  Protected Endpoints (require JWT)                         │
│  ├─ GET /auth/me                                           │
│  ├─ GET /auth/check                                        │
│  └─ All other API endpoints...                             │
└────────────────────────────────────────────────────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │   MySQL DB   │
                    │             │
                    │  User Table │
                    │  - user_id  │
                    │  - email    │
                    │  - firebase_uid │
                    │  - username │
                    └─────────────┘
```

## 🔐 Authentication Flow

### Step 1: Client Authentication (Firebase)

Client sử dụng Firebase SDK để authenticate:

```javascript
import { initializeApp } from 'firebase/app';
import {
  getAuth,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signInWithPopup,
  GoogleAuthProvider,
  sendPasswordResetEmail
} from 'firebase/auth';

// Initialize Firebase
const firebaseConfig = {
  apiKey: "AIzaSy...",
  authDomain: "jar-talk.firebaseapp.com",
  projectId: "jar-talk",
  // ...
};
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

// Method 1: Email/Password Registration
const registerWithEmail = async (email, password) => {
  const userCredential = await createUserWithEmailAndPassword(auth, email, password);
  const user = userCredential.user;
  const idToken = await user.getIdToken();
  return idToken; // Send this to backend
};

// Method 2: Email/Password Login
const loginWithEmail = async (email, password) => {
  const userCredential = await signInWithEmailAndPassword(auth, email, password);
  const user = userCredential.user;
  const idToken = await user.getIdToken();
  return idToken; // Send this to backend
};

// Method 3: Google OAuth
const loginWithGoogle = async () => {
  const provider = new GoogleAuthProvider();
  const result = await signInWithPopup(auth, provider);
  const user = result.user;
  const idToken = await user.getIdToken();
  return idToken; // Send this to backend
};

// Forgot Password (Firebase handles email automatically!)
const resetPassword = async (email) => {
  await sendPasswordResetEmail(auth, email);
  // Firebase automatically sends reset email to user
  // User clicks link → Firebase shows reset form → Done!
};
```

### Step 2: Backend Verification

Client gửi Firebase ID token đến backend:

```javascript
const authenticateWithBackend = async (firebaseToken) => {
  const response = await fetch('http://localhost:8000/auth/firebase', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      firebase_token: firebaseToken,
      username: 'desired_username' // optional
    })
  });

  const data = await response.json();
  // {
  //   "access_token": "eyJhbGc...",  ← JWT for API calls
  //   "token_type": "bearer",
  //   "user": {
  //     "user_id": 1,
  //     "username": "john",
  //     "email": "john@example.com",
  //     ...
  //   }
  // }

  // Store JWT token
  localStorage.setItem('access_token', data.access_token);

  return data;
};
```

### Step 3: API Calls with JWT

Sau khi có JWT token, client dùng nó cho tất cả API calls:

```javascript
const apiCall = async (endpoint) => {
  const token = localStorage.getItem('access_token');

  const response = await fetch(`http://localhost:8000${endpoint}`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });

  return response.json();
};

// Example: Get current user
const user = await apiCall('/auth/me');

// Example: Get user's jars
const jars = await apiCall('/jars');
```

## 📊 Complete Flow Diagram

```
┌──────────┐
│  Client  │
└────┬─────┘
     │
     │ 1. User clicks "Login with Google"
     │
     ▼
┌──────────────────────┐
│  Firebase SDK        │
│  signInWithPopup()   │
└────┬─────────────────┘
     │
     │ 2. Opens Google OAuth popup
     │ 3. User authorizes
     │
     ▼
┌──────────────────────┐
│  Firebase Service    │
│  Returns ID Token    │
└────┬─────────────────┘
     │
     │ 4. idToken = "eyJhbGciOiJSUzI1NiIs..."
     │
     ▼
┌──────────────────────┐
│  Client              │
│  POST /auth/firebase │
│  {firebase_token}    │
└────┬─────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│  Backend: /auth/firebase                │
│                                         │
│  5. Verify token with Firebase Admin    │
│     decoded = verify_id_token(token)    │
│                                         │
│  6. Get user info:                      │
│     uid = decoded['uid']                │
│     email = decoded['email']            │
│                                         │
│  7. Check database:                     │
│     user = db.get_by_firebase_uid(uid)  │
│                                         │
│  8. If not exists:                      │
│     user = db.create(email, uid)        │
│                                         │
│  9. Create JWT token:                   │
│     jwt = create_token(user_id)         │
│                                         │
│  10. Return response                    │
└────┬────────────────────────────────────┘
     │
     │ 11. {access_token, user}
     │
     ▼
┌──────────────────────┐
│  Client              │
│  Store JWT token     │
│  localStorage.set()  │
└────┬─────────────────┘
     │
     │ 12. Future API calls:
     │     Authorization: Bearer <jwt>
     │
     ▼
┌──────────────────────┐
│  Backend API         │
│  Verify JWT          │
│  Process request     │
└──────────────────────┘
```

## 🗄️ Database Schema

```sql
CREATE TABLE user (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    firebase_uid VARCHAR(255) UNIQUE NOT NULL,  -- From Firebase
    profile_picture_url VARCHAR(500),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_email (email),
    INDEX idx_firebase_uid (firebase_uid)
);
```

**Lưu ý**:
- ❌ **KHÔNG có** `password_hash` - Firebase quản lý password
- ✅ **Có** `firebase_uid` - Unique identifier từ Firebase
- ✅ **Required** - Mọi user phải có Firebase UID

## 🎯 API Endpoints

### POST /auth/firebase

Authenticate với Firebase token (duy nhất auth endpoint!)

**Request:**
```json
{
  "firebase_token": "eyJhbGciOiJSUzI1NiIsImtp...",
  "username": "johndoe"  // Optional cho user mới
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "user_id": 1,
    "username": "johndoe",
    "email": "john@example.com",
    "profile_picture_url": "https://...",
    "created_at": "2024-01-01T00:00:00"
  }
}
```

### GET /auth/me

Lấy thông tin user hiện tại (requires JWT)

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response:**
```json
{
  "user_id": 1,
  "username": "johndoe",
  "email": "john@example.com",
  "profile_picture_url": "https://...",
  "created_at": "2024-01-01T00:00:00"
}
```

### GET /auth/check

Check authentication status (requires JWT)

**Response:**
```json
{
  "authenticated": true,
  "user_id": 1
}
```

## 🔥 Firebase Features (Handled by Firebase)

Tất cả các tính năng này **Firebase tự động xử lý**, backend không cần code:

✅ **Email/Password Authentication**
- Register với email/password
- Login với email/password
- Password hashing & security

✅ **Social Login**
- Google OAuth
- Facebook, Twitter, GitHub, etc.

✅ **Password Reset**
```javascript
// Firebase tự động gửi email reset!
await sendPasswordResetEmail(auth, email);
```

✅ **Email Verification**
```javascript
// Firebase tự động gửi email verification!
await sendEmailVerification(user);
```

✅ **Multi-Factor Authentication (MFA)**
- SMS verification
- TOTP authenticator apps

✅ **Account Management**
- Update email
- Update password
- Delete account

## 🛡️ Security

### Firebase Token
- Short-lived (1 hour)
- Verified by Firebase Admin SDK
- Contains user info (uid, email, etc.)
- Cannot be forged

### JWT Token (Backend)
- Long-lived (7 days, configurable)
- Used for API access
- Contains only user_id
- Issued by backend after Firebase verification

### Flow
```
1. Firebase Token (1h) → Verify → Create JWT (7d)
2. Use JWT for all API calls
3. When JWT expires → Get new Firebase token → Get new JWT
```

## 📝 Implementation Checklist

### Backend ✅
- [x] Firebase Admin SDK setup
- [x] POST /auth/firebase endpoint
- [x] JWT token generation
- [x] Protected endpoints with JWT
- [x] User CRUD in database

### Client
- [ ] Firebase SDK initialization
- [ ] Email/Password auth UI
- [ ] Google OAuth button
- [ ] Forgot password flow
- [ ] Store JWT token
- [ ] Add JWT to API requests
- [ ] Handle token expiration

## 🚀 Best Practices

### Client Side
```javascript
// 1. Initialize Firebase once
const auth = getAuth(app);

// 2. Listen to auth state changes
onAuthStateChanged(auth, async (user) => {
  if (user) {
    // User logged in
    const token = await user.getIdToken();
    await authenticateWithBackend(token);
  } else {
    // User logged out
    localStorage.removeItem('access_token');
  }
});

// 3. Handle token refresh
const getValidToken = async () => {
  const user = auth.currentUser;
  if (user) {
    // Force refresh if needed
    return await user.getIdToken(true);
  }
  throw new Error('Not authenticated');
};

// 4. Logout
const logout = async () => {
  await signOut(auth);
  localStorage.removeItem('access_token');
};
```

### Backend Side
```python
# 1. Always verify Firebase tokens
decoded_token = verify_firebase_token(firebase_token)

# 2. Create user on first login
user = get_by_firebase_uid(uid)
if not user:
    user = create_user(uid, email)

# 3. Return JWT for API access
jwt_token = create_access_token({"sub": user.user_id})
```

## 📚 Related Documentation

- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Setup Firebase từ A-Z
- [DOCKER.md](DOCKER.md) - Chạy backend với Docker
- [Firebase Auth Docs](https://firebase.google.com/docs/auth)

## ❓ FAQs

**Q: Tại sao không tự implement email/password authentication?**
A: Firebase cung cấp sẵn tất cả tính năng (forgot password, email verification, security) và hoàn toàn free.

**Q: JWT token có an toàn không?**
A: JWT được issue sau khi verify Firebase token. Chỉ có backend biết SECRET_KEY nên không thể forge.

**Q: Token expire thì sao?**
A: Client request Firebase token mới, rồi gọi `/auth/firebase` lại để lấy JWT mới.

**Q: Có thể dùng nhiều auth provider cho 1 user không?**
A: Có! Firebase hỗ trợ link multiple providers (Google + Email/Password) vào 1 account.

**Q: Backend có lưu password không?**
A: KHÔNG. Hoàn toàn không có password_hash trong database. Firebase quản lý tất cả.
