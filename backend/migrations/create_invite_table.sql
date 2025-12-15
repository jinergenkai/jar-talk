-- Migration: Create invite table
-- Date: 2025-12-15

CREATE TABLE IF NOT EXISTS invite (
    invite_id INT AUTO_INCREMENT PRIMARY KEY,
    container_id INT NOT NULL,
    invite_code VARCHAR(50) NOT NULL UNIQUE,
    created_by INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NULL,
    max_uses INT NULL,
    current_uses INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    -- Foreign keys
    FOREIGN KEY (container_id) REFERENCES container(container_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE CASCADE,

    -- Indexes
    INDEX idx_invite_code (invite_code),
    INDEX idx_container_id (container_id),
    INDEX idx_created_by (created_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Verify the table
DESCRIBE invite;
