#!/usr/bin/env python3
"""
Quick API test script for Jar Talk Backend
"""
import requests
import json
from datetime import datetime


BASE_URL = "http://localhost:8000"


def print_response(title, response):
    """Print formatted response"""
    print(f"\n{'='*60}")
    print(f"🔍 {title}")
    print(f"{'='*60}")
    print(f"Status: {response.status_code}")
    print(f"Response:")
    try:
        print(json.dumps(response.json(), indent=2, ensure_ascii=False))
    except:
        print(response.text)
    print(f"{'='*60}\n")


def test_health():
    """Test health endpoint"""
    response = requests.get(f"{BASE_URL}/health")
    print_response("Health Check", response)
    return response.status_code == 200


def test_register():
    """Test user registration"""
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    user_data = {
        "username": f"testuser_{timestamp}",
        "email": f"test_{timestamp}@example.com",
        "password": "password123"
    }

    print(f"\n📝 Registering user: {user_data['username']}")
    response = requests.post(f"{BASE_URL}/auth/register", json=user_data)
    print_response("Register User", response)

    if response.status_code == 201:
        return response.json()
    return None


def test_login(email, password):
    """Test user login"""
    login_data = {
        "email": email,
        "password": password
    }

    print(f"\n🔐 Logging in: {email}")
    response = requests.post(f"{BASE_URL}/auth/login", json=login_data)
    print_response("Login", response)

    if response.status_code == 200:
        return response.json()
    return None


def test_get_me(token):
    """Test get current user"""
    headers = {
        "Authorization": f"Bearer {token}"
    }

    print(f"\n👤 Getting current user info")
    response = requests.get(f"{BASE_URL}/auth/me", headers=headers)
    print_response("Get Current User", response)

    return response.status_code == 200


def test_check_auth(token):
    """Test check auth"""
    headers = {
        "Authorization": f"Bearer {token}"
    }

    print(f"\n✅ Checking authentication")
    response = requests.get(f"{BASE_URL}/auth/check", headers=headers)
    print_response("Check Auth", response)

    return response.status_code == 200


def main():
    """Run all tests"""
    print("""
    ╔════════════════════════════════════════════════════════╗
    ║        JAR TALK BACKEND API TEST SCRIPT                ║
    ║        Testing: {}                     ║
    ╚════════════════════════════════════════════════════════╝
    """.format(BASE_URL))

    # Test health
    if not test_health():
        print("❌ Health check failed. Make sure the server is running!")
        return

    print("✅ Server is healthy!\n")

    # Test registration
    register_result = test_register()
    if not register_result:
        print("❌ Registration failed!")
        return

    print("✅ Registration successful!")

    email = register_result["user"]["email"]
    password = "password123"

    # Test login
    login_result = test_login(email, password)
    if not login_result:
        print("❌ Login failed!")
        return

    print("✅ Login successful!")

    token = login_result["access_token"]

    # Test get me
    if not test_get_me(token):
        print("❌ Get current user failed!")
        return

    print("✅ Get current user successful!")

    # Test check auth
    if not test_check_auth(token):
        print("❌ Check auth failed!")
        return

    print("✅ Check auth successful!")

    print("""
    ╔════════════════════════════════════════════════════════╗
    ║           🎉 ALL TESTS PASSED! 🎉                      ║
    ╚════════════════════════════════════════════════════════╝

    📌 Summary:
       - User registered: {email}
       - Access token: {token}

    💡 Next steps:
       1. Try the API docs at {base_url}/docs
       2. Test Firebase authentication
       3. Implement more features!
    """.format(
        email=email,
        token=token[:50] + "...",
        base_url=BASE_URL
    ))


if __name__ == "__main__":
    try:
        main()
    except requests.exceptions.ConnectionError:
        print("\n❌ Cannot connect to server!")
        print(f"Make sure the server is running at {BASE_URL}")
        print("\nTo start the server:")
        print("  - With Docker: docker-start.bat (or ./docker-start.sh)")
        print("  - Local: python app.py")
    except Exception as e:
        print(f"\n❌ Error: {e}")
