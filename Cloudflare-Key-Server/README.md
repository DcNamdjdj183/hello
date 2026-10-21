# DNTWEAKS KEY SERVER & MULTI-TIER ADMIN PANEL

Server quản lý Key và xác thực bản quyền cho ứng dụng **DNTWEAKS EXTERNAL IOS** trên nền tảng Cloudflare Workers & Cloudflare D1 Database (`dntweaks_keys`).

---

## 1. CÁC TÍNH NĂNG NỔI BẬT

1. **Phân Quyền 2 Cấp Độ**:
   - **Master Admin (Bạn)**: Toàn quyền tạo tài khoản Seller, phân quyền loại key được phép tạo cho từng Seller, xem toàn bộ thống kê và quản lý toàn bộ Key trên hệ thống.
   - **Seller (Đại Lý)**: Đăng nhập bằng tài khoản Admin cấp, chỉ tạo được các loại Key trong phạm vi được cho phép, chỉ xem và quản lý danh sách Key do chính mình tạo ra.

2. **Tùy Biến Phân Hệ Linh Hoạt & Khóa Làm Mờ Trực Quan**:
   - Cho phép tích chọn bất kỳ tổ hợp tính năng nào khi tạo Key:
     - `AIMLOCK VIP (V1 - V5)`
     - `SENSITIVE VIP (V1 - V5)`
     - `REGEDIT VIP (V1 - V5)`
     - Hoặc tạo combo: `Aimlock + Regedit`, `Aimlock + Sensitive`, hoặc `VIP Toàn Bộ (All Access)`.
   - **Cơ chế khóa & làm mờ trên App iOS**:
     - Khi người dùng nhập Key vào App, hệ thống sẽ xác thực và chỉ mở đúng các mục được cấp quyền.
     - Các phân hệ không được cấp quyền sẽ tự động **bị khóa và làm mờ** (`blur(2.5px)` + giảm opacity `0.35` + vô hiệu hóa tương tác) kèm biểu tượng `🔒 CHƯA ĐƯỢC CẤP QUYỀN`.
     - Thẻ trạng thái Key hiển thị rõ 3 huy hiệu `[✓ AIMLOCK]`, `[✓ SENSITIVE]`, `[✓ REGEDIT]` giúp người dùng nhận diện ngay gói quyền hạn của mình.

3. **Bảo Mật Khóa Thiết Bị (HWID Lock)**:
   - Tự động gắn thiết bị khi người dùng nhập key lần đầu vào App.
   - Ngăn chặn chia sẻ key sang máy khác (Báo lỗi `DEVICE_MISMATCH`).
   - Admin và Seller có nút **Reset ID** chỉ với 1 click nếu khách đổi máy.

---

## 2. HƯỚNG DẪN CẬP NHẬT LÊN CLOUDFLARE WORKERS (Chỉ mất 1 phút)

1. Mở trang quản trị Cloudflare Worker của bạn:
   👉 **`https://dash.cloudflare.com/`** -> Chọn **Workers & Pages** -> Bấm vào Worker **`dntweaks-key-server`**.
2. Nhìn góc trên bên phải, bấm vào nút **`</> Edit code`** (như trong ảnh bạn đã chụp).
3. Xóa toàn bộ nội dung cũ trong file `worker.js` (hoặc `index.js`).
4. Copy toàn bộ nội dung file [`worker.js`](./worker.js) dán vào.
5. Bấm nút **Deploy** (hoặc **Save and Deploy**).
6. Truy cập ngay đường dẫn quản trị:
   👉 **`https://dntweaks-key-server.ddnstore.workers.dev/admin`**
   - **Tài khoản mặc định**: `admin`
   - **Mật khẩu mặc định**: `AdminPassword@123`

---

## 3. DANH SÁCH ENDPOINTS API

| Endpoint | Method | Chức Năng |
|---|---|---|
| `/health` | `GET` | Kiểm tra tình trạng server |
| `/admin` | `GET` | Giao diện Web Quản trị Admin & Seller Panel |
| `/api/auth/login` | `POST` | Đăng nhập tài khoản Admin hoặc Seller |
| `/api/activate` | `POST` | Kích hoạt bản quyền từ App iOS (Gửi `{ key, hwid }`) |
| `/api/verify` | `POST` | Xác minh bản quyền định kỳ |
| `/api/generate-free-key` | `POST` | Tạo key dùng thử cho trang GetKey |
| `/api/admin/keys` | `GET` | Lấy danh sách keys |
| `/api/admin/keys/create` | `POST` | Tạo key mới (chọn 4 loại tier) |
| `/api/admin/sellers` | `GET` | Lấy danh sách Sellers (Admin only) |
| `/api/admin/sellers/create` | `POST` | Tạo tài khoản Seller mới (Admin only) |
