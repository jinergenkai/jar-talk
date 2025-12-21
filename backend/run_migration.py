"""
Database Migration Script
Run this to apply pending migrations
"""

import pymysql
from src.cores.config import settings

def add_title_to_slip(cursor, db_name):
    """Migration 1: Add title column to slip table"""
    print("🔄 Migration 1: Add title column to slip table...")

    # Check if column already exists
    cursor.execute("""
        SELECT COUNT(*)
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = %s
        AND TABLE_NAME = 'slip'
        AND COLUMN_NAME = 'title'
    """, (db_name,))

    result = cursor.fetchone()

    if result[0] > 0:
        print("   ✅ Column 'title' already exists. Skipping.")
        return

    # Add the column
    cursor.execute("""
        ALTER TABLE slip
        ADD COLUMN title VARCHAR(255) NULL
        AFTER author_id
    """)

    print("   ✅ Added column: slip.title (VARCHAR(255) NULL)")


def create_invite_table(cursor, db_name):
    """Migration 2: Create invite table"""
    print("🔄 Migration 2: Create invite table...")

    # Check if table already exists
    cursor.execute("""
        SELECT COUNT(*)
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = %s
        AND TABLE_NAME = 'invite'
    """, (db_name,))

    result = cursor.fetchone()

    if result[0] > 0:
        print("   ✅ Table 'invite' already exists. Skipping.")
        return

    # Create the table
    cursor.execute("""
        CREATE TABLE invite (
            invite_id INT AUTO_INCREMENT PRIMARY KEY,
            container_id INT NOT NULL,
            invite_code VARCHAR(50) NOT NULL UNIQUE,
            created_by INT NOT NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            expires_at DATETIME NULL,
            max_uses INT NULL,
            current_uses INT NOT NULL DEFAULT 0,
            is_active BOOLEAN NOT NULL DEFAULT TRUE,

            FOREIGN KEY (container_id) REFERENCES container(container_id) ON DELETE CASCADE,
            FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE CASCADE,

            INDEX idx_invite_code (invite_code),
            INDEX idx_container_id (container_id),
            INDEX idx_created_by (created_by)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    """)

    print("   ✅ Created table: invite")


def create_comment_and_reaction_tables(cursor, db_name):
    """Migration 3: Create comment and slipreaction tables"""
    print("🔄 Migration 3: Create comment and slipreaction tables...")

    # Check if comment table already exists
    cursor.execute("""
        SELECT COUNT(*)
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = %s
        AND TABLE_NAME = 'comment'
    """, (db_name,))

    result = cursor.fetchone()

    if result[0] > 0:
        print("   ✅ Table 'comment' already exists. Skipping comment table creation.")
    else:
        # Create comment table
        cursor.execute("""
            CREATE TABLE comment (
                comment_id INT AUTO_INCREMENT PRIMARY KEY,
                slip_id INT NOT NULL,
                author_id INT NOT NULL,
                text_content TEXT NOT NULL,
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

                FOREIGN KEY (slip_id) REFERENCES slip(slip_id) ON DELETE CASCADE,
                FOREIGN KEY (author_id) REFERENCES user(user_id) ON DELETE CASCADE,

                INDEX idx_slip_id (slip_id),
                INDEX idx_author_id (author_id),
                INDEX idx_created_at (created_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        """)
        print("   ✅ Created table: comment")

    # Check if slipreaction table already exists
    cursor.execute("""
        SELECT COUNT(*)
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = %s
        AND TABLE_NAME = 'slipreaction'
    """, (db_name,))

    result = cursor.fetchone()

    if result[0] > 0:
        print("   ✅ Table 'slipreaction' already exists. Skipping.")
    else:
        # Create slipreaction table
        cursor.execute("""
            CREATE TABLE slipreaction (
                slip_reaction_id INT AUTO_INCREMENT PRIMARY KEY,
                slip_id INT NOT NULL,
                user_id INT NOT NULL,
                reaction_type VARCHAR(50) NOT NULL,
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

                FOREIGN KEY (slip_id) REFERENCES slip(slip_id) ON DELETE CASCADE,
                FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,

                UNIQUE KEY unique_user_slip_reaction (slip_id, user_id),

                INDEX idx_slip_id (slip_id),
                INDEX idx_user_id (user_id),
                INDEX idx_reaction_type (reaction_type)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        """)
        print("   ✅ Created table: slipreaction")


def run_migration():
    """Run all pending migrations"""

    connection = pymysql.connect(
        host=settings.DB_HOST,
        port=settings.DB_PORT,
        user=settings.DB_USER,
        password=settings.DB_PASSWORD,
        database=settings.DB_NAME
    )

    try:
        with connection.cursor() as cursor:
            print("\n" + "="*50)
            print("🚀 Running Database Migrations")
            print("="*50 + "\n")

            # Run all migrations
            add_title_to_slip(cursor, settings.DB_NAME)
            create_invite_table(cursor, settings.DB_NAME)
            create_comment_and_reaction_tables(cursor, settings.DB_NAME)

            connection.commit()

            print("\n" + "="*50)
            print("✅ All migrations completed successfully!")
            print("="*50 + "\n")

    except Exception as e:
        print(f"\n❌ Migration failed: {e}")
        connection.rollback()
        raise

    finally:
        connection.close()


if __name__ == "__main__":
    run_migration()
