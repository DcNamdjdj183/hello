/**
 * =========================================================================
 * DNTWEAKS EXTERNAL IOS - KEY SERVER & MULTI-TIER ADMIN PANEL
 * Engine: Cloudflare Workers + D1 Database (dntweaks_keys)
 * Version: 2.0.0 Pro VIP
 * 
 * Features:
 * - 2-tier role authentication: Admin (Master) & Seller
 * - 4 Key Tiers: 'all' (VIP All), 'aimlock', 'sensitive', 'regedit'
 * - Auto-binding to HWID device lock with 1-click device reset
 * - Full-featured Admin & Seller web panel at /admin
 * - High-speed JSON API for iOS App & GetKey web portal
 * =========================================================================
 */

const DEFAULT_ADMIN_USER = "admin";
const DEFAULT_ADMIN_PASS = "AdminPassword@123";

// Helper headers CORS
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-HWID, X-Requested-With",
  "Access-Control-Max-Age": "86400",
};

function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      ...corsHeaders,
    },
  });
}

function jsonError(message, error = "BAD_REQUEST", status = 400) {
  return jsonResponse({ ok: false, success: false, error, message }, status);
}

// Khởi tạo bảng D1 nếu chưa tồn tại
async function ensureDatabase(db) {
  await db.exec(`
    CREATE TABLE IF NOT EXISTS keys (
      key TEXT PRIMARY KEY,
      tier TEXT NOT NULL DEFAULT 'all',
      created_by TEXT NOT NULL DEFAULT 'admin',
      duration_days INTEGER NOT NULL DEFAULT 30,
      device_id TEXT,
      max_devices INTEGER DEFAULT 1,
      status TEXT NOT NULL DEFAULT 'UNUSED',
      note TEXT,
      created_at TEXT NOT NULL,
      activated_at TEXT,
      expires_at TEXT
    );

    CREATE TABLE IF NOT EXISTS sellers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      name TEXT,
      role TEXT NOT NULL DEFAULT 'seller',
      allowed_tiers TEXT NOT NULL DEFAULT 'all,aimlock,sensitive,regedit',
      max_keys INTEGER DEFAULT 0,
      status TEXT NOT NULL DEFAULT 'active',
      created_at TEXT NOT NULL
    );
  `);

  // Tạo tài khoản admin mặc định nếu bảng sellers rỗng
  const adminCheck = await db.prepare("SELECT COUNT(*) as count FROM sellers WHERE role = 'admin'").first();
  if (!adminCheck || adminCheck.count === 0) {
    const now = new Date().toISOString();
    await db.prepare(`
      INSERT INTO sellers (username, password, name, role, allowed_tiers, max_keys, status, created_at)
      VALUES (?, ?, ?, 'admin', 'all,aimlock,sensitive,regedit', 0, 'active', ?)
    `).bind(DEFAULT_ADMIN_USER, DEFAULT_ADMIN_PASS, "Master Admin", now).run();
  }
}

// Sinh chuỗi Key ngẫu nhiên theo tier
function generateKey(tier) {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  function randPart(len = 4) {
    let res = "";
    for (let i = 0; i < len; i++) {
      res += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return res;
  }

  let prefix = "ALL";
  if (tier === "aimlock") prefix = "AIM";
  else if (tier === "sensitive") prefix = "SENS";
  else if (tier === "regedit") prefix = "REG";

  return `DNT-${prefix}-${randPart(4)}-${randPart(4)}`;
}

// Chuyển đổi mã tier sang tên thân thiện
function getTierDisplayName(tier) {
  switch (tier) {
    case "aimlock": return "AIMLOCK VIP (V1 - V5)";
    case "sensitive": return "SENSITIVE VIP (V1 - V5)";
    case "regedit": return "REGEDIT VIP (V1 - V5)";
    default: return "ALL ACCESS VIP (TRỌN BỘ)";
  }
}

// Xác thực Token/Credentials của Admin hoặc Seller
async function authenticateUser(request, db, env) {
  const authHeader = request.headers.get("Authorization") || "";
  if (!authHeader.startsWith("Bearer ")) {
    return null;
  }
  const token = authHeader.substring(7).trim();
  if (!token) return null;

  // Hỗ trợ ADMIN_SECRET trực tiếp từ env
  if (env.ADMIN_SECRET && token === env.ADMIN_SECRET) {
    return { username: "admin", role: "admin", name: "Env Master Admin", allowed_tiers: "all,aimlock,sensitive,regedit" };
  }

  try {
    // Format token: base64(username:password:timestamp)
    const decoded = atob(token);
    const [username, password] = decoded.split(":");
    if (!username || !password) return null;

    const user = await db.prepare("SELECT * FROM sellers WHERE username = ? AND password = ?").bind(username, password).first();
    if (user && user.status === "active") {
      return user;
    }
  } catch (e) {
    // Ignore decode error
  }
  return null;
}

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const pathname = url.pathname;
    const method = request.method;

    // 1. Handle CORS Preflight
    if (method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    // 2. Kiểm tra D1 Binding
    if (!env.DB) {
      return jsonError("Cloudflare D1 Database binding 'DB' is missing! Please bind 'DB' to 'dntweaks_keys'.", "DB_NOT_BOUND", 500);
    }

    // Đảm bảo cấu trúc bảng tồn tại
    try {
      await ensureDatabase(env.DB);
    } catch (e) {
      return jsonError("Database initialization error: " + e.message, "DB_INIT_ERROR", 500);
    }

    // =========================================================================
    // ROUTE: HEALTH CHECK
    // =========================================================================
    if (pathname === "/health" || pathname === "/api/health") {
      return jsonResponse({
        status: "ok",
        service: "DNTWEAKS KEY SERVER",
        version: "2.0.0",
        tiers: ["all", "aimlock", "sensitive", "regedit"],
        time: new Date().toISOString()
      });
    }

    // =========================================================================
    // ROUTE: CLIENT APP - KÍCH HOẠT KEY (/api/activate & /api/verify)
    // =========================================================================
    if (pathname === "/api/activate" || pathname === "/api/verify") {
      if (method !== "POST") return jsonError("Method not allowed", "METHOD_NOT_ALLOWED", 405);

      let body;
      try {
        body = await request.json();
      } catch (e) {
        return jsonError("Invalid JSON body", "INVALID_JSON");
      }

      const keyRaw = (body.key || "").trim().toUpperCase();
      const hwid = (body.hwid || body.device_id || request.headers.get("X-HWID") || "").trim();

      if (!keyRaw) {
        return jsonError("Vui lòng nhập License Key!", "MISSING_KEY");
      }

      // Master Backdoor / Developer Override Key
      if (keyRaw === "OGIOS" || keyRaw === "DNTWEAKS" || keyRaw === "VIP3105" || keyRaw === "EXTERNAL-PRO") {
        const fakeExpiry = new Date(Date.now() + 3650 * 86400 * 1000).toISOString();
        return jsonResponse({
          ok: true,
          success: true,
          key: keyRaw,
          tier: "all",
          tierName: getTierDisplayName("all"),
          durationDays: -1,
          expiresAt: fakeExpiry,
          deviceId: hwid || "DEV-OVERRIDE",
          message: "Kích hoạt quyền Master Developer VIP thành công!"
        });
      }

      const keyRecord = await env.DB.prepare("SELECT * FROM keys WHERE key = ?").bind(keyRaw).first();
      if (!keyRecord) {
        return jsonError("Mã Key không tồn tại trên hệ thống!", "KEY_NOT_FOUND", 404);
      }

      if (keyRecord.status === "BANNED") {
        return jsonError("Key này đã bị vô hiệu hóa (Banned) do vi phạm chính sách!", "KEY_BANNED", 403);
      }

      const now = new Date();

      // Nếu key chưa kích hoạt lần nào (UNUSED)
      if (keyRecord.status === "UNUSED") {
        let expiresAt = null;
        if (keyRecord.duration_days > 0) {
          const expTime = new Date(now.getTime() + keyRecord.duration_days * 86400 * 1000);
          expiresAt = expTime.toISOString();
        } else {
          // Lifetime (-1) -> 10 năm sau
          expiresAt = new Date(now.getTime() + 3650 * 86400 * 1000).toISOString();
        }

        const devId = hwid || "DEVICE-DEFAULT";
        await env.DB.prepare(`
          UPDATE keys 
          SET status = 'ACTIVE', device_id = ?, activated_at = ?, expires_at = ?
          WHERE key = ?
        `).bind(devId, now.toISOString(), expiresAt, keyRaw).run();

        return jsonResponse({
          ok: true,
          success: true,
          key: keyRaw,
          tier: keyRecord.tier,
          tierName: getTierDisplayName(keyRecord.tier),
          durationDays: keyRecord.duration_days,
          expiresAt: expiresAt,
          deviceId: devId,
          message: `Kích hoạt thành công gói ${getTierDisplayName(keyRecord.tier)}!`
        });
      }

      // Nếu key đã được kích hoạt trước đó (ACTIVE)
      if (keyRecord.status === "ACTIVE") {
        // 1. Kiểm tra khóa thiết bị HWID
        if (keyRecord.device_id && hwid && keyRecord.device_id !== hwid) {
          return jsonError(
            `Key đã được liên kết với thiết bị khác (ID: ...${keyRecord.device_id.slice(-6)}). Vui lòng liên hệ Admin/Seller để reset thiết bị!`,
            "DEVICE_MISMATCH",
            403
          );
        }

        // 2. Kiểm tra hạn sử dụng
        if (keyRecord.expires_at) {
          const expDate = new Date(keyRecord.expires_at);
          if (now > expDate) {
            await env.DB.prepare("UPDATE keys SET status = 'EXPIRED' WHERE key = ?").bind(keyRaw).run();
            return jsonError("Key của bạn đã hết hạn sử dụng! Vui lòng gia hạn thêm.", "KEY_EXPIRED", 403);
          }
        }

        return jsonResponse({
          ok: true,
          success: true,
          key: keyRaw,
          tier: keyRecord.tier,
          tierName: getTierDisplayName(keyRecord.tier),
          durationDays: keyRecord.duration_days,
          expiresAt: keyRecord.expires_at,
          deviceId: keyRecord.device_id || hwid,
          message: "Xác minh bản quyền hợp lệ!"
        });
      }

      if (keyRecord.status === "EXPIRED") {
        return jsonError("Key của bạn đã hết hạn sử dụng!", "KEY_EXPIRED", 403);
      }

      return jsonError("Trạng thái key không hợp lệ: " + keyRecord.status, "INVALID_STATUS", 400);
    }

    // =========================================================================
    // ROUTE: TẠO KEY MIỄN PHÍ DÀNH CHO TRANG GETKEY (/api/generate-free-key)
    // =========================================================================
    if (pathname === "/api/generate-free-key") {
      if (method !== "POST") return jsonError("Method not allowed", "METHOD_NOT_ALLOWED", 405);

      let body = {};
      try { body = await request.json(); } catch (e) {}

      // Mặc định key thử nghiệm 2 giờ hoặc 24 giờ, loại tier tuỳ chọn (mặc định 'all' hoặc 'aimlock')
      const tier = body.tier || "all";
      const durationHours = parseInt(body.hours) || 2;
      const durationDays = durationHours / 24.0;
      const newKey = generateKey(tier);
      const now = new Date().toISOString();

      await env.DB.prepare(`
        INSERT INTO keys (key, tier, created_by, duration_days, status, note, created_at)
        VALUES (?, ?, 'getkey_portal', ?, 'UNUSED', ?, ?)
      `).bind(newKey, tier, durationDays, `Free Key GetKey Portal (${durationHours}h)`, now).run();

      return jsonResponse({
        ok: true,
        success: true,
        key: newKey,
        tier: tier,
        tierName: getTierDisplayName(tier),
        durationHours: durationHours,
        message: "Tạo key dùng thử thành công!"
      });
    }

    // =========================================================================
    // ROUTE: ĐĂNG NHẬP ADMIN & SELLER (/api/auth/login)
    // =========================================================================
    if (pathname === "/api/auth/login") {
      if (method !== "POST") return jsonError("Method not allowed", "METHOD_NOT_ALLOWED", 405);

      let body;
      try { body = await request.json(); } catch (e) { return jsonError("Invalid JSON"); }

      const username = (body.username || "").trim();
      const password = (body.password || "").trim();

      if (!username || !password) {
        return jsonError("Vui lòng nhập tên đăng nhập và mật khẩu!");
      }

      // Check database
      const user = await env.DB.prepare("SELECT * FROM sellers WHERE username = ? AND password = ?").bind(username, password).first();
      if (!user) {
        return jsonError("Tài khoản hoặc mật khẩu không chính xác!", "AUTH_FAILED", 401);
      }

      if (user.status !== "active") {
        return jsonError("Tài khoản của bạn đã bị khóa! Liên hệ Admin chính.", "ACCOUNT_BLOCKED", 403);
      }

      const token = btoa(`${user.username}:${user.password}:${Date.now()}`);
      return jsonResponse({
        ok: true,
        success: true,
        token: token,
        user: {
          username: user.username,
          name: user.name || user.username,
          role: user.role,
          allowedTiers: user.allowed_tiers.split(","),
          maxKeys: user.max_keys
        }
      });
    }

    // =========================================================================
    // ROUTES: ADMIN & SELLER MANAGEMENT (Yêu cầu Authentication)
    // =========================================================================
    if (pathname.startsWith("/api/admin")) {
      const authUser = await authenticateUser(request, env.DB, env);
      if (!authUser) {
        return jsonError("Phiên làm việc hết hạn hoặc Authorization không hợp lệ!", "UNAUTHORIZED", 401);
      }

      const isAdmin = authUser.role === "admin";

      // -----------------------------------------------------------------------
      // 1. Thống kê Dashboard (/api/admin/stats)
      // -----------------------------------------------------------------------
      if (pathname === "/api/admin/stats" && method === "GET") {
        let keyStats;
        if (isAdmin) {
          keyStats = await env.DB.prepare(`
            SELECT 
              COUNT(*) as total,
              SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) as active,
              SUM(CASE WHEN status = 'UNUSED' THEN 1 ELSE 0 END) as unused,
              SUM(CASE WHEN status = 'BANNED' THEN 1 ELSE 0 END) as banned,
              SUM(CASE WHEN status = 'EXPIRED' THEN 1 ELSE 0 END) as expired
            FROM keys
          `).first();
        } else {
          keyStats = await env.DB.prepare(`
            SELECT 
              COUNT(*) as total,
              SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) as active,
              SUM(CASE WHEN status = 'UNUSED' THEN 1 ELSE 0 END) as unused,
              SUM(CASE WHEN status = 'BANNED' THEN 1 ELSE 0 END) as banned,
              SUM(CASE WHEN status = 'EXPIRED' THEN 1 ELSE 0 END) as expired
            FROM keys WHERE created_by = ?
          `).bind(authUser.username).first();
        }

        const sellerCount = isAdmin ? (await env.DB.prepare("SELECT COUNT(*) as count FROM sellers WHERE role = 'seller'").first())?.count || 0 : 0;

        return jsonResponse({
          ok: true,
          success: true,
          stats: {
            totalKeys: keyStats?.total || 0,
            activeKeys: keyStats?.active || 0,
            unusedKeys: keyStats?.unused || 0,
            bannedKeys: keyStats?.banned || 0,
            expiredKeys: keyStats?.expired || 0,
            totalSellers: sellerCount
          }
        });
      }

      // -----------------------------------------------------------------------
      // 2. Lấy danh sách Keys (/api/admin/keys)
      // -----------------------------------------------------------------------
      if (pathname === "/api/admin/keys" && method === "GET") {
        const search = url.searchParams.get("search") || "";
        const tier = url.searchParams.get("tier") || "";
        const status = url.searchParams.get("status") || "";
        const sellerFilter = url.searchParams.get("seller") || "";

        let sql = "SELECT * FROM keys WHERE 1=1";
        const params = [];

        // Nếu là Seller thường, chỉ lấy key do seller đó tạo
        if (!isAdmin) {
          sql += " AND created_by = ?";
          params.push(authUser.username);
        } else if (sellerFilter) {
          sql += " AND created_by = ?";
          params.push(sellerFilter);
        }

        if (search) {
          sql += " AND (key LIKE ? OR note LIKE ? OR device_id LIKE ?)";
          const s = `%${search}%`;
          params.push(s, s, s);
        }

        if (tier) {
          sql += " AND tier = ?";
          params.push(tier);
        }

        if (status) {
          sql += " AND status = ?";
          params.push(status);
        }

        sql += " ORDER BY created_at DESC LIMIT 500";

        const { results } = await env.DB.prepare(sql).bind(...params).all();
        return jsonResponse({ ok: true, success: true, keys: results });
      }

      // -----------------------------------------------------------------------
      // 3. Tạo Key Mới (/api/admin/keys/create)
      // -----------------------------------------------------------------------
      if (pathname === "/api/admin/keys/create" && method === "POST") {
        let body;
        try { body = await request.json(); } catch (e) { return jsonError("Invalid JSON"); }

        const tier = body.tier || "all";
        const duration_days = parseInt(body.duration_days) ?? 30;
        const max_devices = parseInt(body.max_devices) || 1;
        const note = (body.note || "").trim();
        const quantity = Math.min(Math.max(parseInt(body.quantity) || 1, 1), 100);

        // Kiểm tra quyền tạo tier đối với Seller
        if (!isAdmin) {
          const allowed = (authUser.allowed_tiers || "").split(",").map(t => t.trim());
          if (!allowed.includes(tier) && !allowed.includes("all")) {
            return jsonError(`Bạn không có quyền tạo loại key: ${tier}! Hãy liên hệ Admin.`);
          }

          // Kiểm tra hạn mức tạo key của seller
          if (authUser.max_keys > 0) {
            const count = (await env.DB.prepare("SELECT COUNT(*) as c FROM keys WHERE created_by = ?").bind(authUser.username).first())?.c || 0;
            if (count + quantity > authUser.max_keys) {
              return jsonError(`Bạn đã vượt quá giới hạn tối đa ${authUser.max_keys} key được phép tạo!`);
            }
          }
        }

        const createdKeys = [];
        const now = new Date().toISOString();

        for (let i = 0; i < quantity; i++) {
          const keyStr = generateKey(tier);
          await env.DB.prepare(`
            INSERT INTO keys (key, tier, created_by, duration_days, max_devices, status, note, created_at)
            VALUES (?, ?, ?, ?, ?, 'UNUSED', ?, ?)
          `).bind(keyStr, tier, authUser.username, duration_days, max_devices, note, now).run();

          createdKeys.push(keyStr);
        }

        return jsonResponse({
          ok: true,
          success: true,
          key: createdKeys[0],
          keys: createdKeys,
          count: createdKeys.length,
          tier,
          tierName: getTierDisplayName(tier),
          message: `Đã tạo thành công ${createdKeys.length} key (${getTierDisplayName(tier)})!`
        });
      }

      // -----------------------------------------------------------------------
      // 4. Các thao tác trên 1 Key: Ban / Unban / Reset Device / Delete
      // -----------------------------------------------------------------------
      const keyActionMatch = pathname.match(/^\/api\/admin\/keys\/([^\/]+)(?:\/(ban|unban|reset-device))?$/);
      if (keyActionMatch) {
        const targetKey = decodeURIComponent(keyActionMatch[1]);
        const subAction = keyActionMatch[2];

        // Lấy thông tin key để kiểm tra quyền
        const keyItem = await env.DB.prepare("SELECT * FROM keys WHERE key = ?").bind(targetKey).first();
        if (!keyItem) return jsonError("Key không tồn tại!", "NOT_FOUND", 404);

        if (!isAdmin && keyItem.created_by !== authUser.username) {
          return jsonError("Bạn không có quyền thao tác trên key của người khác!", "FORBIDDEN", 403);
        }

        // Xóa Key (DELETE)
        if (method === "DELETE") {
          await env.DB.prepare("DELETE FROM keys WHERE key = ?").bind(targetKey).run();
          return jsonResponse({ ok: true, success: true, message: "Đã xóa vĩnh viễn key: " + targetKey });
        }

        // Ban Key
        if (subAction === "ban" && method === "POST") {
          await env.DB.prepare("UPDATE keys SET status = 'BANNED' WHERE key = ?").bind(targetKey).run();
          return jsonResponse({ ok: true, success: true, message: "Đã khóa (Ban) key: " + targetKey });
        }

        // Unban Key
        if (subAction === "unban" && method === "POST") {
          const revertStatus = keyItem.activated_at ? "ACTIVE" : "UNUSED";
          await env.DB.prepare("UPDATE keys SET status = ? WHERE key = ?").bind(revertStatus, targetKey).run();
          return jsonResponse({ ok: true, success: true, message: "Đã mở khóa (Unban) key: " + targetKey });
        }

        // Reset Device ID
        if (subAction === "reset-device" && method === "POST") {
          await env.DB.prepare("UPDATE keys SET device_id = NULL WHERE key = ?").bind(targetKey).run();
          return jsonResponse({ ok: true, success: true, message: "Đã xóa liên kết thiết bị cho key: " + targetKey });
        }
      }

      // -----------------------------------------------------------------------
      // 5. QUẢN LÝ SELLERS (Dành riêng cho Admin Chính)
      // -----------------------------------------------------------------------
      if (pathname === "/api/admin/sellers" && method === "GET") {
        if (!isAdmin) return jsonError("Chỉ có Admin mới có quyền truy cập!", "FORBIDDEN", 403);

        const { results } = await env.DB.prepare(`
          SELECT 
            s.id, s.username, s.name, s.role, s.allowed_tiers, s.max_keys, s.status, s.created_at,
            (SELECT COUNT(*) FROM keys WHERE created_by = s.username) as total_keys_created
          FROM sellers s
          ORDER BY s.role DESC, s.created_at DESC
        `).all();

        return jsonResponse({ ok: true, success: true, sellers: results });
      }

      // Tạo Seller mới
      if (pathname === "/api/admin/sellers/create" && method === "POST") {
        if (!isAdmin) return jsonError("Chỉ Admin mới có quyền tạo Seller!", "FORBIDDEN", 403);

        let body;
        try { body = await request.json(); } catch (e) { return jsonError("Invalid JSON"); }

        const username = (body.username || "").trim().toLowerCase();
        const password = (body.password || "").trim();
        const name = (body.name || "").trim() || username;
        const allowed_tiers = body.allowed_tiers || "all,aimlock,sensitive,regedit";
        const max_keys = parseInt(body.max_keys) || 0;
        const role = body.role === "admin" ? "admin" : "seller";

        if (!username || !password) {
          return jsonError("Tên đăng nhập và mật khẩu seller là bắt buộc!");
        }

        const existing = await env.DB.prepare("SELECT id FROM sellers WHERE username = ?").bind(username).first();
        if (existing) {
          return jsonError("Tên đăng nhập này đã tồn tại! Vui lòng chọn tên khác.");
        }

        const now = new Date().toISOString();
        await env.DB.prepare(`
          INSERT INTO sellers (username, password, name, role, allowed_tiers, max_keys, status, created_at)
          VALUES (?, ?, ?, ?, ?, ?, 'active', ?)
        `).bind(username, password, name, role, allowed_tiers, max_keys, now).run();

        return jsonResponse({ ok: true, success: true, message: `Tạo tài khoản ${role.toUpperCase()} '${username}' thành công!` });
      }

      // Khóa / Mở khóa / Đổi mật khẩu / Xóa Seller
      const sellerActionMatch = pathname.match(/^\/api\/admin\/sellers\/([^\/]+)(?:\/(toggle-status|change-password))?$/);
      if (sellerActionMatch) {
        if (!isAdmin) return jsonError("Chỉ Admin mới có quyền quản lý Sellers!", "FORBIDDEN", 403);

        const targetUser = decodeURIComponent(sellerActionMatch[1]).toLowerCase();
        const subAction = sellerActionMatch[2];

        if (targetUser === "admin" && subAction !== "change-password") {
          return jsonError("Không thể thay đổi trạng thái hoặc xóa tài khoản Master Admin!");
        }

        if (method === "DELETE") {
          await env.DB.prepare("DELETE FROM sellers WHERE username = ?").bind(targetUser).run();
          return jsonResponse({ ok: true, success: true, message: `Đã xóa tài khoản seller: ${targetUser}` });
        }

        if (subAction === "toggle-status" && method === "POST") {
          const curr = await env.DB.prepare("SELECT status FROM sellers WHERE username = ?").bind(targetUser).first();
          if (!curr) return jsonError("Không tìm thấy seller này!");
          const newStatus = curr.status === "active" ? "blocked" : "active";
          await env.DB.prepare("UPDATE sellers SET status = ? WHERE username = ?").bind(newStatus, targetUser).run();
          return jsonResponse({ ok: true, success: true, message: `Đã đổi trạng thái seller thành '${newStatus}'!` });
        }

        if (subAction === "change-password" && method === "POST") {
          let body;
          try { body = await request.json(); } catch (e) { return jsonError("Invalid JSON"); }
          const newPass = (body.password || "").trim();
          if (!newPass) return jsonError("Mật khẩu mới không được để trống!");
          await env.DB.prepare("UPDATE sellers SET password = ? WHERE username = ?").bind(newPass, targetUser).run();
          return jsonResponse({ ok: true, success: true, message: `Đã cập nhật mật khẩu cho '${targetUser}' thành công!` });
        }
      }

      return jsonError("Admin Endpoint Not Found", "NOT_FOUND", 404);
    }

    // =========================================================================
    // ROUTE: GIAO DIỆN WEB ADMIN & SELLER PANEL (/admin)
    // =========================================================================
    if (pathname === "/admin" || pathname === "/admin/") {
      return new Response(getAdminPanelHTML(), {
        headers: { "Content-Type": "text/html; charset=utf-8" },
      });
    }

    return jsonError("Endpoint not found", "NOT_FOUND", 404);
  }
};

/**
 * =========================================================================
 * GIAO DIỆN HTML/CSS/JS CỦA ADMIN & SELLER PANEL (/admin)
 * =========================================================================
 */
function getAdminPanelHTML() {
  return `<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>DNTWEAKS KEY SERVER - Admin & Seller Panel</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    :root {
      --bg: #060911;
      --card: rgba(13, 20, 36, 0.85);
      --border: rgba(56, 189, 248, 0.2);
      --primary: #00e5ff;
    }
    body {
      background-color: var(--bg);
      color: #f1f5f9;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      min-height: 100vh;
    }
    .glass-card {
      background: var(--card);
      border: 1px solid var(--border);
      backdrop-filter: blur(16px);
      border-radius: 20px;
    }
    .badge-all { background: rgba(0, 229, 255, 0.15); color: #00e5ff; border: 1px solid rgba(0, 229, 255, 0.3); }
    .badge-aimlock { background: rgba(6, 182, 212, 0.15); color: #22d3ee; border: 1px solid rgba(6, 182, 212, 0.3); }
    .badge-sensitive { background: rgba(249, 115, 22, 0.15); color: #fb923c; border: 1px solid rgba(249, 115, 22, 0.3); }
    .badge-regedit { background: rgba(234, 179, 8, 0.15); color: #fde047; border: 1px solid rgba(234, 179, 8, 0.3); }
  </style>
</head>
<body class="p-3 md:p-6 antialiased">

  <!-- OVERLAY ĐĂNG NHẬP -->
  <div id="login-modal" class="fixed inset-0 z-50 bg-black/85 backdrop-blur-md flex items-center justify-center p-4">
    <div class="w-full max-w-md glass-card p-6 md:p-8 shadow-2xl border border-cyan-500/30">
      <div class="text-center mb-6">
        <div class="w-14 h-14 rounded-2xl bg-gradient-to-tr from-cyan-500 to-blue-600 flex items-center justify-center text-white text-2xl font-black mx-auto mb-3 shadow-lg shadow-cyan-500/30">
          <i class="fas fa-shield-alt"></i>
        </div>
        <h2 class="text-2xl font-black tracking-wide text-white">DNTWEAKS KEY SERVER</h2>
        <p class="text-xs text-gray-400 mt-1">Cổng Quản Trị Hệ Thống (Admin & Seller)</p>
      </div>

      <div class="space-y-4">
        <div>
          <label class="block text-xs font-bold text-gray-300 mb-1">TÊN ĐĂNG NHẬP</label>
          <input type="text" id="login-username" placeholder="admin hoặc tên seller..." class="w-full px-4 py-3 rounded-xl bg-white/5 border border-white/10 text-white placeholder-gray-500 text-sm focus:border-cyan-400 focus:outline-none">
        </div>
        <div>
          <label class="block text-xs font-bold text-gray-300 mb-1">MẬT KHẨU</label>
          <input type="password" id="login-password" placeholder="Nhập mật khẩu..." class="w-full px-4 py-3 rounded-xl bg-white/5 border border-white/10 text-white placeholder-gray-500 text-sm focus:border-cyan-400 focus:outline-none" onkeyup="if(event.key==='Enter') handleLogin()">
        </div>
        <button onclick="handleLogin()" id="btn-login-submit" class="w-full py-3.5 rounded-xl bg-gradient-to-r from-cyan-400 to-blue-500 text-black font-black text-sm tracking-wider shadow-lg shadow-cyan-500/25 hover:opacity-95 active:scale-95 transition-all">
          ĐĂNG NHẬP HỆ THỐNG
        </button>
      </div>

      <div class="mt-6 pt-4 border-t border-white/10 text-center">
        <p class="text-[11px] text-gray-400">Tài khoản Admin mặc định: <b class="text-white">admin</b> / <b class="text-white">AdminPassword@123</b></p>
      </div>
    </div>
  </div>

  <!-- MAIN DASHBOARD -->
  <div id="main-panel" class="max-w-7xl mx-auto space-y-6 hidden">
    
    <!-- Top Bar Header -->
    <header class="glass-card p-4 md:p-5 flex flex-wrap items-center justify-between gap-4 border-b border-cyan-500/30">
      <div class="flex items-center space-x-3">
        <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-cyan-500 to-blue-600 flex items-center justify-center font-black text-white text-lg">
          DN
        </div>
        <div>
          <div class="flex items-center space-x-2">
            <h1 class="text-lg font-black text-white tracking-wide">DNTWEAKS EXTERNAL IOS</h1>
            <span id="role-badge" class="text-[10px] font-extrabold px-2 py-0.5 rounded bg-cyan-500/20 text-cyan-400 border border-cyan-500/30">ADMIN</span>
          </div>
          <p class="text-xs text-gray-400">Đang đăng nhập: <span id="current-user-name" class="font-bold text-white">...</span></p>
        </div>
      </div>

      <div class="flex items-center space-x-2">
        <button onclick="switchTab('keys')" id="nav-btn-keys" class="px-4 py-2 rounded-xl text-xs font-bold bg-cyan-400 text-black transition-all">
          <i class="fas fa-key mr-1"></i> Quản Lý Keys
        </button>
        <button onclick="switchTab('sellers')" id="nav-btn-sellers" class="px-4 py-2 rounded-xl text-xs font-bold bg-white/5 text-gray-300 hover:text-white transition-all hidden">
          <i class="fas fa-users-cog mr-1"></i> Quản Lý Sellers
        </button>
        <button onclick="handleLogout()" class="px-3.5 py-2 rounded-xl text-xs font-bold bg-red-500/20 text-red-400 border border-red-500/30 hover:bg-red-500/30 transition-all">
          <i class="fas fa-sign-out-alt"></i> Đăng Xuất
        </button>
      </div>
    </header>

    <!-- Thống kê HUD -->
    <div class="grid grid-cols-2 md:grid-cols-5 gap-3 md:gap-4">
      <div class="glass-card p-4 border border-cyan-500/20">
        <span class="text-[10px] font-bold text-gray-400 uppercase">TỔNG KEYS</span>
        <h3 id="stat-total" class="text-2xl font-black text-white mt-1">0</h3>
      </div>
      <div class="glass-card p-4 border border-emerald-500/20">
        <span class="text-[10px] font-bold text-gray-400 uppercase">ĐANG SỬ DỤNG</span>
        <h3 id="stat-active" class="text-2xl font-black text-emerald-400 mt-1">0</h3>
      </div>
      <div class="glass-card p-4 border border-blue-500/20">
        <span class="text-[10px] font-bold text-gray-400 uppercase">CHƯA SỬ DỤNG</span>
        <h3 id="stat-unused" class="text-2xl font-black text-blue-400 mt-1">0</h3>
      </div>
      <div class="glass-card p-4 border border-amber-500/20">
        <span class="text-[10px] font-bold text-gray-400 uppercase">ĐÃ HẾT HẠN</span>
        <h3 id="stat-expired" class="text-2xl font-black text-amber-400 mt-1">0</h3>
      </div>
      <div class="glass-card p-4 border border-red-500/20">
        <span class="text-[10px] font-bold text-gray-400 uppercase">ĐÃ KHÓA (BANNED)</span>
        <h3 id="stat-banned" class="text-2xl font-black text-red-400 mt-1">0</h3>
      </div>
    </div>

    <!-- TAB 1: QUẢN LÝ KEYS -->
    <div id="tab-keys" class="space-y-6">
      
      <!-- Hộp tạo Key mới -->
      <div class="glass-card p-5 md:p-6">
        <h3 class="text-base font-black text-white mb-4 flex items-center space-x-2">
          <i class="fas fa-plus-circle text-cyan-400"></i>
          <span>TẠO LICENSE KEY MỚI</span>
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-5 gap-3.5">
          <div>
            <label class="block text-[11px] font-bold text-gray-400 mb-1">LOẠI KEY (4 PHÂN HỆ)</label>
            <select id="create-tier" class="w-full px-3 py-2.5 rounded-xl bg-[#0a101d] border border-white/10 text-white text-xs font-bold focus:border-cyan-400 focus:outline-none">
              <option value="all">💎 VIP TOÀN BỘ (All Features)</option>
              <option value="aimlock">🎯 AIMLOCK ONLY (V1 - V5)</option>
              <option value="sensitive">⚡ SENSITIVE ONLY (V1 - V5)</option>
              <option value="regedit">⚙️ REGEDIT ONLY (V1 - V5)</option>
            </select>
          </div>

          <div>
            <label class="block text-[11px] font-bold text-gray-400 mb-1">THỜI HẠN</label>
            <select id="create-duration" class="w-full px-3 py-2.5 rounded-xl bg-[#0a101d] border border-white/10 text-white text-xs font-bold focus:border-cyan-400 focus:outline-none">
              <option value="1">1 Ngày (24 Giờ)</option>
              <option value="3">3 Ngày</option>
              <option value="7">7 Ngày (1 Tuần)</option>
              <option value="30" selected>30 Ngày (1 Tháng)</option>
              <option value="90">90 Ngày (3 Tháng)</option>
              <option value="365">365 Ngày (1 Năm)</option>
              <option value="-1">🔥 VĨNH VIỄN (Lifetime)</option>
            </select>
          </div>

          <div>
            <label class="block text-[11px] font-bold text-gray-400 mb-1">SỐ LƯỢNG KEY</label>
            <input type="number" id="create-quantity" value="1" min="1" max="100" class="w-full px-3 py-2.5 rounded-xl bg-[#0a101d] border border-white/10 text-white text-xs font-bold focus:border-cyan-400 focus:outline-none">
          </div>

          <div>
            <label class="block text-[11px] font-bold text-gray-400 mb-1">GHI CHÚ (TÊN KHÁCH)</label>
            <input type="text" id="create-note" placeholder="VD: Khách Zalo DucNam..." class="w-full px-3 py-2.5 rounded-xl bg-[#0a101d] border border-white/10 text-white text-xs focus:border-cyan-400 focus:outline-none">
          </div>

          <div class="flex items-end">
            <button onclick="handleCreateKey()" class="w-full py-2.5 rounded-xl bg-gradient-to-r from-cyan-400 to-blue-500 text-black font-black text-xs uppercase shadow-md shadow-cyan-500/20 hover:opacity-90 active:scale-95 transition-all">
              ⚡ TẠO KEY NGAY
            </button>
          </div>
        </div>
      </div>

      <!-- Danh Sách Keys -->
      <div class="glass-card p-5 md:p-6">
        <div class="flex flex-wrap items-center justify-between gap-3 mb-4">
          <div class="flex items-center space-x-2">
            <h3 class="text-base font-black text-white">DANH SÁCH KEYS</h3>
            <span id="keys-count-badge" class="text-xs px-2 py-0.5 rounded-full bg-white/10 text-gray-300">0 key</span>
          </div>

          <div class="flex flex-wrap items-center gap-2">
            <input type="text" id="search-input" placeholder="Tìm theo Key, HWID, Ghi chú..." class="px-3.5 py-2 rounded-xl bg-[#0a101d] border border-white/10 text-xs text-white placeholder-gray-500 focus:border-cyan-400 focus:outline-none w-60" onkeyup="if(event.key==='Enter') loadKeys()">
            <select id="filter-tier" onchange="loadKeys()" class="px-3 py-2 rounded-xl bg-[#0a101d] border border-white/10 text-xs text-white">
              <option value="">Tất cả loại tier</option>
              <option value="all">VIP ALL</option>
              <option value="aimlock">AIMLOCK</option>
              <option value="sensitive">SENSITIVE</option>
              <option value="regedit">REGEDIT</option>
            </select>
            <select id="filter-status" onchange="loadKeys()" class="px-3 py-2 rounded-xl bg-[#0a101d] border border-white/10 text-xs text-white">
              <option value="">Tất cả trạng thái</option>
              <option value="ACTIVE">ACTIVE (Đang dùng)</option>
              <option value="UNUSED">UNUSED (Chưa dùng)</option>
              <option value="EXPIRED">EXPIRED (Hết hạn)</option>
              <option value="BANNED">BANNED (Bị khóa)</option>
            </select>
            <button onclick="loadKeys()" class="px-3.5 py-2 rounded-xl bg-white/10 text-xs font-bold text-gray-200 hover:bg-white/20">
              <i class="fas fa-sync-alt"></i>
            </button>
          </div>
        </div>

        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs text-gray-300">
            <thead class="text-[11px] uppercase bg-white/[0.03] text-gray-400 border-b border-white/10">
              <tr>
                <th class="py-3 px-3">Mã Key</th>
                <th class="py-3 px-3">Phân Hệ</th>
                <th class="py-3 px-3">Người Tạo</th>
                <th class="py-3 px-3">Trạng Thái</th>
                <th class="py-3 px-3">Hạn Dùng</th>
                <th class="py-3 px-3">HWID Thiết Bị</th>
                <th class="py-3 px-3">Ghi Chú</th>
                <th class="py-3 px-3 text-right">Thao Tác</th>
              </tr>
            </thead>
            <tbody id="keys-tbody" class="divide-y divide-white/5 font-mono">
              <!-- Load dynamic data -->
            </tbody>
          </table>
        </div>
      </div>

    </div>

    <!-- TAB 2: QUẢN LÝ SELLERS (ADMIN ONLY) -->
    <div id="tab-sellers" class="space-y-6 hidden">
      
      <!-- Hộp tạo Seller mới -->
      <div class="glass-card p-5 md:p-6">
        <h3 class="text-base font-black text-white mb-4 flex items-center space-x-2">
          <i class="fas fa-user-plus text-cyan-400"></i>
          <span>TẠO TÀI KHOẢN SELLER MỚI</span>
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-4 gap-3.5">
          <div>
            <label class="block text-[11px] font-bold text-gray-400 mb-1">TÊN ĐĂNG NHẬP</label>
            <input type="text" id="seller-username" placeholder="seller_ducnam..." class="w-full px-3 py-2.5 rounded-xl bg-[#0a101d] border border-white/10 text-white text-xs focus:border-cyan-400 focus:outline-none">
          </div>
          <div>
            <label class="block text-[11px] font-bold text-gray-400 mb-1">MẬT KHẨU</label>
            <input type="text" id="seller-password" placeholder="Mật khẩu seller..." class="w-full px-3 py-2.5 rounded-xl bg-[#0a101d] border border-white/10 text-white text-xs focus:border-cyan-400 focus:outline-none">
          </div>
          <div>
            <label class="block text-[11px] font-bold text-gray-400 mb-1">TÊN HIỂN THỊ</label>
            <input type="text" id="seller-name" placeholder="Đại Lý Miền Bắc..." class="w-full px-3 py-2.5 rounded-xl bg-[#0a101d] border border-white/10 text-white text-xs focus:border-cyan-400 focus:outline-none">
          </div>
          <div>
            <label class="block text-[11px] font-bold text-gray-400 mb-1">QUYỀN TẠO KEY</label>
            <select id="seller-allowed-tiers" class="w-full px-3 py-2.5 rounded-xl bg-[#0a101d] border border-white/10 text-white text-xs font-bold focus:border-cyan-400 focus:outline-none">
              <option value="all,aimlock,sensitive,regedit">Tất cả 4 loại (All, Aim, Sens, Reg)</option>
              <option value="aimlock">Chỉ được tạo Aimlock</option>
              <option value="sensitive">Chỉ được tạo Sensitive</option>
              <option value="regedit">Chỉ được tạo Regedit</option>
              <option value="aimlock,sensitive,regedit">3 Phân hệ lẻ (Không tạo được ALL)</option>
            </select>
          </div>
        </div>

        <div class="mt-4 flex justify-end">
          <button onclick="handleCreateSeller()" class="px-6 py-2.5 rounded-xl bg-gradient-to-r from-emerald-400 to-cyan-500 text-black font-black text-xs uppercase shadow-md shadow-emerald-500/20 hover:opacity-90 active:scale-95 transition-all">
            + THÊM TÀI KHOẢN SELLER
          </button>
        </div>
      </div>

      <!-- Danh sách Sellers -->
      <div class="glass-card p-5 md:p-6">
        <h3 class="text-base font-black text-white mb-4">DANH SÁCH TÀI KHOẢN SELLER & ADMIN</h3>

        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs text-gray-300">
            <thead class="text-[11px] uppercase bg-white/[0.03] text-gray-400 border-b border-white/10">
              <tr>
                <th class="py-3 px-3">Tài Khoản</th>
                <th class="py-3 px-3">Tên Hiển Thị</th>
                <th class="py-3 px-3">Cấp Bậc (Role)</th>
                <th class="py-3 px-3">Quyền Loại Key</th>
                <th class="py-3 px-3">Tổng Key Đã Tạo</th>
                <th class="py-3 px-3">Trạng Thái</th>
                <th class="py-3 px-3 text-right">Thao Tác</th>
              </tr>
            </thead>
            <tbody id="sellers-tbody" class="divide-y divide-white/5 font-mono">
              <!-- Load dynamic seller data -->
            </tbody>
          </table>
        </div>
      </div>

    </div>

  </div>

  <script>
    let authToken = localStorage.getItem('dntweaks_token') || '';
    let currentUser = null;

    // Khởi động
    window.addEventListener('DOMContentLoaded', () => {
      if (authToken) {
        checkSession();
      }
    });

    async function apiRequest(endpoint, method = 'GET', body = null) {
      const options = {
        method,
        headers: {
          'Authorization': 'Bearer ' + authToken,
          'Content-Type': 'application/json'
        }
      };
      if (body) options.body = JSON.stringify(body);

      try {
        const res = await fetch('/api' + endpoint, options);
        if (res.status === 401) {
          handleLogout();
          return null;
        }
        return await res.json();
      } catch (e) {
        alert('Lỗi kết nối máy chủ API: ' + e.message);
        return null;
      }
    }

    async function handleLogin() {
      const u = document.getElementById('login-username').value.trim();
      const p = document.getElementById('login-password').value.trim();
      if (!u || !p) return alert('Vui lòng nhập tài khoản và mật khẩu!');

      const btn = document.getElementById('btn-login-submit');
      btn.innerText = 'ĐANG ĐĂNG NHẬP...';
      btn.disabled = true;

      try {
        const res = await fetch('/api/auth/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ username: u, password: p })
        });
        const data = await res.json();

        if (data.ok && data.token) {
          authToken = data.token;
          currentUser = data.user;
          localStorage.setItem('dntweaks_token', authToken);
          localStorage.setItem('dntweaks_user', JSON.stringify(currentUser));

          setupUIForUser();
        } else {
          alert('Đăng nhập thất bại: ' + (data.message || 'Sai mật khẩu!'));
        }
      } catch (e) {
        alert('Lỗi: ' + e.message);
      } finally {
        btn.innerText = 'ĐĂNG NHẬP HỆ THỐNG';
        btn.disabled = false;
      }
    }

    function handleLogout() {
      authToken = '';
      currentUser = null;
      localStorage.removeItem('dntweaks_token');
      localStorage.removeItem('dntweaks_user');
      document.getElementById('login-modal').classList.remove('hidden');
      document.getElementById('main-panel').classList.add('hidden');
    }

    function checkSession() {
      try {
        currentUser = JSON.parse(localStorage.getItem('dntweaks_user'));
      } catch(e){}
      setupUIForUser();
    }

    function setupUIForUser() {
      document.getElementById('login-modal').classList.add('hidden');
      document.getElementById('main-panel').classList.remove('hidden');

      const isAdm = currentUser && currentUser.role === 'admin';
      document.getElementById('current-user-name').innerText = currentUser ? (currentUser.name || currentUser.username) : 'Admin';
      document.getElementById('role-badge').innerText = isAdm ? 'MASTER ADMIN' : 'SELLER PRO';
      document.getElementById('role-badge').className = isAdm 
        ? 'text-[10px] font-extrabold px-2 py-0.5 rounded bg-cyan-500/20 text-cyan-400 border border-cyan-500/30'
        : 'text-[10px] font-extrabold px-2 py-0.5 rounded bg-amber-500/20 text-amber-400 border border-amber-500/30';

      const sellerBtn = document.getElementById('nav-btn-sellers');
      if (isAdm) {
        sellerBtn.classList.remove('hidden');
      } else {
        sellerBtn.classList.add('hidden');
      }

      loadStats();
      loadKeys();
    }

    function switchTab(tab) {
      const keysTab = document.getElementById('tab-keys');
      const sellersTab = document.getElementById('tab-sellers');
      const keysBtn = document.getElementById('nav-btn-keys');
      const sellersBtn = document.getElementById('nav-btn-sellers');

      if (tab === 'keys') {
        keysTab.classList.remove('hidden');
        sellersTab.classList.add('hidden');
        keysBtn.className = 'px-4 py-2 rounded-xl text-xs font-bold bg-cyan-400 text-black transition-all';
        sellersBtn.className = 'px-4 py-2 rounded-xl text-xs font-bold bg-white/5 text-gray-300 hover:text-white transition-all';
        loadKeys();
      } else {
        keysTab.classList.add('hidden');
        sellersTab.classList.remove('hidden');
        sellersBtn.className = 'px-4 py-2 rounded-xl text-xs font-bold bg-cyan-400 text-black transition-all';
        keysBtn.className = 'px-4 py-2 rounded-xl text-xs font-bold bg-white/5 text-gray-300 hover:text-white transition-all';
        loadSellers();
      }
    }

    async function loadStats() {
      const data = await apiRequest('/admin/stats');
      if (data && data.stats) {
        document.getElementById('stat-total').innerText = data.stats.totalKeys;
        document.getElementById('stat-active').innerText = data.stats.activeKeys;
        document.getElementById('stat-unused').innerText = data.stats.unusedKeys;
        document.getElementById('stat-expired').innerText = data.stats.expiredKeys;
        document.getElementById('stat-banned').innerText = data.stats.bannedKeys;
      }
    }

    async function loadKeys() {
      const search = document.getElementById('search-input').value.trim();
      const tier = document.getElementById('filter-tier').value;
      const status = document.getElementById('filter-status').value;

      let url = '/admin/keys?';
      if (search) url += 'search=' + encodeURIComponent(search) + '&';
      if (tier) url += 'tier=' + tier + '&';
      if (status) url += 'status=' + status + '&';

      const data = await apiRequest(url);
      if (!data || !data.keys) return;

      document.getElementById('keys-count-badge').innerText = data.keys.length + ' key';
      const tbody = document.getElementById('keys-tbody');
      tbody.innerHTML = '';

      if (data.keys.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="text-center py-8 text-gray-500">Chưa có mã key nào phù hợp.</td></tr>';
        return;
      }

      data.keys.forEach(k => {
        let tierBadge = 'badge-all';
        let tierLabel = 'VIP ALL';
        if (k.tier === 'aimlock') { tierBadge = 'badge-aimlock'; tierLabel = 'AIMLOCK'; }
        else if (k.tier === 'sensitive') { tierBadge = 'badge-sensitive'; tierLabel = 'SENSITIVE'; }
        else if (k.tier === 'regedit') { tierBadge = 'badge-regedit'; tierLabel = 'REGEDIT'; }

        let statusClass = 'text-blue-400 bg-blue-500/10 border-blue-500/20';
        if (k.status === 'ACTIVE') statusClass = 'text-emerald-400 bg-emerald-500/10 border-emerald-500/20';
        else if (k.status === 'BANNED') statusClass = 'text-red-400 bg-red-500/10 border-red-500/20';
        else if (k.status === 'EXPIRED') statusClass = 'text-gray-400 bg-white/5 border-white/10';

        const durText = k.duration_days === -1 ? 'Vĩnh viễn' : (k.duration_days + ' ngày');
        const devText = k.device_id ? ('...' + k.device_id.slice(-8)) : '<span class="text-gray-500">Chưa gắn</span>';

        const tr = document.createElement('tr');
        tr.className = 'hover:bg-white/[0.02] transition-colors';
        tr.innerHTML = \`
          <td class="py-3 px-3 font-bold text-white select-all">\${k.key}</td>
          <td class="py-3 px-3"><span class="px-2 py-0.5 rounded text-[10px] font-black \${tierBadge}">\${tierLabel}</span></td>
          <td class="py-3 px-3 text-cyan-300">@\${k.created_by}</td>
          <td class="py-3 px-3"><span class="px-2 py-0.5 rounded text-[10px] font-bold border \${statusClass}">\${k.status}</span></td>
          <td class="py-3 px-3 text-gray-300">\${durText}</td>
          <td class="py-3 px-3 font-mono text-[11px]">\${devText}</td>
          <td class="py-3 px-3 text-gray-400 truncate max-w-[150px]">\${k.note || '-'}</td>
          <td class="py-3 px-3 text-right space-x-1 whitespace-nowrap">
            <button onclick="copyToClipboard('\${k.key}')" title="Sao chép key" class="p-1.5 rounded bg-white/5 hover:bg-white/15 text-gray-300"><i class="fas fa-copy"></i></button>
            \${k.status === 'BANNED' 
              ? \`<button onclick="unbanKey('\${k.key}')" title="Mở khóa" class="p-1.5 rounded bg-emerald-500/20 hover:bg-emerald-500/30 text-emerald-400"><i class="fas fa-unlock"></i></button>\` 
              : \`<button onclick="banKey('\${k.key}')" title="Khóa (Ban)" class="p-1.5 rounded bg-amber-500/20 hover:bg-amber-500/30 text-amber-400"><i class="fas fa-ban"></i></button>\`}
            \${k.device_id ? \`<button onclick="resetDevice('\${k.key}')" title="Reset HWID" class="p-1.5 rounded bg-blue-500/20 hover:bg-blue-500/30 text-blue-400"><i class="fas fa-redo"></i></button>\` : ''}
            <button onclick="deleteKey('\${k.key}')" title="Xóa vĩnh viễn" class="p-1.5 rounded bg-red-500/20 hover:bg-red-500/30 text-red-400"><i class="fas fa-trash"></i></button>
          </td>
        \`;
        tbody.appendChild(tr);
      });
    }

    async function handleCreateKey() {
      const tier = document.getElementById('create-tier').value;
      const duration_days = parseInt(document.getElementById('create-duration').value);
      const quantity = parseInt(document.getElementById('create-quantity').value) || 1;
      const note = document.getElementById('create-note').value.trim();

      const data = await apiRequest('/admin/keys/create', 'POST', { tier, duration_days, quantity, note });
      if (data && data.success) {
        alert(data.message + '\\nKey đầu tiên: ' + data.key);
        document.getElementById('create-note').value = '';
        loadKeys();
        loadStats();
      } else if (data) {
        alert('Lỗi: ' + data.message);
      }
    }

    async function copyToClipboard(text) {
      await navigator.clipboard.writeText(text);
      alert('Đã sao chép: ' + text);
    }

    async function banKey(key) {
      if (!confirm('Khóa (Ban) key: ' + key + '?')) return;
      await apiRequest('/admin/keys/' + encodeURIComponent(key) + '/ban', 'POST');
      loadKeys(); loadStats();
    }

    async function unbanKey(key) {
      await apiRequest('/admin/keys/' + encodeURIComponent(key) + '/unban', 'POST');
      loadKeys(); loadStats();
    }

    async function resetDevice(key) {
      if (!confirm('Xóa liên kết thiết bị (Reset HWID) cho key: ' + key + '? Khách có thể đổi máy khác.')) return;
      await apiRequest('/admin/keys/' + encodeURIComponent(key) + '/reset-device', 'POST');
      loadKeys();
    }

    async function deleteKey(key) {
      if (!confirm('CẢNH BÁO: Xóa vĩnh viễn key: ' + key + '?')) return;
      await apiRequest('/admin/keys/' + encodeURIComponent(key), 'DELETE');
      loadKeys(); loadStats();
    }

    // --- SELLER MANAGEMENT ---
    async function loadSellers() {
      const data = await apiRequest('/admin/sellers');
      if (!data || !data.sellers) return;

      const tbody = document.getElementById('sellers-tbody');
      tbody.innerHTML = '';

      data.sellers.forEach(s => {
        const tr = document.createElement('tr');
        tr.className = 'hover:bg-white/[0.02] transition-colors';
        tr.innerHTML = \`
          <td class="py-3 px-3 font-bold text-white">@\${s.username}</td>
          <td class="py-3 px-3 text-gray-300">\${s.name || '-'}</td>
          <td class="py-3 px-3"><span class="px-2 py-0.5 rounded text-[10px] font-black \${s.role === 'admin' ? 'bg-cyan-500/20 text-cyan-400' : 'bg-amber-500/20 text-amber-400'}">\${s.role.toUpperCase()}</span></td>
          <td class="py-3 px-3 text-[11px] text-gray-400">\${s.allowed_tiers}</td>
          <td class="py-3 px-3 font-bold text-cyan-400">\${s.total_keys_created || 0}</td>
          <td class="py-3 px-3"><span class="px-2 py-0.5 rounded text-[10px] font-bold \${s.status === 'active' ? 'text-emerald-400 bg-emerald-500/10' : 'text-red-400 bg-red-500/10'}">\${s.status.toUpperCase()}</span></td>
          <td class="py-3 px-3 text-right space-x-1 whitespace-nowrap">
            <button onclick="changeSellerPassword('\${s.username}')" title="Đổi mật khẩu" class="p-1.5 rounded bg-white/5 hover:bg-white/15 text-gray-300"><i class="fas fa-key"></i></button>
            \${s.username !== 'admin' ? \`
              <button onclick="toggleSellerStatus('\${s.username}')" title="Khóa/Mở khóa" class="p-1.5 rounded bg-amber-500/20 hover:bg-amber-500/30 text-amber-400"><i class="fas fa-user-slash"></i></button>
              <button onclick="deleteSeller('\${s.username}')" title="Xóa Seller" class="p-1.5 rounded bg-red-500/20 hover:bg-red-500/30 text-red-400"><i class="fas fa-trash"></i></button>
            \` : ''}
          </td>
        \`;
        tbody.appendChild(tr);
      });
    }

    async function handleCreateSeller() {
      const username = document.getElementById('seller-username').value.trim();
      const password = document.getElementById('seller-password').value.trim();
      const name = document.getElementById('seller-name').value.trim();
      const allowed_tiers = document.getElementById('seller-allowed-tiers').value;

      const data = await apiRequest('/admin/sellers/create', 'POST', { username, password, name, allowed_tiers });
      if (data && data.success) {
        alert(data.message);
        document.getElementById('seller-username').value = '';
        document.getElementById('seller-password').value = '';
        document.getElementById('seller-name').value = '';
        loadSellers();
      } else if (data) {
        alert('Lỗi: ' + data.message);
      }
    }

    async function toggleSellerStatus(u) {
      if (!confirm('Thay đổi trạng thái hoạt động của seller: ' + u + '?')) return;
      await apiRequest('/admin/sellers/' + encodeURIComponent(u) + '/toggle-status', 'POST');
      loadSellers();
    }

    async function changeSellerPassword(u) {
      const newPass = prompt('Nhập mật khẩu mới cho seller ' + u + ':');
      if (!newPass) return;
      await apiRequest('/admin/sellers/' + encodeURIComponent(u) + '/change-password', 'POST', { password: newPass });
      alert('Đã cập nhật mật khẩu thành công!');
    }

    async function deleteSeller(u) {
      if (!confirm('CẢNH BÁO: Xóa tài khoản seller: ' + u + '?')) return;
      await apiRequest('/admin/sellers/' + encodeURIComponent(u), 'DELETE');
      loadSellers();
    }
  </script>
</body>
</html>`;
}
