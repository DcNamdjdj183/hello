-- ============================================================================
-- DNTWEAKS EXTERNAL IOS - D1 DATABASE SCHEMA
-- Database name: dntweaks_keys
-- Table: licenses (Đồng bộ toàn diện với hệ thống cũ và mới)
-- ============================================================================

-- 1. Bảng Lưu Trữ Bản Quyền Keys (Bảng licenses chính)
CREATE TABLE IF NOT EXISTS licenses (
    key TEXT PRIMARY KEY,
    product TEXT DEFAULT 'DNTWEAKS-VIP-ALL',
    tier TEXT DEFAULT 'all',                                    -- 'all', 'aimlock', 'sensitive', 'regedit' hoặc combo: 'aimlock,regedit'
    allowed_modules TEXT DEFAULT 'aimlock,sensitive,regedit',   -- Danh sách phân hệ được mở trên iOS App
    duration_days INTEGER NOT NULL DEFAULT 30,                  -- -1 là vĩnh viễn (Lifetime), số dương là số ngày
    max_devices INTEGER DEFAULT 1,                              -- Số thiết bị tối đa được dùng
    note TEXT,                                                  -- Ghi chú tên khách, đơn hàng...
    status TEXT NOT NULL DEFAULT 'UNUSED',                      -- 'UNUSED', 'ACTIVE', 'BANNED', 'REVOKED', 'EXPIRED'
    device_id TEXT,                                             -- HWID thiết bị khi kích hoạt lần đầu
    device_name TEXT,                                           -- Tên thiết bị (ví dụ: iPhone 13 Pro Max)
    created_by TEXT NOT NULL DEFAULT 'admin',                   -- 'admin' hoặc username của seller tạo key
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,                  -- Ngày tạo
    activated_at TEXT,                                          -- Thời điểm kích hoạt lần đầu
    expires_at TEXT,                                            -- Thời điểm hết hạn sử dụng
    last_check_at TEXT                                          -- Heartbeat kiểm tra trạng thái gần nhất
);

-- 2. Bảng Quản Lý Đại Lý & Quản Trị Viên (Sellers)
CREATE TABLE IF NOT EXISTS sellers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,                              -- Tên đăng nhập seller
    password TEXT NOT NULL,                                     -- Mật khẩu
    name TEXT,                                                  -- Tên hiển thị của đại lý
    role TEXT NOT NULL DEFAULT 'seller',                        -- 'admin' hoặc 'seller'
    allowed_tiers TEXT NOT NULL DEFAULT 'all,aimlock,sensitive,regedit', -- Phân hệ seller được cấp phép bán
    max_keys INTEGER DEFAULT 0,                                 -- Giới hạn số key seller được tạo (0 = vô hạn)
    used_keys INTEGER DEFAULT 0,                                -- Số key seller đã tạo thực tế
    status TEXT NOT NULL DEFAULT 'active',                      -- 'active' hoặc 'blocked'
    created_at TEXT DEFAULT CURRENT_TIMESTAMP                   -- Thời điểm đăng ký
);

-- 3. Chỉ mục tối ưu hóa tốc độ truy vấn D1
CREATE INDEX IF NOT EXISTS idx_licenses_created_by ON licenses(created_by);
CREATE INDEX IF NOT EXISTS idx_licenses_status ON licenses(status);
CREATE INDEX IF NOT EXISTS idx_licenses_tier ON licenses(tier);
CREATE INDEX IF NOT EXISTS idx_licenses_device_id ON licenses(device_id);

-- ============================================================================
-- LỆNH NÂNG CẤP NẾU BẢNG 'licenses' ĐÃ TỒN TẠI TỪ BẢN CŨ TRÊN CLOUDFLARE D1
-- (Có thể chạy trực tiếp trong D1 Console nếu chưa có các cột mới)
-- ============================================================================
-- ALTER TABLE licenses ADD COLUMN tier TEXT DEFAULT 'all';
-- ALTER TABLE licenses ADD COLUMN allowed_modules TEXT DEFAULT 'aimlock,sensitive,regedit';
-- ALTER TABLE licenses ADD COLUMN created_by TEXT DEFAULT 'admin';
