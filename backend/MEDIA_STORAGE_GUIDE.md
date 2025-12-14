# Media Storage Guide - Presigned URLs with MinIO

## 🎯 Architecture

```
┌─────────┐                 ┌─────────┐                 ┌─────────┐
│ Client  │                 │ Backend │                 │  MinIO  │
└────┬────┘                 └────┬────┘                 └────┬────┘
     │                           │                           │
     │ 1. Request upload URL     │                           │
     ├──────────────────────────>│                           │
     │                           │                           │
     │                           │ 2. Generate presigned URL │
     │                           ├──────────────────────────>│
     │                           │                           │
     │                           │ 3. Return presigned URL   │
     │                           │<──────────────────────────┤
     │ 4. Presigned URL          │                           │
     │<──────────────────────────┤                           │
     │   + file_key              │                           │
     │                           │                           │
     │ 5. Upload file directly                               │
     │   PUT to presigned URL                                │
     ├───────────────────────────────────────────────────────>│
     │                           │                           │
     │ 6. File uploaded ✓        │                           │
     │<───────────────────────────────────────────────────────┤
     │                           │                           │
     │ 7. Create media record    │                           │
     │    (with file_key)        │                           │
     ├──────────────────────────>│                           │
     │                           │                           │
     │                           │ 8. Verify file exists     │
     │                           ├──────────────────────────>│
     │                           │<──────────────────────────┤
     │                           │                           │
     │                           │ 9. Save to DB             │
     │                           │                           │
     │ 10. Media created ✓       │                           │
     │<──────────────────────────┤                           │
     │    + download_url         │                           │
```

## 🔑 Benefits of Presigned URLs

1. **Direct Upload**: Client uploads directly to MinIO (không qua backend)
2. **Bandwidth**: Backend không xử lý file data
3. **Speed**: Nhanh hơn nhiều
4. **Security**: URL expires sau 1 giờ
5. **Scalability**: Backend không bị bottleneck bởi file uploads

## 📝 Complete Flow Example

### Step 1: Request Upload URL

**Client Request:**
```javascript
// User chọn file
const file = document.getElementById('fileInput').files[0];
const fileType = file.type.startsWith('image') ? 'image' : 'audio';

// Request upload URL
const response = await fetch('http://localhost:8000/media/upload-url', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${accessToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    file_type: fileType,
    content_type: file.type  // e.g., 'image/jpeg'
  })
});

const uploadData = await response.json();
// {
//   "upload_url": "http://192.168.0.101:9000/jar-talk/image/uuid.jpg?X-Amz-...",
//   "file_key": "image/abc123-def456.jpg",
//   "content_type": "image/jpeg",
//   "expires_in": 3600
// }
```

### Step 2: Upload File to MinIO

**Client Upload:**
```javascript
// Upload file directly to MinIO using presigned URL
const uploadResponse = await fetch(uploadData.upload_url, {
  method: 'PUT',
  headers: {
    'Content-Type': uploadData.content_type
  },
  body: file  // Raw file data
});

if (!uploadResponse.ok) {
  throw new Error('Upload failed');
}

console.log('✅ File uploaded successfully!');
```

### Step 3: Create Media Record

**Client Request:**
```javascript
// Create media record in database
const mediaResponse = await fetch('http://localhost:8000/media', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${accessToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    slip_id: slipId,
    media_type: fileType,
    storage_url: uploadData.file_key,  // ← Save file_key from step 1
    caption: 'My photo description'
  })
});

const media = await mediaResponse.json();
// {
//   "media_id": 1,
//   "slip_id": 5,
//   "media_type": "image",
//   "storage_url": "image/abc123-def456.jpg",
//   "caption": "My photo description",
//   "created_at": "2024-01-01T12:00:00",
//   "download_url": "http://192.168.0.101:9000/jar-talk/image/abc123.jpg?X-Amz-..."
// }
```

### Step 4: Display Media

**Client Display:**
```javascript
// Get media with download URL
const response = await fetch(`http://localhost:8000/media/${mediaId}`, {
  headers: {
    'Authorization': `Bearer ${accessToken}`
  }
});

const media = await response.json();

// Display image
document.getElementById('myImage').src = media.download_url;
// URL is valid for 1 hour, then regenerate
```

## 🎨 Complete React Component Example

```javascript
import React, { useState } from 'react';

function MediaUpload({ slipId, accessToken }) {
  const [uploading, setUploading] = useState(false);
  const [media, setMedia] = useState(null);

  const handleFileUpload = async (event) => {
    const file = event.target.files[0];
    if (!file) return;

    setUploading(true);

    try {
      // Step 1: Request upload URL
      const urlResponse = await fetch('http://localhost:8000/media/upload-url', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          file_type: file.type.startsWith('image') ? 'image' : 'audio',
          content_type: file.type
        })
      });

      const { upload_url, file_key } = await urlResponse.json();

      // Step 2: Upload to MinIO
      const uploadResponse = await fetch(upload_url, {
        method: 'PUT',
        headers: {
          'Content-Type': file.type
        },
        body: file
      });

      if (!uploadResponse.ok) {
        throw new Error('Upload failed');
      }

      // Step 3: Create media record
      const mediaResponse = await fetch('http://localhost:8000/media', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          slip_id: slipId,
          media_type: file.type.startsWith('image') ? 'image' : 'audio',
          storage_url: file_key,
          caption: ''
        })
      });

      const mediaData = await mediaResponse.json();
      setMedia(mediaData);

      alert('✅ Upload successful!');
    } catch (error) {
      console.error('Upload error:', error);
      alert('❌ Upload failed');
    } finally {
      setUploading(false);
    }
  };

  return (
    <div>
      <input
        type="file"
        accept="image/*,audio/*"
        onChange={handleFileUpload}
        disabled={uploading}
      />
      {uploading && <p>Uploading...</p>}
      {media && (
        <div>
          <h3>Uploaded Media</h3>
          {media.media_type === 'image' ? (
            <img src={media.download_url} alt={media.caption} />
          ) : (
            <audio src={media.download_url} controls />
          )}
        </div>
      )}
    </div>
  );
}

export default MediaUpload;
```

## 🔒 Security Features

### 1. Presigned URL Expiry
- Upload URLs expire sau **1 giờ**
- Download URLs expire sau **1 giờ**
- Sau khi expire, cần request URL mới

### 2. Access Control
- Chỉ container members mới có thể upload media cho slip
- Chỉ container members mới có thể xem media
- Only author hoặc admin mới có thể delete media

### 3. File Validation
- Backend verify file tồn tại trong storage trước khi tạo record
- Content-Type được validate khi request upload URL

## 📊 API Endpoints

### POST /media/upload-url

Request presigned URL for upload

**Request:**
```json
{
  "file_type": "image",
  "content_type": "image/jpeg"
}
```

**Response:**
```json
{
  "upload_url": "http://192.168.0.101:9000/jar-talk/image/uuid.jpg?X-Amz-Algorithm=...",
  "file_key": "image/abc123-def456.jpg",
  "content_type": "image/jpeg",
  "expires_in": 3600
}
```

### POST /media

Create media record

**Request:**
```json
{
  "slip_id": 1,
  "media_type": "image",
  "storage_url": "image/abc123-def456.jpg",
  "caption": "Beautiful sunset"
}
```

**Response:**
```json
{
  "media_id": 1,
  "slip_id": 1,
  "media_type": "image",
  "storage_url": "image/abc123-def456.jpg",
  "caption": "Beautiful sunset",
  "created_at": "2024-01-01T12:00:00",
  "download_url": "http://192.168.0.101:9000/jar-talk/image/abc123.jpg?X-Amz-..."
}
```

### GET /media/{media_id}

Get media with download URL

### GET /media/slip/{slip_id}

Get all media for a slip

**Response:**
```json
[
  {
    "media_id": 1,
    "slip_id": 5,
    "media_type": "image",
    "storage_url": "image/abc.jpg",
    "caption": "Photo 1",
    "created_at": "2024-01-01T12:00:00",
    "download_url": "http://..."
  },
  {
    "media_id": 2,
    "slip_id": 5,
    "media_type": "audio",
    "storage_url": "audio/def.mp3",
    "caption": "Voice note",
    "created_at": "2024-01-01T12:05:00",
    "download_url": "http://..."
  }
]
```

### PUT /media/{media_id}

Update caption

### DELETE /media/{media_id}

Delete media (file + record)

## ⚙️ Configuration

**Environment Variables:**

```bash
# MinIO Configuration
STORAGE_ENDPOINT=192.168.0.101:9000
STORAGE_ACCESS_KEY=admin
STORAGE_SECRET_KEY=strongpassword123
STORAGE_BUCKET=jar-talk
STORAGE_REGION=us-east-1
STORAGE_USE_SSL=False
PRESIGNED_URL_EXPIRY=3600
```

## 🎯 Supported File Types

### Images
- `image/jpeg` → `.jpg`
- `image/png` → `.png`
- `image/gif` → `.gif`
- `image/webp` → `.webp`

### Audio
- `audio/mpeg` → `.mp3`
- `audio/wav` → `.wav`
- `audio/ogg` → `.ogg`
- `audio/aac` → `.aac`
- `audio/m4a` → `.m4a`

## 🚀 Testing with curl

```bash
# 1. Get upload URL
UPLOAD_DATA=$(curl -X POST http://localhost:8000/media/upload-url \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"file_type":"image","content_type":"image/jpeg"}')

UPLOAD_URL=$(echo $UPLOAD_DATA | jq -r '.upload_url')
FILE_KEY=$(echo $UPLOAD_DATA | jq -r '.file_key')

# 2. Upload file
curl -X PUT "$UPLOAD_URL" \
  -H "Content-Type: image/jpeg" \
  --data-binary @photo.jpg

# 3. Create media record
curl -X POST http://localhost:8000/media \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"slip_id\":1,\"media_type\":\"image\",\"storage_url\":\"$FILE_KEY\"}"
```

## 📈 Best Practices

1. **Upload Progress**: Show upload progress trên UI
2. **Error Handling**: Handle network errors, timeout
3. **Retry Logic**: Retry failed uploads
4. **File Size**: Validate file size trước khi upload
5. **Image Preview**: Show preview trước khi upload
6. **Cache URLs**: Cache download URLs (valid for 1 hour)

## ⚠️ Important Notes

- Upload URLs expire sau 1 giờ - upload ngay!
- Download URLs expire sau 1 giờ - regenerate khi cần
- File tự động có unique name (UUID)
- Delete media cũng delete file trong storage
- MinIO bucket tự động được tạo khi start app
