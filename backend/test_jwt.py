#!/usr/bin/env python3
"""
Test JWT token creation and verification locally
"""
import sys
sys.path.insert(0, '.')

from src.cores.security import create_access_token, decode_access_token
from src.cores.config import settings
from datetime import timedelta

print("="*60)
print("JWT Token Test")
print("="*60)

# Test 1: Create token
print("\n1. Creating token...")
print(f"   Secret Key: {settings.SECRET_KEY[:20]}...")
print(f"   Algorithm: {settings.ALGORITHM}")

user_id = 123
token_data = {"sub": user_id}
token = create_access_token(token_data)

print(f"   Token: {token[:50]}...")
print(f"   Full token: {token}")

# Test 2: Decode token
print("\n2. Decoding token...")
try:
    payload = decode_access_token(token)
    print(f"   ✅ Success!")
    print(f"   Payload: {payload}")
    print(f"   User ID: {payload.get('sub')}")
    print(f"   Expires: {payload.get('exp')}")
except Exception as e:
    print(f"   ❌ Error: {e}")

# Test 3: Invalid token
print("\n3. Testing invalid token...")
try:
    payload = decode_access_token("invalid.token.here")
    print(f"   ❌ Should have failed!")
except Exception as e:
    print(f"   ✅ Correctly rejected: {e}")

# Test 4: Expired token
print("\n4. Creating expired token...")
expired_token = create_access_token(
    {"sub": user_id},
    expires_delta=timedelta(seconds=-10)  # Already expired
)
try:
    payload = decode_access_token(expired_token)
    print(f"   ❌ Should have failed!")
except Exception as e:
    print(f"   ✅ Correctly rejected: {e}")

print("\n" + "="*60)
print("Test completed!")
print("="*60)
