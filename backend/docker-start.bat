@echo off
echo Starting Jar Talk Backend with Docker...
echo.

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

REM Stop and remove existing containers
echo Cleaning up existing containers...
docker-compose down

REM Build and start containers
echo Building and starting containers...
docker-compose up --build -d

REM Wait for database to be ready
echo Waiting for database to be ready...
timeout /t 10 /nobreak >nul

echo.
echo Containers started successfully!
echo.
echo Services:
echo    - API: http://localhost:8000
echo    - API Docs: http://localhost:8000/docs
echo    - MySQL: localhost:3307
echo.
echo Useful commands:
echo    - View logs: docker-compose logs -f
echo    - Stop: docker-compose down
echo    - Restart: docker-compose restart
echo.
echo Press Ctrl+C to stop viewing logs...
docker-compose logs -f
