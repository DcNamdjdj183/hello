-- DNTWEAKS KEY SERVER - D1 DATABASE SCHEMA
-- Database name: dntweaks_keys

-- 1. Bảng lưu trữ Keys
CREATE TABLE IF NOT EXISTS keys (
    key TEXT PRIMARY KEY,
    tier TEXT NOT NULL DEFAULT 'all',              -- 'all', 'aimlock', 'sensitive', 'regedit' hoặc combo tổ hợp: 'aimlock,regedit', 'aimlock,sensitive'...
    created_by TEXT NOT NULL DEFAULT 'admin',     -- 'admin' hoặc username của seller
    duration_days INTEGER NOT NULL DEFAULT 30,    -- -1 là vĩnh viễn (Lifetime), số dương là số ngày
    device_id TEXT,                               -- Khóa HWID thiết bị khi kích hoạt lần đầu
    max_devices INTEGER DEFAULT 1,                -- Số thiết bị tối đa được phép dùng key này
    status TEXT NOT NULL DEFAULT 'UNUSED',         -- 'UNUSED', 'ACTIVE', 'BANNED', 'EXPIRED'
    note TEXT,                                    -- Ghi chú tên khách, đơn hàng...
    created_at TEXT NOT NULL,                     -- ISO timestamp
    activated_at TEXT,                            -- ISO timestamp khi kích hoạt lần đầu
    expires_at TEXT                               -- ISO timestamp khi hết hạn
);

-- 2. Bảng lưu trữ Sellers & Admins
CREATE TABLE IF NOT EXISTS sellers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,                -- Tên đăng nhập seller
    password TEXT NOT NULL,                       -- Mật khẩu đăng nhập
    name TEXT,                                    -- Tên hiển thị của seller
    role TEXT NOT NULL DEFAULT 'seller',          -- 'admin' hoặc 'seller'
    allowed_tiers TEXT NOT NULL DEFAULT 'all,aimlock,sensitive,regedit', -- Các loại key seller được phép tạo
    max_keys INTEGER DEFAULT 0,                   -- Giới hạn số key seller được tạo (0 = không giới hạn)
    status TEXT NOT NULL DEFAULT 'active',        -- 'active' hoặc 'blocked'
    created_at TEXT NOT NULL                      -- ISO timestamp
);

-- Chỉ mục tối ưu tìm kiếm
CREATE INDEX IF NOT EXISTS idx_keys_created_by ON keys(created_by);
CREATE INDEX IF NOT EXISTS idx_keys_status ON keys(status);
CREATE INDEX IF NOT EXISTS idx_keys_tier ON keys(tier);
CREATE INDEX IF NOT EXISTS idx_keys_device_id ON keys(device_id);
