# DNTWEAKS Key Server & Multi-Tier Admin Panel (Cloudflare Worker + D1)

Hệ thống máy chủ phân phối bản quyền, quản lý Key và phân quyền Đại lý (Sellers) cho ứng dụng **DNTWEAKS EXTERNAL IOS**.

---

## ⚡ Các Tính Năng Đã Tích Hợp Đầy Đủ

1. **Tương thích 100% với hệ thống cũ**:
   - Sử dụng bảng **`licenses`** từ database D1 gốc.
   - Tự động bổ sung các cột mới (`tier`, `allowed_modules`, `created_by`) mà không làm mất bất kỳ key cũ nào.
   - Hỗ trợ toàn bộ các API cũ:
     - `POST /api/v1/auth/login`: Kích hoạt & đăng nhập thiết bị
     - `POST /api/v1/auth/check`: Kiểm tra thời hạn, số ngày còn lại (`days_remaining`)
     - `POST /api/v1/auth/heartbeat`: Cập nhật `last_check_at` định kỳ
     - `GET  /health`: Kiểm tra trạng thái máy chủ
2. **API Mới Đồng Bộ Với App iOS ([LicenseManager.swift](file:///c:/Users/admin/Downloads/hello-main/hello-main/ThreeOneOSFive/helpers/LicenseManager.swift))**:
   - `POST /api/activate`: Nhận `{ key, hwid }`, trả về danh sách phân hệ được phép mở `allowedModules: ["aimlock", "sensitive", "regedit"]`.
   - `POST /api/verify`: Kiểm tra tính hợp lệ và thời hạn sử dụng.
3. **Tùy Chọn Phân Hệ Tinh Gọn (Checkbox & Quick Combos)**:
   - Checkbox độc lập cho từng tính năng:
     - `[✓] Aimlock VIP (V1 - V5)`
     - `[✓] Sensitive VIP (V1 - V5)`
     - `[✓] Regedit VIP (V1 - V5)`
   - Nút chọn combo siêu nhanh: `VIP ALL`, `Chỉ Aimlock`, `Chỉ Sensitive`, `Chỉ Regedit`, `Aim + Reg`, `Aim + Sens`.
   - Tự động sinh tiền tố nhận diện: `DNT-ALL-`, `DNT-AIM-`, `DNT-SENS-`, `DNT-REG-`, `DNT-COMBO-`.
4. **Phân Quyền 2 Cấp (Master Admin & Đại Lý - Sellers)**:
   - **Master Admin** (Đăng nhập bằng `ADMIN_SECRET`):
     - Tạo tài khoản cho Seller kèm mật khẩu và hạn mức (quota) số lượng key.
     - Xem và quản lý toàn bộ keys trong hệ thống.
     - Ban / Unban / Reset HWID / Xóa key.
   - **Seller** (Đăng nhập bằng Username & Mật khẩu do Admin cấp):
     - Tạo key trong phạm vi Quota được cấp.
     - Chỉ xem và quản lý danh sách key do chính mình tạo ra.
5. **Giao Diện Cyber Dark Glass tại `/admin`**:
   - Tông màu Dark Glassmorphism neon công nghệ cao.
   - Hỗ trợ Copy key 1-click, lọc theo trạng thái, tìm kiếm tức thì.

---

## 🚀 Hướng Dẫn Cập Nhật Lên Cloudflare Worker (1 Bước Duy Nhất)

### Cách 1: Copy-Paste Trực Tiếp Trên Trình Duyệt (Khuyên Dùng)
1. Đăng nhập [Cloudflare Dashboard](https://dash.cloudflare.com/) -> Vào mục **Workers & Pages**.
2. Chọn worker: **`dntweaks-key-server`**.
3. Nhấp nút **`</> Edit code`** ở góc trên bên phải.
4. Mở file [worker.js](file:///c:/Users/admin/Downloads/hello-main/hello-main/Cloudflare-Key-Server/worker.js), copy toàn bộ nội dung và dán đè vào trình soạn thảo của Cloudflare.
5. Nhấp **`Deploy`**. Hệ thống sẽ tự động cập nhật ngay lập tức!

### Cách 2: Deploy Bằng Wrangler CLI
```bash
cd Cloudflare-Key-Server
npx wrangler deploy
```

---

## ⚙️ Biến Môi Trường (Variables / Secrets)
Trong **Cloudflare Dashboard** -> Worker **`dntweaks-key-server`** -> **Settings** -> **Variables and Secrets**:
- `ADMIN_SECRET`: Mã bí mật quản trị viên cấp cao (Master Admin). Mặc định nếu không cài đặt sẽ là `DNTWEAKS_SECRET`.
- D1 Database Binding: Tên binding là **`DB`**, trỏ tới Database `dntweaks_keys`.
