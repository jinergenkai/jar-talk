"""
Database Migration Script
Run this to apply pending migrations
"""

import pymysql
from src.cores.config import settings

def run_migration():
    """Add title column to slip table"""

    connection = pymysql.connect(
        host=settings.DB_HOST,
        port=settings.DB_PORT,
        user=settings.DB_USER,
        password=settings.DB_PASSWORD,
        database=settings.DB_NAME
    )

    try:
        with connection.cursor() as cursor:
            print("🔄 Running migration: Add title column to slip table...")

            # Check if column already exists
            cursor.execute("""
                SELECT COUNT(*)
                FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = %s
                AND TABLE_NAME = 'slip'
                AND COLUMN_NAME = 'title'
            """, (settings.DB_NAME,))

            result = cursor.fetchone()

            if result[0] > 0:
                print("✅ Column 'title' already exists in 'slip' table. Skipping migration.")
                return

            # Add the column
            cursor.execute("""
                ALTER TABLE slip
                ADD COLUMN title VARCHAR(255) NULL
                AFTER author_id
            """)

            connection.commit()
            print("✅ Migration completed successfully!")
            print("   Added column: slip.title (VARCHAR(255) NULL)")

    except Exception as e:
        print(f"❌ Migration failed: {e}")
        connection.rollback()
        raise

    finally:
        connection.close()


if __name__ == "__main__":
    run_migration()
