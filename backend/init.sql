-- Initialize database with UTF-8 support
CREATE DATABASE IF NOT EXISTS jar_talk CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE jar_talk;

-- Grant privileges to jar_user
GRANT ALL PRIVILEGES ON jar_talk.* TO 'jar_user'@'%';
FLUSH PRIVILEGES;
