# Enriched Data Response Guide

## 📊 Overview

API responses đã được enrich với related data để giảm số lượng requests từ client.

---

## 📝 Slip Response (Enriched)

### GET /slips?container_id=1

**Before (Basic):**
```json
{
  "slip_id": 1,
  "container_id": 1,
  "author_id": 5,
  "text_content": "Amazing day!",
  "created_at": "2024-01-01T12:00:00"
}
```

**After (Enriched):**
```json
{
  "slip_id": 1,
  "container_id": 1,
  "author_id": 5,
  "title": "Beach Day",
  "text_content": "Amazing day at the beach!",
  "created_at": "2024-01-01T12:00:00",
  "location_data": "Santa Monica, CA",

  // ✨ Author info (embedded)
  "author_username": "johndoe",
  "author_email": "john@example.com",
  "author_profile_picture": "https://...",

  // ✨ Media attachments (với download URLs)
  "media": [
    {
      "media_id": 10,
      "media_type": "image",
      "storage_url": "image/abc123.jpg",
      "caption": "Sunset at the beach",
      "download_url": "http://192.168.0.101:9000/jar-talk/image/abc123.jpg?X-Amz-..."
    },
    {
      "media_id": 11,
      "media_type": "audio",
      "storage_url": "audio/def456.mp3",
      "caption": "Ocean sounds",
      "download_url": "http://192.168.0.101:9000/jar-talk/audio/def456.mp3?X-Amz-..."
    }
  ],

  // ✨ Emotion log
  "emotion": {
    "emotion_type": "happy",
    "logged_at": "2024-01-01T12:00:00"
  }
}
```

### Benefits:

✅ **1 request thay vì 3+**:
- Old: GET /slips → GET /media/slip/{id} → GET /users/{id}
- New: GET /slips (all data included!)

✅ **Download URLs ready**:
- Media download URLs đã generated sẵn
- Client chỉ cần render `<img src={media.download_url} />`

✅ **Author info embedded**:
- Không cần fetch user info riêng
- Show author profile ngay lập tức

---

## 📦 Container Response (Enriched)

### GET /containers/{id}

**Before (Basic):**
```json
{
  "container_id": 1,
  "name": "Family Journal",
  "owner_id": 5,
  "created_at": "2024-01-01T00:00:00",
  "user_role": "admin",
  "member_count": 3
}
```

**After (Enriched):**
```json
{
  "container_id": 1,
  "name": "Family Journal",
  "owner_id": 5,
  "jar_style_settings": "{\"theme\":\"blue\"}",
  "created_at": "2024-01-01T00:00:00",
  "user_role": "admin",
  "member_count": 3,

  // ✨ Member details (full list)
  "members": [
    {
      "user_id": 5,
      "username": "johndoe",
      "email": "john@example.com",
      "profile_picture_url": "https://...",
      "role": "admin",
      "joined_at": "2024-01-01T00:00:00"
    },
    {
      "user_id": 7,
      "username": "alice",
      "email": "alice@example.com",
      "profile_picture_url": "https://...",
      "role": "member",
      "joined_at": "2024-01-02T10:00:00"
    },
    {
      "user_id": 9,
      "username": "bob",
      "email": "bob@example.com",
      "profile_picture_url": null,
      "role": "member",
      "joined_at": "2024-01-03T15:00:00"
    }
  ]
}
```

### Benefits:

✅ **Show member list immediately**:
- Không cần GET /containers/{id}/members riêng
- Display all member avatars, names, roles

✅ **Member management UI**:
- Show who's admin vs member
- Show when they joined
- Easy to implement "Remove member" button

---

## 🎨 Client Usage Examples

### React - Display Slip with Media

```javascript
function SlipCard({ slip }) {
  return (
    <div className="slip-card">
      {/* Author */}
      <div className="author">
        <img src={slip.author_profile_picture || '/default-avatar.png'} />
        <span>{slip.author_username}</span>
        <time>{slip.created_at}</time>
      </div>

      {/* Title */}
      {slip.title && <h3>{slip.title}</h3>}

      {/* Content */}
      <p>{slip.text_content}</p>

      {/* Location */}
      {slip.location_data && (
        <span className="location">📍 {slip.location_data}</span>
      )}

      {/* Media Gallery */}
      {slip.media.length > 0 && (
        <div className="media-gallery">
          {slip.media.map(media => (
            <div key={media.media_id}>
              {media.media_type === 'image' ? (
                <img
                  src={media.download_url}
                  alt={media.caption}
                  title={media.caption}
                />
              ) : (
                <audio src={media.download_url} controls />
              )}
              {media.caption && <p>{media.caption}</p>}
            </div>
          ))}
        </div>
      )}

      {/* Emotion */}
      {slip.emotion && (
        <div className="emotion">
          {getEmotionEmoji(slip.emotion.emotion_type)}
          <span>{slip.emotion.emotion_type}</span>
        </div>
      )}
    </div>
  );
}
```

### React - Container Members List

```javascript
function ContainerMembers({ container }) {
  const handleRemoveMember = async (userId) => {
    await fetch(`/containers/${container.container_id}/members/${userId}`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${token}` }
    });
  };

  return (
    <div className="members-list">
      <h3>Members ({container.member_count})</h3>
      {container.members.map(member => (
        <div key={member.user_id} className="member-item">
          <img src={member.profile_picture_url || '/default-avatar.png'} />
          <div>
            <strong>{member.username}</strong>
            <span>{member.email}</span>
            <small>Joined {new Date(member.joined_at).toLocaleDateString()}</small>
          </div>
          <span className={`role ${member.role}`}>
            {member.role === 'admin' ? '👑 Admin' : 'Member'}
          </span>

          {/* Only show remove if current user is admin */}
          {container.user_role === 'admin' && member.user_id !== container.owner_id && (
            <button onClick={() => handleRemoveMember(member.user_id)}>
              Remove
            </button>
          )}
        </div>
      ))}
    </div>
  );
}
```

### Flutter - Slip Model

```dart
class Slip {
  final int slipId;
  final String? title;
  final String textContent;
  final DateTime createdAt;
  final String? locationData;

  // Author info
  final String authorUsername;
  final String? authorProfilePicture;

  // Media
  final List<MediaInfo> media;

  // Emotion
  final EmotionInfo? emotion;

  Slip.fromJson(Map<String, dynamic> json)
    : slipId = json['slip_id'],
      title = json['title'],
      textContent = json['text_content'],
      createdAt = DateTime.parse(json['created_at']),
      locationData = json['location_data'],
      authorUsername = json['author_username'],
      authorProfilePicture = json['author_profile_picture'],
      media = (json['media'] as List)
          .map((m) => MediaInfo.fromJson(m))
          .toList(),
      emotion = json['emotion'] != null
          ? EmotionInfo.fromJson(json['emotion'])
          : null;
}

class MediaInfo {
  final int mediaId;
  final String mediaType;
  final String caption;
  final String downloadUrl;

  MediaInfo.fromJson(Map<String, dynamic> json)
    : mediaId = json['media_id'],
      mediaType = json['media_type'],
      caption = json['caption'] ?? '',
      downloadUrl = json['download_url'];
}
```

---

## 🚀 Performance Benefits

### Before (Multiple Requests):

```javascript
// 1. Get slips
const slips = await GET('/slips?container_id=1');  // 50 slips

// 2. Get media for each slip (50 requests!)
for (let slip of slips) {
  slip.media = await GET(`/media/slip/${slip.slip_id}`);
}

// 3. Get author for each slip (50 requests!)
for (let slip of slips) {
  slip.author = await GET(`/users/${slip.author_id}`);
}

// Total: 101 requests! 😱
```

### After (Single Request):

```javascript
// Get everything in 1 request!
const slips = await GET('/slips?container_id=1');

// All data ready:
// - slip.media (with download URLs)
// - slip.author_username, author_profile_picture
// - slip.emotion

// Total: 1 request! 🚀
```

**Result**:
- 101 requests → 1 request
- ~10 seconds → ~100ms
- Much better UX!

---

## 📋 API Response Comparison

| Endpoint | Basic Response | Enriched Response |
|----------|---------------|-------------------|
| GET /slips | Slip data only | + Media list<br/>+ Author info<br/>+ Emotion |
| GET /slips/{id} | Slip data only | + Media list<br/>+ Author info<br/>+ Emotion |
| GET /containers/{id} | Container data<br/>+ member_count | + Full member list<br/>+ User details |

---

## 💡 Best Practices

### 1. Cache Download URLs

```javascript
// Download URLs expire sau 1 giờ
// Cache để tránh regenerate quá nhiều

const cachedUrls = new Map();

function getCachedDownloadUrl(mediaId, url) {
  const cached = cachedUrls.get(mediaId);
  if (cached && cached.expiresAt > Date.now()) {
    return cached.url;
  }

  // Cache for 50 minutes (URL valid for 60 minutes)
  cachedUrls.set(mediaId, {
    url: url,
    expiresAt: Date.now() + 50 * 60 * 1000
  });

  return url;
}
```

### 2. Lazy Load Images

```javascript
// Chỉ load media khi scroll đến

function SlipCard({ slip }) {
  return (
    <div>
      <p>{slip.text_content}</p>
      {slip.media.map(media => (
        <img
          key={media.media_id}
          src={media.download_url}
          loading="lazy"  // ← Lazy load
        />
      ))}
    </div>
  );
}
```

### 3. Handle URL Expiry

```javascript
async function displayMedia(media) {
  try {
    // Try to load with current URL
    await loadImage(media.download_url);
  } catch (error) {
    // URL might be expired, fetch fresh one
    const freshMedia = await fetch(`/media/${media.media_id}`);
    const { download_url } = await freshMedia.json();
    await loadImage(download_url);
  }
}
```

---

## 🎯 Summary

| Feature | Status | Benefit |
|---------|--------|---------|
| Slip with media | ✅ Done | No separate media fetch |
| Slip with author | ✅ Done | No user fetch needed |
| Slip with emotion | ✅ Ready | When emotion implemented |
| Container with members | ✅ Done | Full member list |
| Download URLs | ✅ Done | Ready to display |

**Result**: Faster app, better UX, less requests! 🚀
