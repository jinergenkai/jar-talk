# Firebase Setup Guide

Hướng dẫn chi tiết cấu hình Firebase cho Jar Talk Backend.

## Bước 1: Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project** (hoặc chọn project có sẵn)
3. Nhập tên project: `jar-talk` (hoặc tên bạn muốn)
4. Follow các bước setup

## Bước 2: Enable Authentication

1. Trong Firebase Console, vào **Authentication**
2. Click tab **Sign-in method**
3. Enable các provider:
   - **Email/Password**: Click → Enable → Save
   - **Google**: Click → Enable → Chọn support email → Save

## Bước 3: Lấy Service Account Credentials

### Download Firebase Admin SDK credentials:

1. Click vào icon ⚙️ → **Project settings**
2. Chọn tab **Service accounts**
3. Đảm bảo đang ở tab **Firebase Admin SDK**
4. Click **Generate new private key**
5. Confirm → Download file JSON

### Đặt file vào project:

```bash
# Di chuyển file đã download vào thư mục backend
# Đổi tên thành firebase-credentials.json
mv ~/Downloads/jar-talk-firebase-adminsdk-xxxxx.json E:\project\jar-talk\backend\firebase-credentials.json
```

## Bước 4: Lấy Web API Key

1. Vẫn ở **Project settings**
2. Tab **General**
3. Scroll xuống **Your apps**
4. Nếu chưa có Web App:
   - Click icon **</>** (Web)
   - Register app với nickname: `jar-talk-web`
   - Copy **firebaseConfig** object
5. Nếu đã có app:
   - Copy **Web API Key** từ **Your apps** section

## Bước 5: Cấu hình Backend

### Với Docker (khuyến nghị):

1. **Đặt file credentials**:
   ```bash
   # File nên ở: E:\project\jar-talk\backend\firebase-credentials.json
   ```

2. **Cập nhật `.env.docker`**:
   ```bash
   # Mở file .env.docker
   # Thay your_firebase_web_api_key_here bằng Web API Key thật
   FIREBASE_WEB_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```

3. **Restart Docker containers**:
   ```bash
   docker-compose restart api
   ```

### Với Local Python:

1. **Đặt file credentials**:
   ```bash
   # File nên ở: E:\project\jar-talk\backend\firebase-credentials.json
   ```

2. **Tạo/cập nhật `.env`**:
   ```bash
   # Thêm vào file .env
   FIREBASE_CREDENTIALS_PATH=E:\project\jar-talk\backend\firebase-credentials.json
   FIREBASE_WEB_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```

3. **Restart server**:
   ```bash
   # Stop (Ctrl+C) và start lại
   python app.py
   ```

## Bước 6: Verify Setup

### Test với cURL:

```bash
# Giả sử bạn đã có Firebase ID token từ client
curl -X POST http://localhost:8000/auth/firebase \
  -H "Content-Type: application/json" \
  -d '{"firebase_token":"YOUR_FIREBASE_ID_TOKEN"}'
```

### Test với Python:

```python
import requests

# Firebase ID token từ client-side Firebase SDK
firebase_token = "eyJhbGciOiJSUzI1NiIsImtpZCI6..."

response = requests.post(
    "http://localhost:8000/auth/firebase",
    json={"firebase_token": firebase_token}
)

print(response.json())
# Expected: {"access_token": "...", "user": {...}}
```

## Firebase Client Integration

### Web/React/Flutter Client:

Trên client side, bạn cần:

1. **Install Firebase SDK**:
   ```bash
   # React/Web
   npm install firebase

   # Flutter
   flutter pub add firebase_core firebase_auth
   ```

2. **Initialize Firebase** (client-side):
   ```javascript
   // React/Web example
   import { initializeApp } from 'firebase/app';
   import { getAuth, signInWithPopup, GoogleAuthProvider } from 'firebase/auth';

   const firebaseConfig = {
     apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
     authDomain: "jar-talk.firebaseapp.com",
     projectId: "jar-talk",
     // ... other config
   };

   const app = initializeApp(firebaseConfig);
   const auth = getAuth(app);
   ```

3. **Authenticate với Google**:
   ```javascript
   // Google Sign-In
   const provider = new GoogleAuthProvider();

   const signInWithGoogle = async () => {
     try {
       const result = await signInWithPopup(auth, provider);
       const user = result.user;

       // Get Firebase ID token
       const idToken = await user.getIdToken();

       // Send to your backend
       const response = await fetch('http://localhost:8000/auth/firebase', {
         method: 'POST',
         headers: { 'Content-Type': 'application/json' },
         body: JSON.stringify({ firebase_token: idToken })
       });

       const data = await response.json();
       // data.access_token - your JWT token
       // data.user - user info

       // Store JWT token for future requests
       localStorage.setItem('access_token', data.access_token);

     } catch (error) {
       console.error(error);
     }
   };
   ```

4. **Authenticate với Email/Password**:
   ```javascript
   import { signInWithEmailAndPassword, createUserWithEmailAndPassword } from 'firebase/auth';

   // Register
   const registerWithEmail = async (email, password) => {
     const userCredential = await createUserWithEmailAndPassword(auth, email, password);
     const idToken = await userCredential.user.getIdToken();

     // Send to backend
     const response = await fetch('http://localhost:8000/auth/firebase', {
       method: 'POST',
       headers: { 'Content-Type': 'application/json' },
       body: JSON.stringify({
         firebase_token: idToken,
         username: 'desired_username' // optional
       })
     });

     return response.json();
   };

   // Login
   const loginWithEmail = async (email, password) => {
     const userCredential = await signInWithEmailAndPassword(auth, email, password);
     const idToken = await userCredential.user.getIdToken();

     // Send to backend same as above
     // ...
   };
   ```

## Authentication Flow

### Google OAuth Flow:

```
┌─────────┐                 ┌──────────┐                 ┌─────────┐
│ Client  │                 │ Firebase │                 │ Backend │
└────┬────┘                 └────┬─────┘                 └────┬────┘
     │                           │                            │
     │ 1. signInWithPopup()      │                            │
     ├──────────────────────────>│                            │
     │                           │                            │
     │ 2. User authenticates     │                            │
     │    with Google            │                            │
     │<──────────────────────────┤                            │
     │                           │                            │
     │ 3. Get ID Token           │                            │
     ├──────────────────────────>│                            │
     │<──────────────────────────┤                            │
     │     Firebase ID Token     │                            │
     │                           │                            │
     │ 4. POST /auth/firebase                                 │
     │    {firebase_token}                                    │
     ├────────────────────────────────────────────────────────>│
     │                           │                            │
     │                           │ 5. Verify token            │
     │                           │<───────────────────────────┤
     │                           │    verify_id_token()       │
     │                           ├───────────────────────────>│
     │                           │    Token valid ✓           │
     │                           │                            │
     │                                    6. Create/Get user  │
     │                                       Generate JWT     │
     │<────────────────────────────────────────────────────────┤
     │     {access_token, user}  │                            │
     │                           │                            │
     │ 7. Use JWT for API calls  │                            │
     │    Authorization: Bearer <JWT>                         │
     ├────────────────────────────────────────────────────────>│
     │                                                         │
```

## Troubleshooting

### Error: "Firebase app not initialized"

**Nguyên nhân**: File credentials không tồn tại hoặc path sai

**Giải pháp**:
```bash
# Kiểm tra file tồn tại
ls -la backend/firebase-credentials.json

# Kiểm tra path trong .env hoặc .env.docker
cat backend/.env.docker
```

### Error: "Invalid token"

**Nguyên nhân**:
- Token đã expire (tokens expire sau 1 giờ)
- Token không đúng format
- Project ID không khớp

**Giải pháp**:
- Lấy token mới từ client: `await user.getIdToken(true)` (force refresh)
- Kiểm tra token format: phải bắt đầu bằng `eyJ...`
- Verify project ID trong Firebase Console khớp với credentials

### Error: "Permission denied"

**Nguyên nhân**: Service account không có quyền

**Giải pháp**:
- Re-download service account key mới
- Đảm bảo download đúng project
- Check IAM permissions trong Google Cloud Console

### Firebase works nhưng backend không nhận

**Kiểm tra**:
```bash
# View logs
docker-compose logs api | grep -i firebase

# Test credentials
python -c "
import firebase_admin
from firebase_admin import credentials
cred = credentials.Certificate('firebase-credentials.json')
firebase_admin.initialize_app(cred)
print('Firebase initialized successfully!')
"
```

## Security Notes

⚠️ **QUAN TRỌNG**:

1. **NEVER commit** `firebase-credentials.json` vào git
2. **NEVER expose** service account credentials publicly
3. File đã được thêm vào `.gitignore`
4. Trong production, sử dụng secret management (AWS Secrets, Google Secret Manager, etc.)
5. Rotate keys định kỳ

## Production Checklist

- [ ] Service account credentials được lưu an toàn (không commit vào git)
- [ ] Web API Key được set trong environment variables
- [ ] Firebase Authentication rules được cấu hình đúng
- [ ] CORS được cấu hình chỉ cho phép trusted origins
- [ ] Rate limiting được enable
- [ ] Monitoring và logging được setup
- [ ] Backup credentials ở nơi an toàn

## Resources

- [Firebase Authentication Docs](https://firebase.google.com/docs/auth)
- [Firebase Admin SDK Python](https://firebase.google.com/docs/admin/setup)
- [Firebase Web SDK](https://firebase.google.com/docs/web/setup)
