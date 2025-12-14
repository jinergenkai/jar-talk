-- Migration: Add title column to slip table
-- Date: 2025-12-15

ALTER TABLE slip
ADD COLUMN title VARCHAR(255) NULL
AFTER author_id;

-- Verify the change
DESCRIBE slip;
