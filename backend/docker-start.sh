#!/bin/bash

echo "🚀 Starting Jar Talk Backend with Docker..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Stop and remove existing containers
echo "🧹 Cleaning up existing containers..."
docker-compose down

# Build and start containers
echo "🏗️  Building and starting containers..."
docker-compose up --build -d

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Show logs
echo ""
echo "✅ Containers started successfully!"
echo ""
echo "📊 Services:"
echo "   - API: http://localhost:8000"
echo "   - API Docs: http://localhost:8000/docs"
echo "   - MySQL: localhost:3307"
echo ""
echo "📝 Useful commands:"
echo "   - View logs: docker-compose logs -f"
echo "   - Stop: docker-compose down"
echo "   - Restart: docker-compose restart"
echo ""
echo "🔍 Checking API health..."
sleep 5
curl -s http://localhost:8000/health || echo "⚠️  API not ready yet, please wait a moment"

echo ""
echo "📋 Viewing logs (press Ctrl+C to exit)..."
docker-compose logs -f
