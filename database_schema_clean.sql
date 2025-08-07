CREATE TABLE IF NOT EXISTS "_prisma_migrations" (
    "id"                    TEXT PRIMARY KEY NOT NULL,
    "checksum"              TEXT NOT NULL,
    "finished_at"           DATETIME,
    "migration_name"        TEXT NOT NULL,
    "logs"                  TEXT,
    "rolled_back_at"        DATETIME,
    "started_at"            DATETIME NOT NULL DEFAULT current_timestamp,
    "applied_steps_count"   INTEGER UNSIGNED NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS "newspost" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "category" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "slug" TEXT,
    "created" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "account_session" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "account_id" INTEGER NOT NULL,
    "world" INTEGER NOT NULL DEFAULT 0,
    "profile" TEXT NOT NULL DEFAULT 'main',
    "session_uuid" TEXT NOT NULL,
    "timestamp" DATETIME NOT NULL,
    "coord" INTEGER NOT NULL,
    "event" TEXT NOT NULL,
    "event_type" INTEGER NOT NULL DEFAULT -1
);
CREATE TABLE IF NOT EXISTS "hiscore" (
    "profile" TEXT NOT NULL DEFAULT 'main',
    "account_id" INTEGER NOT NULL,
    "type" INTEGER NOT NULL,
    "level" INTEGER NOT NULL,
    "value" INTEGER NOT NULL,
    "date" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("profile", "account_id", "type")
);
CREATE TABLE IF NOT EXISTS "hiscore_large" (
    "profile" TEXT NOT NULL DEFAULT 'main',
    "account_id" INTEGER NOT NULL,
    "type" INTEGER NOT NULL,
    "level" INTEGER NOT NULL,
    "value" BIGINT NOT NULL,
    "date" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("profile", "account_id", "type")
);
CREATE TABLE IF NOT EXISTS "session" (
    "uuid" TEXT NOT NULL PRIMARY KEY,
    "account_id" INTEGER NOT NULL,
    "profile" TEXT NOT NULL,
    "world" INTEGER NOT NULL,
    "timestamp" DATETIME NOT NULL,
    "uid" INTEGER NOT NULL,
    "ip" TEXT
);
CREATE TABLE IF NOT EXISTS "report" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "account_id" INTEGER NOT NULL,
    "profile" TEXT NOT NULL,
    "world" INTEGER NOT NULL,
    "timestamp" DATETIME NOT NULL,
    "coord" INTEGER NOT NULL,
    "offender" TEXT NOT NULL,
    "reason" INTEGER NOT NULL
, `reviewed` BOOLEAN NOT NULL DEFAULT false);
CREATE TABLE IF NOT EXISTS "private_chat" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "account_id" INTEGER NOT NULL,
    "profile" TEXT NOT NULL,
    "timestamp" DATETIME NOT NULL,
    "coord" INTEGER NOT NULL,
    "to_account_id" INTEGER NOT NULL,
    "message" TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS "public_chat" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "account_id" INTEGER NOT NULL,
    "profile" TEXT NOT NULL,
    "world" INTEGER NOT NULL,
    "timestamp" DATETIME NOT NULL,
    "coord" INTEGER NOT NULL,
    "message" TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS "login" (
    "uuid" TEXT NOT NULL PRIMARY KEY,
    "account_id" INTEGER NOT NULL,
    "world" INTEGER NOT NULL,
    "timestamp" DATETIME NOT NULL,
    "uid" INTEGER NOT NULL,
    "ip" TEXT
);
CREATE TABLE IF NOT EXISTS "ipban" (
    "ip" TEXT NOT NULL PRIMARY KEY
);
CREATE TABLE IF NOT EXISTS "friendlist" (
    "account_id" INTEGER NOT NULL,
    "friend_account_id" INTEGER NOT NULL,
    "created" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("account_id", "friend_account_id")
);
CREATE TABLE IF NOT EXISTS "input_report_event_raw" (
    "input_report_id" INTEGER NOT NULL,
    "seq" INTEGER NOT NULL,
    "coord" INTEGER NOT NULL,
    "data" BLOB NOT NULL,

    PRIMARY KEY ("input_report_id", "seq")
);
CREATE TABLE IF NOT EXISTS "ignorelist" (
    "account_id" INTEGER NOT NULL,
    "value" TEXT NOT NULL,
    "created" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("account_id", "value")
);
CREATE TABLE IF NOT EXISTS "input_report" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "account_id" INTEGER NOT NULL,
    "timestamp" DATETIME NOT NULL,
    "session_uuid" TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS "message_status" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "thread_id" INTEGER NOT NULL,
    "account_id" INTEGER NOT NULL,
    "read" DATETIME,
    "deleted" DATETIME
);
CREATE TABLE IF NOT EXISTS "account_tag" (
    "tag_id" INTEGER NOT NULL,
    "account_id" INTEGER NOT NULL,

    PRIMARY KEY ("account_id", "tag_id")
);
CREATE TABLE IF NOT EXISTS "account" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "username" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "email" TEXT,
    "registration_ip" TEXT,
    "registration_date" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "logged_in" INTEGER NOT NULL DEFAULT 0,
    "login_time" DATETIME,
    "logged_out" INTEGER NOT NULL DEFAULT 0,
    "logout_time" DATETIME,
    "muted_until" DATETIME,
    "banned_until" DATETIME,
    "staffmodlevel" INTEGER NOT NULL DEFAULT 0,
    "notes" TEXT,
    "notes_updated" DATETIME,
    "members" BOOLEAN NOT NULL DEFAULT false,
    "tfa_enabled" BOOLEAN NOT NULL DEFAULT false,
    "tfa_last_code" INTEGER NOT NULL DEFAULT 0,
    "tfa_secret_base32" TEXT,
    "tfa_incorrect_attempts" INTEGER NOT NULL DEFAULT 0
, "oauth_provider" TEXT, "password_updated" DATETIME, pin TEXT, pin_enabled INTEGER DEFAULT 0);
CREATE UNIQUE INDEX "account_username_key" ON "account"("username");
CREATE TABLE IF NOT EXISTS "wealth_event" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "timestamp" DATETIME NOT NULL,
    "coord" INTEGER NOT NULL,
    "world" INTEGER NOT NULL DEFAULT 0,
    "profile" TEXT NOT NULL DEFAULT 'main',
    "event_type" INTEGER NOT NULL DEFAULT -1,
    "account_id" INTEGER NOT NULL,
    "account_session" TEXT NOT NULL,
    "account_items" TEXT NOT NULL,
    "account_value" INTEGER NOT NULL,
    "recipient_id" INTEGER,
    "recipient_session" TEXT,
    "recipient_items" TEXT,
    "recipient_value" INTEGER
);
CREATE INDEX "wealth_event_recipient_id_idx" ON "wealth_event"("recipient_id");
CREATE TABLE IF NOT EXISTS "message_tag" (
    "tag_id" INTEGER NOT NULL,
    "thread_id" INTEGER NOT NULL,

    PRIMARY KEY ("thread_id", "tag_id")
);
CREATE TABLE IF NOT EXISTS "message" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "thread_id" INTEGER NOT NULL,
    "sender_id" INTEGER NOT NULL,
    "sender_ip" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "created" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "edited" DATETIME,
    "edited_by" INTEGER,
    "deleted" DATETIME,
    "deleted_by" INTEGER
);
CREATE TABLE IF NOT EXISTS "message_thread" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "to_account_id" INTEGER,
    "from_account_id" INTEGER NOT NULL,
    "last_message_from" INTEGER NOT NULL,
    "subject" TEXT NOT NULL,
    "created" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "messages" INTEGER NOT NULL DEFAULT 1,
    "closed" DATETIME,
    "closed_by" INTEGER,
    "marked_spam" DATETIME,
    "marked_spam_by" INTEGER
);
CREATE TABLE IF NOT EXISTS "tag" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "color" TEXT,
    "category" INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE news (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        author_id INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        is_active INTEGER DEFAULT 1
    );
CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
    );
CREATE TABLE site_content (
                    key TEXT PRIMARY KEY,
                    value TEXT NOT NULL
                );
CREATE TABLE theme_settings (
                    key TEXT PRIMARY KEY,
                    value TEXT NOT NULL
                );
CREATE TABLE game_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    category TEXT,
    type TEXT,
    description TEXT,
    requires_restart INTEGER DEFAULT 0,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
CREATE TABLE mod_action (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        target_id INTEGER,
        action TEXT NOT NULL,
        reason TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    );
CREATE TABLE chat_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        username TEXT NOT NULL,
        message TEXT NOT NULL,
        chat_type TEXT NOT NULL,
        target_username TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (account_id) REFERENCES account(id)
    );
CREATE TABLE admin_login_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        username TEXT NOT NULL,
        ip_address TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (account_id) REFERENCES account(id)
    );
CREATE TABLE moderator_permissions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        permission_key TEXT NOT NULL UNIQUE,
        permission_name TEXT NOT NULL,
        permission_description TEXT,
        enabled INTEGER DEFAULT 1
    );
CREATE TABLE moderator_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        moderator_id INTEGER NOT NULL,
        moderator_name TEXT NOT NULL,
        action TEXT NOT NULL,
        target_name TEXT,
        details TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (moderator_id) REFERENCES account(id)
    );
