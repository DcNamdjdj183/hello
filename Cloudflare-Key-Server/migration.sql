ALTER TABLE licenses ADD COLUMN tier TEXT DEFAULT 'all';
ALTER TABLE licenses ADD COLUMN allowed_modules TEXT DEFAULT 'aimlock,sensitive,regedit';
ALTER TABLE licenses ADD COLUMN created_by TEXT DEFAULT 'admin';

CREATE TABLE IF NOT EXISTS sellers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    name TEXT,
    role TEXT NOT NULL DEFAULT 'seller',
    allowed_tiers TEXT NOT NULL DEFAULT 'all,aimlock,sensitive,regedit',
    max_keys INTEGER DEFAULT 0,
    used_keys INTEGER DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_licenses_created_by ON licenses(created_by);
CREATE INDEX IF NOT EXISTS idx_licenses_status ON licenses(status);
