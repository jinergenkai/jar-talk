SHARED JOURNALING APPLICATION - ENTITY-RELATIONSHIP (ER) MODEL

=== ENTITIES AND ATTRIBUTES (COLUMNS) ===

1. USER (PK: user_id)
   - user_id (Primary Key)
   - username
   - email
   - password_hash
   - profile_picture_url
   - created_at

2. CONTAINER (Jar) (PK: container_id)
   - container_id (Primary Key)
   - name
   - owner_id (Foreign Key to User)
   - jar_style_settings (JSON or text field for customization)
   - created_at

3. SLIP (Journal Entry) (PK: slip_id)
   - slip_id (Primary Key)
   - container_id (Foreign Key to Container)
   - author_id (Foreign Key to User)
   - text_content
   - created_at
   - location_data (Optional: coordinates, city)

4. MEDIA (PK: media_id)
   - media_id (Primary Key)
   - slip_id (Foreign Key to Slip)
   - media_type ('image', 'audio')
   - storage_url (Link to file storage)
   - caption

5. COMMENT (PK: comment_id)
   - comment_id (Primary Key)
   - slip_id (Foreign Key to Slip)
   - author_id (Foreign Key to User)
   - text_content
   - created_at

6. TAG (PK: tag_id)
   - tag_id (Primary Key)
   - tag_name ('Work', 'Travel', 'Gratitude', etc.)

7. EMOTIONLOG (PK: emotion_log_id)
   - emotion_log_id (Primary Key)
   - slip_id (Foreign Key to Slip)
   - emotion_type ('happy', 'sad', 'anxious', etc.)
   - logged_at

8. STREAK (PK: streak_id)
   - streak_id (Primary Key)
   - user_id (Foreign Key to User)
   - current_streak_days
   - last_slip_date
   - longest_streak_days

=== JUNCTION TABLES (M:N Relationships & Access) ===

9. MEMBERSHIP (PK: participant_id) 
    - participant_id (Primary Key)
    - user_id (Foreign Key to User)
    - container_id (Foreign Key to Container)
    - role ('admin', 'member')
    - joined_at

10. SLIPTAG (PK: slip_tag_id)
    - slip_tag_id (Primary Key)
    - slip_id (Foreign Key to Slip)
    - tag_id (Foreign Key to Tag)

11. SLIPREACTION (PK: slip_reaction_id)
    - slip_reaction_id (Primary Key)
    - slip_id (Foreign Key to Slip)
    - user_id (Foreign Key to User)
    - reaction_type ('Heart', 'Fire', 'Resonate', etc.)
    - created_at

=== KEY RELATIONSHIPS (CARDINALITY) ===

- USER <--> CONTAINER: Many-to-Many (via JARPARTICIPANT)
- SLIP <--> USER: Many-to-Many (via SLIPREACTION) - (The new reaction mechanism)
- CONTAINER --> SLIP: One-to-Many
- USER --> SLIP: One-to-Many
- SLIP --> MEDIA: One-to-Many
- SLIP --> EMOTIONLOG: One-to-One
- SLIP <--> TAG: Many-to-Many (via SLIPTAG)
- SLIP --> COMMENT: One-to-Many
- USER --> STREAK: One-to-One



erDiagram
    %% ENTITIES
    USER {
        int user_id PK
        varchar username
        varchar email
        varchar password_hash
        varchar profile_picture_url
        datetime created_at
    }

    CONTAINER {
        int container_id PK
        varchar name
        int owner_id FK
        text jar_style_settings
        datetime created_at
    }

    SLIP {
        int slip_id PK
        int container_id FK
        int author_id FK
        text text_content
        datetime created_at
        varchar location_data
    }

    MEDIA {
        int media_id PK
        int slip_id FK
        varchar media_type
        varchar storage_url
        varchar caption
    }

    COMMENT {
        int comment_id PK
        int slip_id FK
        int author_id FK
        text text_content
        datetime created_at
    }

    TAG {
        int tag_id PK
        varchar tag_name
    }

    EMOTIONLOG {
        int emotion_log_id PK
        int slip_id FK
        varchar emotion_type
        datetime logged_at
    }

    STREAK {
        int streak_id PK
        int user_id FK
        int current_streak_days
        datetime last_slip_date
        int longest_streak_days
    }

    %% JUNCTION TABLES
    MEMBERSHIP {
        int participant_id PK
        int user_id FK
        int container_id FK
        varchar role
        datetime joined_at
    }

    SLIPTAG {
        int slip_tag_id PK
        int slip_id FK
        int tag_id FK
    }

    SLIPREACTION {
        int slip_reaction_id PK
        int slip_id FK
        int user_id FK
        varchar reaction_type
        datetime created_at
    }

    %% RELATIONSHIPS
    USER ||--o{ MEMBERSHIP : has
    CONTAINER ||--o{ MEMBERSHIP : includes

    USER ||--o{ SLIPREACTION : applies
    SLIP ||--o{ SLIPREACTION : receives

    CONTAINER ||--o{ SLIP : contains
    USER ||--o{ SLIP : authors

    SLIP ||--o{ MEDIA : has
    SLIP ||--o{ COMMENT : discusses

    SLIP ||--o{ SLIPTAG : is_tagged_with
    TAG ||--o{ SLIPTAG : tags

    SLIP ||--|{ EMOTIONLOG : logs

    USER ||--|{ STREAK : tracks