-- Migration: Create comment and slipreaction tables
-- Date: 2025-12-15

-- Create comment table
CREATE TABLE IF NOT EXISTS comment (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    slip_id INT NOT NULL,
    author_id INT NOT NULL,
    text_content TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    FOREIGN KEY (slip_id) REFERENCES slip(slip_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES user(user_id) ON DELETE CASCADE,

    -- Indexes
    INDEX idx_slip_id (slip_id),
    INDEX idx_author_id (author_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create slipreaction table
CREATE TABLE IF NOT EXISTS slipreaction (
    slip_reaction_id INT AUTO_INCREMENT PRIMARY KEY,
    slip_id INT NOT NULL,
    user_id INT NOT NULL,
    reaction_type VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    FOREIGN KEY (slip_id) REFERENCES slip(slip_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,

    -- Unique constraint: one reaction per user per slip
    UNIQUE KEY unique_user_slip_reaction (slip_id, user_id),

    -- Indexes
    INDEX idx_slip_id (slip_id),
    INDEX idx_user_id (user_id),
    INDEX idx_reaction_type (reaction_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Verify the tables
DESCRIBE comment;
DESCRIBE slipreaction;
