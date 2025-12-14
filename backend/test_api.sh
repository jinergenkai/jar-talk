#!/bin/bash
# Quick curl-based API testing script

BASE_URL="http://localhost:8000"

echo "╔════════════════════════════════════════════════════════╗"
echo "║        JAR TALK BACKEND API TEST (CURL)                ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test health
echo -e "${BLUE}🔍 Testing Health Check...${NC}"
curl -s "${BASE_URL}/health" | jq '.'
echo ""

# Generate random user
TIMESTAMP=$(date +%s)
USERNAME="testuser_${TIMESTAMP}"
EMAIL="test_${TIMESTAMP}@example.com"
PASSWORD="password123"

# Test register
echo -e "${BLUE}📝 Testing Registration...${NC}"
echo "Username: ${USERNAME}"
echo "Email: ${EMAIL}"
REGISTER_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"${USERNAME}\",\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\"}")

echo "$REGISTER_RESPONSE" | jq '.'
echo ""

# Extract token
TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.access_token')

if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ]; then
    echo -e "${GREEN}✅ Registration successful!${NC}"
    echo ""

    # Test login
    echo -e "${BLUE}🔐 Testing Login...${NC}"
    LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/login" \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\"}")

    echo "$LOGIN_RESPONSE" | jq '.'
    echo ""

    # Test get me
    echo -e "${BLUE}👤 Testing Get Current User...${NC}"
    curl -s "${BASE_URL}/auth/me" \
      -H "Authorization: Bearer ${TOKEN}" | jq '.'
    echo ""

    # Test check auth
    echo -e "${BLUE}✅ Testing Check Auth...${NC}"
    curl -s "${BASE_URL}/auth/check" \
      -H "Authorization: Bearer ${TOKEN}" | jq '.'
    echo ""

    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           🎉 ALL TESTS COMPLETED! 🎉                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "📌 Test User:"
    echo "   Email: ${EMAIL}"
    echo "   Password: ${PASSWORD}"
    echo "   Token: ${TOKEN:0:50}..."
    echo ""
    echo "💡 API Docs: ${BASE_URL}/docs"
else
    echo -e "${RED}❌ Registration failed!${NC}"
fi
