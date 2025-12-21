# Database Migrations

## How to Run Migrations

### Option 1: Using Python Script (Recommended)

```bash
# From backend directory
python run_migration.py
```

The script will:
- ✅ Check if migration is already applied
- ✅ Skip if already done
- ✅ Apply migration if needed
- ✅ Show clear success/error messages

### Option 2: Manual SQL Execution

Connect to MySQL and run the SQL file:

```bash
# Using MySQL CLI
mysql -h localhost -u root -p jar_talk < migrations/add_title_to_slip.sql

# Or using Docker
docker exec -i jar_talk_db mysql -u root -ppassword jar_talk < migrations/add_title_to_slip.sql
```

### Option 3: Via Docker Compose

```bash
# Copy SQL into running container and execute
docker cp migrations/add_title_to_slip.sql jar_talk_db:/tmp/
docker exec jar_talk_db mysql -u root -ppassword jar_talk -e "source /tmp/add_title_to_slip.sql"
```

## Migration History

| Date | File | Description |
|------|------|-------------|
| 2025-12-15 | `add_title_to_slip.sql` | Add `title` column to `slip` table |
| 2025-12-15 | `create_invite_table.sql` | Create `invite` table for invite system |
| 2025-12-15 | `create_comment_and_reaction_tables.sql` | Create `comment` and `slipreaction` tables |

## Creating New Migrations

When you modify database schema:

1. **Create SQL file**: `migrations/description.sql`
2. **Update run_migration.py**: Add migration logic
3. **Update this README**: Document the migration
4. **Test**: Run migration on development database first

## Rolling Back

To remove the title column (if needed):

```sql
ALTER TABLE slip DROP COLUMN title;
```
