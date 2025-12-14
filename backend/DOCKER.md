# Docker Setup Guide

Hướng dẫn chạy Jar Talk Backend với Docker và Docker Compose.

## Yêu cầu

- Docker Desktop (hoặc Docker Engine + Docker Compose)
- Port 8000 và 3307 available

## Files Docker

- **Dockerfile**: Build image cho FastAPI backend
- **docker-compose.yml**: Orchestration cho services (API + MySQL)
- **init.sql**: Initialize database script
- **.dockerignore**: Files được ignore khi build image
- **docker-start.sh** / **docker-start.bat**: Script để start nhanh

## Cách sử dụng

### Option 1: Sử dụng script (Khuyến nghị)

**Windows:**
```bash
docker-start.bat
```

**Linux/Mac:**
```bash
chmod +x docker-start.sh
./docker-start.sh
```

### Option 2: Sử dụng Docker Compose trực tiếp

```bash
# Start containers
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose down

# Restart containers
docker-compose restart

# Stop and remove volumes (xóa data)
docker-compose down -v
```

## Services

Sau khi start thành công:

- **API Server**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **API Redoc**: http://localhost:8000/redoc
- **MySQL Database**: localhost:3307

## Database Connection

Từ host machine:
```
Host: localhost
Port: 3307
User: jar_user
Password: jar_password
Database: jar_talk
```

Từ containers khác trong network:
```
Host: db
Port: 3306
User: jar_user
Password: jar_password
Database: jar_talk
```

## Firebase Setup (Optional)

Nếu muốn sử dụng Firebase authentication:

1. Tải Firebase credentials JSON file
2. Đặt file vào `backend/firebase-credentials.json`
3. Uncomment dòng volume trong `docker-compose.yml`:
   ```yaml
   volumes:
     - ./:/app
     - ./firebase-credentials.json:/app/firebase-credentials.json  # Uncomment this
   ```
4. Uncomment environment variables trong `docker-compose.yml`:
   ```yaml
   environment:
     FIREBASE_CREDENTIALS_PATH: /app/firebase-credentials.json
     FIREBASE_WEB_API_KEY: your_web_api_key
   ```
5. Restart containers: `docker-compose restart api`

## Useful Commands

### View logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api
docker-compose logs -f db
```

### Execute commands in containers
```bash
# Access API container shell
docker-compose exec api bash

# Access MySQL
docker-compose exec db mysql -u jar_user -pjar_password jar_talk
```

### Database operations
```bash
# Backup database
docker-compose exec db mysqldump -u jar_user -pjar_password jar_talk > backup.sql

# Restore database
docker-compose exec -T db mysql -u jar_user -pjar_password jar_talk < backup.sql

# Reset database
docker-compose down -v
docker-compose up -d
```

### Rebuild containers
```bash
# Rebuild specific service
docker-compose up --build -d api

# Rebuild all
docker-compose up --build -d

# Force rebuild (no cache)
docker-compose build --no-cache
docker-compose up -d
```

## Troubleshooting

### Port already in use
```bash
# Check what's using port 8000
netstat -ano | findstr :8000  # Windows
lsof -i :8000                 # Linux/Mac

# Change port in docker-compose.yml
ports:
  - "8001:8000"  # Host:Container
```

### Database connection failed
```bash
# Check if DB is healthy
docker-compose ps

# View DB logs
docker-compose logs db

# Wait for DB to be ready (takes ~10-15 seconds on first start)
docker-compose exec db mysqladmin ping -h localhost -u root -prootpassword
```

### Permission issues (Linux/Mac)
```bash
# Fix permissions
sudo chown -R $USER:$USER .

# Run with sudo if needed
sudo docker-compose up -d
```

### Container keeps restarting
```bash
# Check logs for errors
docker-compose logs api

# Common issues:
# 1. Database not ready yet - wait 10-15 seconds
# 2. Missing dependencies - rebuild: docker-compose up --build
# 3. Syntax error in code - check logs for Python errors
```

### Clean restart
```bash
# Stop everything
docker-compose down -v

# Remove all Docker resources
docker system prune -a --volumes

# Start fresh
docker-compose up --build -d
```

## Development Workflow

### Code changes
Code changes được auto-reload nhờ volume mount và `--reload` flag. Không cần restart container.

### Install new dependencies
```bash
# Update requirements.txt
# Then rebuild
docker-compose up --build -d api
```

### Database schema changes
SQLModel sẽ tự động tạo tables khi start. Để force recreate:
```bash
docker-compose down -v  # Remove volumes
docker-compose up -d    # Recreate
```

## Production Deployment

Để deploy production:

1. **Update docker-compose.yml**:
   ```yaml
   environment:
     DEBUG: "False"
     SECRET_KEY: "your-strong-random-secret-key"
   ```

2. **Remove --reload**:
   ```yaml
   command: uvicorn app:app --host 0.0.0.0 --port 8000 --workers 4
   ```

3. **Add reverse proxy (nginx)**
4. **Use environment file instead of hardcoded values**
5. **Enable HTTPS**
6. **Set proper ALLOWED_ORIGINS**

## Testing API

### Using curl
```bash
# Health check
curl http://localhost:8000/health

# Register user
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Using API Docs
Mở browser: http://localhost:8000/docs

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
