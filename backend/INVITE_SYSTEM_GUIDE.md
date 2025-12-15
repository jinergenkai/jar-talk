# Invite System Guide

## 📋 Overview

The invite system allows container admins to create shareable links or codes that allow other users to join their containers. This replaces the previous direct member addition approach.

## 🎯 Key Features

- ✅ **Invite Links**: Generate shareable URLs with codes
- ✅ **Invite Codes**: Short codes users can manually enter
- ✅ **Expiration**: Set invite expiration time (e.g., 24 hours)
- ✅ **Usage Limits**: Limit how many people can use an invite
- ✅ **Auto-cleanup**: Expired invites are automatically deactivated
- ✅ **Security**: Only admins can create/view invites

## 🔐 Access Control

| Action | Required Role |
|--------|--------------|
| Create invite | Container admin |
| View invites | Container admin |
| Join via invite | Any authenticated user |
| Deactivate invite | Container admin or invite creator |

## 📊 Database Schema

```sql
CREATE TABLE invite (
    invite_id INT AUTO_INCREMENT PRIMARY KEY,
    container_id INT NOT NULL,
    invite_code VARCHAR(50) NOT NULL UNIQUE,
    created_by INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NULL,        -- NULL = never expires
    max_uses INT NULL,                -- NULL = unlimited uses
    current_uses INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    FOREIGN KEY (container_id) REFERENCES container(container_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE CASCADE
);
```

## 🚀 Usage Examples

### 1. Create Invite Link (Admin)

```javascript
// Create invite that expires in 24 hours with max 10 uses
const response = await fetch('http://localhost:8000/invites', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_JWT_TOKEN',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    container_id: 1,
    expires_in_hours: 24,
    max_uses: 10
  })
});

const invite = await response.json();
/*
{
  "invite_id": 1,
  "container_id": 1,
  "invite_code": "ABC123XY",
  "invite_link": "http://localhost:8000/invites/join?code=ABC123XY",
  "created_by": 1,
  "created_at": "2024-01-01T12:00:00",
  "expires_at": "2024-01-02T12:00:00",
  "max_uses": 10,
  "current_uses": 0,
  "is_active": true,
  "container_name": "My Travel Journal"
}
*/
```

### 2. Create Permanent Invite

```javascript
// Create invite with no expiration or usage limit
const invite = await fetch('http://localhost:8000/invites', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_JWT_TOKEN',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    container_id: 1,
    expires_in_hours: null,  // Never expires
    max_uses: null           // Unlimited uses
  })
});
```

### 3. Join Using Invite Code

```javascript
// Option 1: User clicks invite link - extract code from URL
const urlParams = new URLSearchParams(window.location.search);
const inviteCode = urlParams.get('code'); // "ABC123XY"

// Option 2: User manually enters code
const inviteCode = userInput; // "ABC123XY" from text input

// Join the container (same endpoint for both)
const response = await fetch(`http://localhost:8000/invites/join?code=${inviteCode}`, {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer USER_JWT_TOKEN'
  }
});

const result = await response.json();
/*
{
  "message": "Successfully joined container",
  "container": {
    "container_id": 1,
    "name": "My Travel Journal"
  },
  "membership": {
    "participant_id": 10,
    "role": "member",
    "joined_at": "2024-01-01T12:00:00"
  }
}
*/
```

### 4. View Active Invites (Admin)

```javascript
const response = await fetch('http://localhost:8000/invites/container/1', {
  method: 'GET',
  headers: {
    'Authorization': 'Bearer ADMIN_JWT_TOKEN'
  }
});

const invites = await response.json();
/*
[
  {
    "invite_id": 1,
    "invite_code": "ABC123XY",
    "invite_link": "http://localhost:8000/invites/join?code=ABC123XY",
    "current_uses": 3,
    "max_uses": 10,
    "expires_at": "2024-01-02T12:00:00",
    "is_active": true
  },
  {
    "invite_id": 2,
    "invite_code": "XYZ789AB",
    "invite_link": "http://localhost:8000/invites/join?code=XYZ789AB",
    "current_uses": 1,
    "max_uses": null,
    "expires_at": null,
    "is_active": true
  }
]
*/
```

### 5. Deactivate Invite (Admin)

```javascript
const response = await fetch('http://localhost:8000/invites/1', {
  method: 'DELETE',
  headers: {
    'Authorization': 'Bearer ADMIN_JWT_TOKEN'
  }
});

const result = await response.json();
// { "message": "Invite deactivated successfully" }
```

## 🎨 React Component Examples

### InviteCreator Component

```jsx
import { useState } from 'react';

function InviteCreator({ containerId }) {
  const [invite, setInvite] = useState(null);
  const [expiresIn, setExpiresIn] = useState(24);
  const [maxUses, setMaxUses] = useState(10);

  const createInvite = async () => {
    const response = await fetch('http://localhost:8000/invites', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        container_id: containerId,
        expires_in_hours: expiresIn || null,
        max_uses: maxUses || null
      })
    });

    const data = await response.json();
    setInvite(data);
  };

  const copyToClipboard = () => {
    navigator.clipboard.writeText(invite.invite_link);
    alert('Invite link copied!');
  };

  return (
    <div>
      <h3>Create Invite Link</h3>

      <input
        type="number"
        placeholder="Expires in hours (empty = never)"
        value={expiresIn}
        onChange={(e) => setExpiresIn(e.target.value)}
      />

      <input
        type="number"
        placeholder="Max uses (empty = unlimited)"
        value={maxUses}
        onChange={(e) => setMaxUses(e.target.value)}
      />

      <button onClick={createInvite}>Create Invite</button>

      {invite && (
        <div className="invite-result">
          <h4>Invite Created!</h4>
          <p><strong>Code:</strong> {invite.invite_code}</p>
          <p><strong>Link:</strong> {invite.invite_link}</p>
          <button onClick={copyToClipboard}>Copy Link</button>

          <div className="invite-info">
            <p>Expires: {invite.expires_at || 'Never'}</p>
            <p>Max uses: {invite.max_uses || 'Unlimited'}</p>
            <p>Current uses: {invite.current_uses}</p>
          </div>
        </div>
      )}
    </div>
  );
}
```

### JoinByInvite Component

```jsx
import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';

function JoinByInvite() {
  const [searchParams] = useSearchParams();
  const [code, setCode] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    // Auto-extract code from URL if present
    const urlCode = searchParams.get('code');
    if (urlCode) {
      setCode(urlCode);
      // Auto-join if code is in URL
      joinContainer(urlCode);
    }
  }, []);

  const joinContainer = async (inviteCode = code) => {
    try {
      const response = await fetch(`http://localhost:8000/invites/join?code=${inviteCode}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.detail);
      }

      const result = await response.json();
      alert(`Successfully joined ${result.container.name}!`);
      navigate(`/containers/${result.container.container_id}`);

    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div>
      <h3>Join Container</h3>
      <input
        type="text"
        placeholder="Enter invite code"
        value={code}
        onChange={(e) => setCode(e.target.value.toUpperCase())}
        maxLength={8}
      />
      <button onClick={() => joinContainer()}>Join</button>
      {error && <p className="error">{error}</p>}
    </div>
  );
}
```

### InviteList Component (Admin)

```jsx
import { useEffect, useState } from 'react';

function InviteList({ containerId }) {
  const [invites, setInvites] = useState([]);

  useEffect(() => {
    fetchInvites();
  }, []);

  const fetchInvites = async () => {
    const response = await fetch(
      `http://localhost:8000/invites/container/${containerId}`,
      {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      }
    );
    const data = await response.json();
    setInvites(data);
  };

  const deactivateInvite = async (inviteId) => {
    await fetch(`http://localhost:8000/invites/${inviteId}`, {
      method: 'DELETE',
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    });
    fetchInvites(); // Refresh list
  };

  return (
    <div>
      <h3>Active Invites</h3>
      {invites.map(invite => (
        <div key={invite.invite_id} className="invite-card">
          <strong>{invite.invite_code}</strong>
          <p>Uses: {invite.current_uses} / {invite.max_uses || '∞'}</p>
          <p>Expires: {invite.expires_at || 'Never'}</p>
          <button onClick={() => deactivateInvite(invite.invite_id)}>
            Deactivate
          </button>
        </div>
      ))}
    </div>
  );
}
```

## 🛡️ Security Features

### Invite Code Generation

- 8 characters long
- Uses uppercase letters and digits
- Excludes similar-looking characters (0, O, I, 1)
- Cryptographically secure random generation
- Uniqueness guaranteed

### Auto-deactivation

Invites are automatically deactivated when:
- Expiration time is reached
- Maximum uses are reached
- Admin manually deactivates

### Validation Checks

Before joining, the system validates:
- ✅ Invite exists
- ✅ Invite is active
- ✅ Invite hasn't expired
- ✅ Max uses not exceeded
- ✅ User not already a member

## 🔄 Migration from Old System

If you were using the old `/containers/{id}/members` endpoint:

**Old Way:**
```javascript
// Direct member addition (deprecated)
POST /containers/1/members?member_user_id=5
```

**New Way:**
```javascript
// Step 1: Admin creates invite
POST /invites { container_id: 1 }

// Step 2: Share invite code/link with user

// Step 3: User joins using invite
POST /invites/join?code=ABC123XY
```

## 📱 Mobile App Integration

### Flutter Example

```dart
// Create invite
Future<Invite> createInvite(int containerId) async {
  final response = await http.post(
    Uri.parse('$baseUrl/invites'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'container_id': containerId,
      'expires_in_hours': 24,
      'max_uses': 10,
    }),
  );

  return Invite.fromJson(jsonDecode(response.body));
}

// Join by code (from link or manual entry)
Future<void> joinByCode(String code) async {
  final response = await http.post(
    Uri.parse('$baseUrl/invites/join?code=$code'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    print('Joined ${result['container']['name']}');
  }
}
```

## ⚠️ Common Errors

### 404: Invalid invite code
- The invite code doesn't exist
- User may have mistyped the code

### 400: Invite expired
- The invite's expiration time has passed
- Admin needs to create a new invite

### 400: Max uses reached
- The invite has been used maximum times
- Admin needs to create a new invite

### 400: Already a member
- User is already a member of this container
- No action needed

### 403: Only admins can create invites
- User must be container admin to create invites
- Owner must promote user to admin first
