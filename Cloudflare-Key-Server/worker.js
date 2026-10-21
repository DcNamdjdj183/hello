/**
 * ============================================================================
 * DNTWEAKS EXTERNAL IOS - UNIFIED KEY SERVER & MANAGEMENT PANEL
 * Engine: Cloudflare Workers + D1 Database (licenses)
 * Version: 2.5.0 Pro VIP (Dual Compatibility Edition)
 *
 * Full Backwards Compatibility:
 * - Table 'licenses' preserved with all columns: key, product, duration_days,
 *   max_devices, note, status, device_id, device_name, created_at,
 *   activated_at, expires_at, last_check_at.
 * - Auto-migrates and adds 'tier', 'allowed_modules', 'created_by' seamlessly.
 * - Supports legacy endpoints:
 *     POST /api/v1/auth/login
 *     POST /api/v1/auth/check
 *     POST /api/v1/auth/heartbeat
 * - Supports new iOS App endpoints:
 *     POST /api/activate
 *     POST /api/verify
 *     GET  /health
 * - Supports Admin & Seller endpoints:
 *     POST /api/admin/login
 *     POST /api/admin/keys/create (Multi-module checkboxes + combos)
 *     GET  /api/admin/keys
 *     GET  /api/admin/keys/:key
 *     POST /api/admin/keys/:key/ban
 *     POST /api/admin/keys/:key/unban
 *     POST /api/admin/keys/:key/revoke
 *     POST /api/admin/keys/:key/reset-device
 *     DELETE /api/admin/keys/:key
 *     GET  /api/admin/stats
 *     GET  /api/admin/sellers
 *     POST /api/admin/sellers/create
 *     POST /api/admin/sellers/:id/quota
 *     DELETE /api/admin/sellers/:id
 *     GET  /admin (Modern Cyber Dark Glass Panel)
 * ============================================================================
 */

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
  'Access-Control-Max-Age': '86400'
};

function handleCors(request) {
  if (request.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }
  return null;
}

function jsonResponse(data, status = 200, headers = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      ...CORS_HEADERS,
      ...headers
    }
  });
}

function sendError(code, message, status = 400) {
  return jsonResponse({
    success: false,
    valid: false,
    ok: false,
    error: code,
    message
  }, status);
}

// ----------------------------------------------------------------------------
// Database Auto-Initialization & Schema Migration
// ----------------------------------------------------------------------------
let dbMigrated = false;

async function ensureDb(db) {
  if (!db || dbMigrated) return;
  try {
    await db.exec(`
      CREATE TABLE IF NOT EXISTS licenses (
        key TEXT PRIMARY KEY,
        product TEXT,
        tier TEXT DEFAULT 'all',
        allowed_modules TEXT DEFAULT 'aimlock,sensitive,regedit',
        duration_days INTEGER NOT NULL DEFAULT 30,
        max_devices INTEGER DEFAULT 1,
        note TEXT,
        status TEXT NOT NULL DEFAULT 'UNUSED',
        device_id TEXT,
        device_name TEXT,
        created_by TEXT NOT NULL DEFAULT 'admin',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        activated_at TEXT,
        expires_at TEXT,
        last_check_at TEXT
      );

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
      CREATE INDEX IF NOT EXISTS idx_licenses_device_id ON licenses(device_id);
    `);

    // In case licenses table already existed from older deployment, safely add new columns:
    const migrations = [
      "ALTER TABLE licenses ADD COLUMN tier TEXT DEFAULT 'all'",
      "ALTER TABLE licenses ADD COLUMN allowed_modules TEXT DEFAULT 'aimlock,sensitive,regedit'",
      "ALTER TABLE licenses ADD COLUMN created_by TEXT DEFAULT 'admin'",
      "ALTER TABLE licenses ADD COLUMN device_name TEXT",
      "ALTER TABLE licenses ADD COLUMN last_check_at TEXT",
      "ALTER TABLE licenses ADD COLUMN max_devices INTEGER DEFAULT 1",
      "ALTER TABLE licenses ADD COLUMN note TEXT"
    ];
    for (const sql of migrations) {
      try { await db.exec(sql); } catch (_) {}
    }

    dbMigrated = true;
  } catch (err) {
    console.error('DB Migration Warning:', err);
  }
}

// ----------------------------------------------------------------------------
// Key Generator & Module Resolver
// ----------------------------------------------------------------------------
function generateLicenseKey(modules = ['aimlock', 'sensitive', 'regedit'], customPrefix = null) {
  let prefix = customPrefix;
  if (!prefix) {
    const hasAim = modules.includes('aimlock');
    const hasSens = modules.includes('sensitive');
    const hasReg = modules.includes('regedit');

    if (hasAim && hasSens && hasReg) {
      prefix = 'DNT-ALL';
    } else if (hasAim && !hasSens && !hasReg) {
      prefix = 'DNT-AIM';
    } else if (!hasAim && hasSens && !hasReg) {
      prefix = 'DNT-SENS';
    } else if (!hasAim && !hasSens && hasReg) {
      prefix = 'DNT-REG';
    } else if (hasAim && hasReg && !hasSens) {
      prefix = 'DNT-AIMREG';
    } else if (hasAim && hasSens && !hasReg) {
      prefix = 'DNT-AIMSENS';
    } else if (hasSens && hasReg && !hasAim) {
      prefix = 'DNT-SENSREG';
    } else {
      prefix = 'DNT-COMBO';
    }
  }

  const parts = [prefix];
  for (let i = 0; i < 3; i++) {
    const array = new Uint32Array(1);
    crypto.getRandomValues(array);
    let part = array[0].toString(36).toUpperCase();
    while (part.length < 4) {
      const randArray = new Uint8Array(1);
      crypto.getRandomValues(randArray);
      part += randArray[0].toString(36).charAt(0).toUpperCase();
    }
    parts.push(part.substring(0, 4));
  }
  return parts.join('-');
}

function parseLicenseModules(license) {
  let rawMods = [];
  if (license.allowed_modules && typeof license.allowed_modules === 'string') {
    rawMods = license.allowed_modules.split(',').map(m => m.trim().toLowerCase()).filter(Boolean);
  } else if (license.tier && typeof license.tier === 'string') {
    if (license.tier === 'all') {
      rawMods = ['aimlock', 'sensitive', 'regedit'];
    } else {
      rawMods = license.tier.split(',').map(m => m.trim().toLowerCase()).filter(Boolean);
    }
  } else {
    const prod = (license.product || '').toUpperCase();
    if (prod.includes('AIM') && !prod.includes('ALL') && !prod.includes('VIP')) {
      rawMods.push('aimlock');
    }
    if (prod.includes('SENS')) {
      rawMods.push('sensitive');
    }
    if (prod.includes('REG')) {
      rawMods.push('regedit');
    }
    if (rawMods.length === 0 || prod.includes('ALL') || prod.includes('VIP-ALL')) {
      rawMods = ['aimlock', 'sensitive', 'regedit'];
    }
  }

  const valid = new Set(['aimlock', 'sensitive', 'regedit']);
  const filtered = Array.from(new Set(rawMods.filter(m => valid.has(m))));
  const finalMods = filtered.length > 0 ? filtered : ['aimlock', 'sensitive', 'regedit'];

  let tier = license.tier;
  if (!tier) {
    if (finalMods.length === 3) tier = 'all';
    else tier = finalMods.join(',');
  }

  let tierName = 'ALL ACCESS VIP (TRỌN BỘ)';
  if (tier === 'all' || finalMods.length === 3) {
    tierName = 'ALL ACCESS VIP (TRỌN BỘ)';
  } else if (finalMods.length === 1) {
    if (finalMods[0] === 'aimlock') tierName = 'AIMLOCK VIP (V1-V5)';
    else if (finalMods[0] === 'sensitive') tierName = 'SENSITIVE VIP (V1-V5)';
    else if (finalMods[0] === 'regedit') tierName = 'REGEDIT VIP (V1-V5)';
    else tierName = finalMods[0].toUpperCase() + ' VIP';
  } else {
    tierName = finalMods.map(m => m.toUpperCase()).join(' + ') + ' VIP';
  }

  return { tier, tierName, allowedModules: finalMods };
}

// ----------------------------------------------------------------------------
// Authentication Helper (Master Admin & Seller Support)
// ----------------------------------------------------------------------------
async function authenticateAdminOrSeller(request, env) {
  const authHeader = request.headers.get('Authorization') || '';
  let token = '';
  if (authHeader.startsWith('Bearer ')) {
    token = authHeader.substring(7).trim();
  } else {
    const url = new URL(request.url);
    token = url.searchParams.get('token') || '';
  }

  if (!token) {
    return { ok: false, error: 'UNAUTHORIZED', message: 'Missing Authorization token', status: 401 };
  }

  const adminSecret = env.ADMIN_SECRET || 'DNTWEAKS_SECRET';
  if (token === adminSecret || token === 'ADMIN_AUTH_DUCNAMTWEAKS_18042010') {
    return { ok: true, role: 'admin', username: 'DucNamTweaks', name: 'Master Admin (DucNamTweaks)' };
  }

  // Check Seller token (Format: SELLER:username:password)
  if (token.startsWith('SELLER:')) {
    const parts = token.split(':');
    if (parts.length >= 3) {
      const username = parts[1];
      const password = parts.slice(2).join(':');
      if (env.DB) {
        await ensureDb(env.DB);
        const seller = await env.DB.prepare(
          'SELECT * FROM sellers WHERE username = ? AND password = ? AND status = ?'
        ).bind(username, password, 'active').first();

        if (seller) {
          return {
            ok: true,
            role: seller.role || 'seller',
            username: seller.username,
            name: seller.name || seller.username,
            seller
          };
        }
      }
    }
  }

  return { ok: false, error: 'UNAUTHORIZED', message: 'Mã xác thực hoặc tài khoản không hợp lệ', status: 401 };
}

// ----------------------------------------------------------------------------
// Shared Activation & Verification Logic
// ----------------------------------------------------------------------------
async function activateOrLoginKey(db, key, deviceId, deviceName, product = null) {
  const license = await db.prepare('SELECT * FROM licenses WHERE key = ?').bind(key).first();
  if (!license) {
    return { success: false, code: 'KEY_NOT_FOUND', message: 'Mã key không tồn tại trên hệ thống' };
  }

  // Product verification (lenient: allows if exact match, or key has VIP ALL, or product matches module)
  if (product && license.product && license.product !== product) {
    const tierInfo = parseLicenseModules(license);
    const prodUpper = product.toUpperCase();
    const isMatchingModule = tierInfo.allowedModules.some(m => prodUpper.includes(m.toUpperCase()));
    if (!isMatchingModule && tierInfo.tier !== 'all' && !prodUpper.includes('ALL')) {
      return { success: false, code: 'PRODUCT_MISMATCH', message: 'Key không hỗ trợ phân hệ/sản phẩm này' };
    }
  }

  if (license.status === 'BANNED') {
    return { success: false, code: 'KEY_BANNED', message: 'Key đã bị khóa (BANNED) do vi phạm quy định' };
  }
  if (license.status === 'REVOKED') {
    return { success: false, code: 'KEY_REVOKED', message: 'Key đã bị thu hồi (REVOKED)' };
  }
  if (license.status === 'EXPIRED') {
    return { success: false, code: 'KEY_EXPIRED', message: 'Key đã hết thời hạn sử dụng' };
  }

  if (license.expires_at) {
    const expTime = new Date(license.expires_at).getTime();
    if (Date.now() > expTime) {
      await db.prepare("UPDATE licenses SET status = 'EXPIRED' WHERE key = ?").bind(key).run();
      return { success: false, code: 'KEY_EXPIRED', message: 'Key đã hết hạn sử dụng' };
    }
  }

  const tierInfo = parseLicenseModules(license);
  const nowIso = new Date().toISOString();

  // If UNUSED -> Activate
  if (license.status === 'UNUSED') {
    const durationDays = license.duration_days ?? 30;
    let expiresAt;
    if (license.note && license.note.includes('hours:')) {
      const matchHours = license.note.match(/hours:(\d+)/);
      const h = matchHours ? parseInt(matchHours[1]) : 2;
      expiresAt = new Date(Date.now() + h * 3600000).toISOString();
    } else if (durationDays === -1) {
      expiresAt = '2099-12-31T23:59:59.000Z';
    } else {
      const exp = new Date();
      exp.setUTCDate(exp.getUTCDate() + durationDays);
      expiresAt = exp.toISOString();
    }

    const updated = await db.prepare(`
      UPDATE licenses
      SET status = 'ACTIVE',
          activated_at = ?,
          expires_at = ?,
          device_id = ?,
          device_name = ?,
          last_check_at = ?
      WHERE key = ? AND status = 'UNUSED'
      RETURNING *
    `).bind(nowIso, expiresAt, deviceId, deviceName || 'iOS Device', nowIso, key).first();

    return {
      success: true,
      valid: true,
      ok: true,
      status: 'ACTIVE',
      message: 'Kích hoạt bản quyền thành công!',
      license: updated || license,
      product: license.product,
      tier: tierInfo.tier,
      tierName: tierInfo.tierName,
      allowedModules: tierInfo.allowedModules,
      expires_at: expiresAt,
      expiresAt
    };
  }

  // If ACTIVE -> Check device_id HWID
  if (license.device_id && license.device_id !== deviceId) {
    return {
      success: false,
      code: 'DEVICE_MISMATCH',
      message: 'Key này đã được kích hoạt trên thiết bị khác. Vui lòng liên hệ Admin/Seller để Reset HWID.'
    };
  }

  // Update heartbeat
  await db.prepare('UPDATE licenses SET last_check_at = ? WHERE key = ?').bind(nowIso, key).run();

  return {
    success: true,
    valid: true,
    ok: true,
    status: 'ACTIVE',
    message: 'Xác thực bản quyền thành công',
    license,
    product: license.product,
    tier: tierInfo.tier,
    tierName: tierInfo.tierName,
    allowedModules: tierInfo.allowedModules,
    expires_at: license.expires_at,
    expiresAt: license.expires_at
  };
}

// ----------------------------------------------------------------------------
// Main Request Handler
// ----------------------------------------------------------------------------
export default {
  async fetch(request, env, ctx) {
    const corsRes = handleCors(request);
    if (corsRes) return corsRes;

    const url = new URL(request.url);
    const path = url.pathname.replace(/\/+$/, '') || '/';
    const method = request.method.toUpperCase();

    // Ensure database schema is ready
    if (env.DB) {
      await ensureDb(env.DB);
    }

    // 1. Health Check
    if (path === '/health' && method === 'GET') {
      return jsonResponse({
        status: 'ok',
        service: 'DNTWEAKS KEY SERVER',
        version: '2.5.0 Pro VIP',
        compatibility: 'Unified Dual-API'
      });
    }

    // 2. Admin Panel Web UI
    if (path === '/admin' && method === 'GET') {
      return new Response(renderAdminHtml(), {
        headers: { 'Content-Type': 'text/html; charset=utf-8' }
      });
    }

    // 3. New iOS App Activation Endpoint: POST /api/activate
    if (path === '/api/activate' && method === 'POST') {
      try {
        const body = await request.json().catch(() => ({}));
        const key = (body.key || '').trim().toUpperCase();
        const hwid = (body.hwid || body.device_id || '').trim();
        const deviceName = (body.device_name || 'iOS Device').trim();

        if (!key || !hwid) {
          return sendError('INVALID_REQUEST', 'Vui lòng cung cấp mã Key và Device HWID');
        }

        const result = await activateOrLoginKey(env.DB, key, hwid, deviceName);
        if (!result.success) {
          return sendError(result.code, result.message, 400);
        }

        return jsonResponse({
          ok: true,
          success: true,
          valid: true,
          status: result.status,
          tier: result.tier,
          tierName: result.tierName,
          allowedModules: result.allowedModules,
          expiresAt: result.expiresAt,
          expires_at: result.expires_at,
          message: result.message
        });
      } catch (err) {
        return sendError('SERVER_ERROR', err.message || 'Lỗi xử lý kích hoạt', 500);
      }
    }

    // 3.1 Free Trial Key Generation (Used by getkey-dnxtweaks.pages.dev)
    if (path === '/api/generate-free-key' && method === 'POST') {
      try {
        const body = await request.json().catch(() => ({}));
        const tier = (body.tier || '').trim().toLowerCase();
        const hours = parseInt(body.hours ?? 2);

        // Bắt buộc: Không cho phép getkey toàn bộ chức năng (VIP ALL)
        if (!tier || tier === 'all' || (Array.isArray(body.modules) && body.modules.length > 1)) {
          return sendError('TIER_FORBIDDEN', 'Gói VIP Toàn Bộ không được cấp miễn phí. Vui lòng liên hệ Admin qua Telegram @dntweaks hoặc Zalo 0395109314!', 403);
        }

        let modules = [];
        if (tier === 'aimlock') modules = ['aimlock'];
        else if (tier === 'sensitive') modules = ['sensitive'];
        else if (tier === 'regedit') modules = ['regedit'];
        else {
          return sendError('INVALID_TIER', 'Chỉ được chọn 1 phân hệ dùng thử: aimlock, sensitive hoặc regedit', 400);
        }

        const key = generateLicenseKey(modules);
        const allowedModulesStr = modules.join(',');
        const note = `Free Trial ${hours}H - hours:${hours}`;
        const product = `DNTWEAKS-${tier.toUpperCase()}`;

        await env.DB.prepare(`
          INSERT INTO licenses (
            key, product, tier, allowed_modules, duration_days, max_devices, note, status, created_by, created_at
          ) VALUES (?, ?, ?, ?, 1, 1, ?, 'UNUSED', 'free_system', CURRENT_TIMESTAMP)
        `).bind(key, product, tier, allowedModulesStr, note).run();

        const tierInfo = parseLicenseModules({ tier, allowed_modules: allowedModulesStr, product });

        return jsonResponse({
          ok: true,
          success: true,
          key,
          tier: tierInfo.tier,
          tierName: tierInfo.tierName,
          allowedModules: tierInfo.allowedModules,
          hours,
          duration: `${hours} Giờ Trải Nghiệm`
        });
      } catch (err) {
        return sendError('SERVER_ERROR', err.message || 'Lỗi tạo key miễn phí', 500);
      }
    }

    // 4. New iOS App Verification Endpoint: POST /api/verify
    if (path === '/api/verify' && method === 'POST') {
      try {
        const body = await request.json().catch(() => ({}));
        const key = (body.key || '').trim().toUpperCase();
        const hwid = (body.hwid || body.device_id || '').trim();

        if (!key || !hwid) {
          return sendError('INVALID_REQUEST', 'Vui lòng cung cấp mã Key và Device HWID');
        }

        const license = await env.DB.prepare('SELECT * FROM licenses WHERE key = ?').bind(key).first();
        if (!license) {
          return sendError('KEY_NOT_FOUND', 'Mã key không tồn tại');
        }

        if (license.status === 'BANNED') return sendError('KEY_BANNED', 'Key đã bị khóa');
        if (license.status === 'REVOKED') return sendError('KEY_REVOKED', 'Key đã bị thu hồi');
        if (license.status === 'EXPIRED') return sendError('KEY_EXPIRED', 'Key đã hết hạn');

        if (license.expires_at && Date.now() > new Date(license.expires_at).getTime()) {
          await env.DB.prepare("UPDATE licenses SET status = 'EXPIRED' WHERE key = ?").bind(key).run();
          return sendError('KEY_EXPIRED', 'Key đã hết hạn');
        }

        if (license.device_id && license.device_id !== hwid) {
          return sendError('DEVICE_MISMATCH', 'Thiết bị không trùng khớp với mã key');
        }

        const tierInfo = parseLicenseModules(license);
        let daysRemaining = 0;
        if (license.expires_at) {
          const msRemaining = new Date(license.expires_at).getTime() - Date.now();
          daysRemaining = Math.max(0, Math.floor(msRemaining / (1000 * 60 * 60 * 24)));
        }

        return jsonResponse({
          ok: true,
          success: true,
          valid: true,
          status: license.status,
          tier: tierInfo.tier,
          tierName: tierInfo.tierName,
          allowedModules: tierInfo.allowedModules,
          expiresAt: license.expires_at,
          expires_at: license.expires_at,
          days_remaining: daysRemaining,
          daysRemaining,
          message: 'Key hợp lệ'
        });
      } catch (err) {
        return sendError('SERVER_ERROR', err.message, 500);
      }
    }

    // 5. Legacy Auth Endpoints (/api/v1/auth/*)
    if (path === '/api/v1/auth/login' && method === 'POST') {
      try {
        const body = await request.json().catch(() => ({}));
        const key = (body.key || '').trim().toUpperCase();
        const deviceId = (body.device_id || body.hwid || '').trim();
        const deviceName = (body.device_name || 'Unknown').trim();
        const product = body.product || null;

        if (!key || !deviceId) {
          return sendError('INVALID_REQUEST', 'Missing key or device_id');
        }

        const result = await activateOrLoginKey(env.DB, key, deviceId, deviceName, product);
        if (!result.success) {
          return sendError(result.code, result.message, 400);
        }

        return jsonResponse({
          success: true,
          valid: true,
          ok: true,
          status: result.status,
          message: result.message,
          product: result.product,
          tier: result.tier,
          tierName: result.tierName,
          allowedModules: result.allowedModules,
          expires_at: result.expires_at,
          expiresAt: result.expiresAt
        });
      } catch (err) {
        return sendError('SERVER_ERROR', err.message || 'Internal error', 500);
      }
    }

    if (path === '/api/v1/auth/check' && method === 'POST') {
      try {
        const body = await request.json().catch(() => ({}));
        const key = (body.key || '').trim().toUpperCase();
        const deviceId = (body.device_id || body.hwid || '').trim();
        const product = body.product || null;

        if (!key || !deviceId) {
          return sendError('INVALID_REQUEST', 'Missing fields');
        }

        const license = await env.DB.prepare('SELECT * FROM licenses WHERE key = ?').bind(key).first();
        if (!license) return sendError('KEY_NOT_FOUND', 'Key does not exist', 404);

        if (license.status === 'BANNED') return sendError('KEY_BANNED', 'Key has been banned');
        if (license.status === 'REVOKED') return sendError('KEY_REVOKED', 'Key has been revoked');
        if (license.status === 'EXPIRED') return sendError('KEY_EXPIRED', 'Key has expired');

        if (license.expires_at && Date.now() > new Date(license.expires_at).getTime()) {
          await env.DB.prepare("UPDATE licenses SET status = 'EXPIRED' WHERE key = ?").bind(key).run();
          return sendError('KEY_EXPIRED', 'Key has expired');
        }

        if (license.status === 'UNUSED') {
          return sendError('UNAUTHORIZED', 'Key not activated yet');
        }

        if (license.device_id !== deviceId) {
          return sendError('DEVICE_MISMATCH', 'Device mismatch');
        }

        let daysRemaining = 0;
        if (license.expires_at) {
          const msRemaining = new Date(license.expires_at).getTime() - Date.now();
          daysRemaining = Math.max(0, Math.floor(msRemaining / (1000 * 60 * 60 * 24)));
        }

        const tierInfo = parseLicenseModules(license);
        return jsonResponse({
          success: true,
          valid: true,
          ok: true,
          status: license.status,
          product: license.product,
          tier: tierInfo.tier,
          tierName: tierInfo.tierName,
          allowedModules: tierInfo.allowedModules,
          expires_at: license.expires_at,
          expiresAt: license.expires_at,
          days_remaining: daysRemaining
        });
      } catch (err) {
        return sendError('SERVER_ERROR', err.message, 500);
      }
    }

    if (path === '/api/v1/auth/heartbeat' && method === 'POST') {
      try {
        const body = await request.json().catch(() => ({}));
        const key = (body.key || '').trim().toUpperCase();
        const deviceId = (body.device_id || body.hwid || '').trim();

        if (!key || !deviceId) return sendError('INVALID_REQUEST', 'Missing fields');

        const now = new Date().toISOString();
        await env.DB.prepare(`
          UPDATE licenses
          SET last_check_at = ?
          WHERE key = ? AND device_id = ?
        `).bind(now, key, deviceId).run();

        return jsonResponse({ success: true, ok: true });
      } catch (err) {
        return sendError('SERVER_ERROR', 'Heartbeat failed', 500);
      }
    }

    // 6. Admin / Seller Login Endpoint
    if (path === '/api/admin/login' && method === 'POST') {
      try {
        const body = await request.json().catch(() => ({}));
        const secret = (body.secret || '').trim();
        const username = (body.username || '').trim();
        const password = (body.password || '').trim();

        const adminSecret = env.ADMIN_SECRET || 'DNTWEAKS_SECRET';

        // Master Admin: DucNamTweaks / 18042010 hoặc mã ADMIN_SECRET
        const isMasterAdmin = (username.toLowerCase() === 'ducnamtweaks' && password === '18042010');
        if (isMasterAdmin || (secret && secret === adminSecret)) {
          return jsonResponse({
            success: true,
            role: 'admin',
            username: 'DucNamTweaks',
            name: 'Master Admin (DucNamTweaks)',
            token: 'ADMIN_AUTH_DUCNAMTWEAKS_18042010'
          });
        }

        // Seller login
        if (username && password) {
          const seller = await env.DB.prepare(
            'SELECT * FROM sellers WHERE username = ? AND password = ? AND status = ?'
          ).bind(username, password, 'active').first();

          if (seller) {
            const token = `SELLER:${seller.username}:${seller.password}`;
            return jsonResponse({
              success: true,
              role: seller.role || 'seller',
              username: seller.username,
              name: seller.name || seller.username,
              max_keys: seller.max_keys,
              used_keys: seller.used_keys,
              quota_remaining: seller.max_keys === 0 ? 'Vô hạn' : Math.max(0, seller.max_keys - seller.used_keys),
              token
            });
          }
        }

        return sendError('UNAUTHORIZED', 'Mã bí mật hoặc tài khoản/mật khẩu không đúng', 401);
      } catch (err) {
        return sendError('SERVER_ERROR', err.message, 500);
      }
    }

    // 7. Protected Admin & Seller APIs
    if (path.startsWith('/api/admin/')) {
      const auth = await authenticateAdminOrSeller(request, env);
      if (!auth.ok) {
        return sendError(auth.error, auth.message, auth.status);
      }

      // GET /api/admin/stats
      if (path === '/api/admin/stats' && method === 'GET') {
        let countQuery = 'SELECT status, COUNT(*) as count FROM licenses';
        const params = [];
        if (auth.role === 'seller') {
          countQuery += ' WHERE created_by = ?';
          params.push(auth.username);
        }
        countQuery += ' GROUP BY status';

        const { results } = await env.DB.prepare(countQuery).bind(...params).all();
        const stats = {
          total_keys: 0,
          active_keys: 0,
          unused_keys: 0,
          expired_keys: 0,
          banned_keys: 0,
          revoked_keys: 0,
          total_sellers: 0
        };

        (results || []).forEach(row => {
          stats.total_keys += row.count;
          const k = row.status.toLowerCase() + '_keys';
          if (stats[k] !== undefined) stats[k] = row.count;
        });

        if (auth.role === 'admin') {
          const sellersRow = await env.DB.prepare('SELECT COUNT(*) as count FROM sellers').first();
          stats.total_sellers = sellersRow?.count || 0;
        }

        return jsonResponse({ success: true, stats, role: auth.role, username: auth.username });
      }

      // POST /api/admin/keys/create
      if (path === '/api/admin/keys/create' && method === 'POST') {
        try {
          const body = await request.json().catch(() => ({}));
          const durationDays = parseInt(body.duration_days ?? 30);
          const maxDevices = parseInt(body.max_devices ?? 1);
          const note = body.note || null;
          const customPrefix = body.prefix || null;

          // Check Seller Quota
          if (auth.role === 'seller' && auth.seller) {
            if (auth.seller.max_keys > 0 && auth.seller.used_keys >= auth.seller.max_keys) {
              return sendError('QUOTA_EXCEEDED', 'Bạn đã tạo hết hạn mức (quota) key được cấp. Liên hệ Master Admin.', 403);
            }
          }

          // Module & Tier Selection
          let selectedMods = [];
          if (Array.isArray(body.modules) && body.modules.length > 0) {
            selectedMods = body.modules.map(m => m.trim().toLowerCase());
          } else if (typeof body.modules === 'string' && body.modules.trim()) {
            selectedMods = body.modules.split(',').map(m => m.trim().toLowerCase());
          } else if (body.tier) {
            if (body.tier === 'all') selectedMods = ['aimlock', 'sensitive', 'regedit'];
            else selectedMods = body.tier.split(',').map(m => m.trim().toLowerCase());
          } else {
            selectedMods = ['aimlock', 'sensitive', 'regedit'];
          }

          const validMods = new Set(['aimlock', 'sensitive', 'regedit']);
          const finalMods = Array.from(new Set(selectedMods.filter(m => validMods.has(m))));
          if (finalMods.length === 0) finalMods.push('aimlock', 'sensitive', 'regedit');

          let tier = finalMods.length === 3 ? 'all' : finalMods.join(',');
          let product = body.product;
          if (!product) {
            if (tier === 'all') product = 'DNTWEAKS-VIP-ALL';
            else if (tier === 'aimlock') product = 'DNTWEAKS-AIMLOCK';
            else if (tier === 'sensitive') product = 'DNTWEAKS-SENSITIVE';
            else if (tier === 'regedit') product = 'DNTWEAKS-REGEDIT';
            else product = 'DNTWEAKS-COMBO';
          }

          const key = generateLicenseKey(finalMods, customPrefix);
          const allowedModulesStr = finalMods.join(',');
          const createdBy = auth.username;

          await env.DB.prepare(`
            INSERT INTO licenses (
              key, product, tier, allowed_modules, duration_days, max_devices, note, status, created_by, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, 'UNUSED', ?, CURRENT_TIMESTAMP)
          `).bind(key, product, tier, allowedModulesStr, durationDays, maxDevices, note, createdBy).run();

          // If Seller, increment used_keys
          if (auth.role === 'seller') {
            await env.DB.prepare('UPDATE sellers SET used_keys = used_keys + 1 WHERE username = ?').bind(auth.username).run();
          }

          const tierInfo = parseLicenseModules({ tier, allowed_modules: allowedModulesStr, product });

          return jsonResponse({
            success: true,
            key,
            product,
            tier: tierInfo.tier,
            tierName: tierInfo.tierName,
            allowed_modules: finalMods,
            duration_days: durationDays,
            max_devices: maxDevices,
            status: 'UNUSED',
            expires_at: null,
            created_by: createdBy
          });
        } catch (err) {
          return sendError('SERVER_ERROR', err.message || 'Lỗi tạo key', 500);
        }
      }

      // GET /api/admin/keys
      if (path === '/api/admin/keys' && method === 'GET') {
        const search = url.searchParams.get('search') || '';
        const status = url.searchParams.get('status') || '';
        const product = url.searchParams.get('product') || '';
        const tier = url.searchParams.get('tier') || '';
        const page = Math.max(1, parseInt(url.searchParams.get('page') || '1'));
        const limit = Math.max(1, Math.min(100, parseInt(url.searchParams.get('limit') || '50')));
        const offset = (page - 1) * limit;

        let query = 'SELECT * FROM licenses WHERE 1=1';
        const params = [];

        if (auth.role === 'seller') {
          query += ' AND created_by = ?';
          params.push(auth.username);
        }

        if (search) {
          query += ' AND (key LIKE ? OR device_id LIKE ? OR note LIKE ?)';
          params.push(`%${search}%`, `%${search}%`, `%${search}%`);
        }

        if (status) {
          query += ' AND status = ?';
          params.push(status);
        }

        if (product) {
          query += ' AND product = ?';
          params.push(product);
        }

        if (tier) {
          query += ' AND (tier = ? OR allowed_modules LIKE ?)';
          params.push(tier, `%${tier}%`);
        }

        query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
        params.push(limit, offset);

        const { results } = await env.DB.prepare(query).bind(...params).all();

        // Enrich results with parsed modules
        const keys = (results || []).map(k => {
          const parsed = parseLicenseModules(k);
          return {
            ...k,
            tier: parsed.tier,
            tierName: parsed.tierName,
            allowed_modules_list: parsed.allowedModules
          };
        });

        return jsonResponse({ success: true, keys, page, limit });
      }

      // Single Key Operations: /api/admin/keys/:key/*
      const keyDetailMatch = path.match(/^\/api\/admin\/keys\/([^\/]+)$/);
      if (keyDetailMatch) {
        const key = decodeURIComponent(keyDetailMatch[1]);
        if (method === 'GET') {
          const license = await env.DB.prepare('SELECT * FROM licenses WHERE key = ?').bind(key).first();
          if (!license) return sendError('KEY_NOT_FOUND', 'Key not found', 404);
          if (auth.role === 'seller' && license.created_by !== auth.username) {
            return sendError('FORBIDDEN', 'Bạn không có quyền quản lý key này', 403);
          }
          return jsonResponse({ success: true, license: { ...license, ...parseLicenseModules(license) } });
        }
        if (method === 'DELETE') {
          const license = await env.DB.prepare('SELECT * FROM licenses WHERE key = ?').bind(key).first();
          if (!license) return sendError('KEY_NOT_FOUND', 'Key not found', 404);
          if (auth.role === 'seller' && license.created_by !== auth.username) {
            return sendError('FORBIDDEN', 'Bạn không có quyền xóa key này', 403);
          }
          await env.DB.prepare('DELETE FROM licenses WHERE key = ?').bind(key).run();
          return jsonResponse({ success: true, message: 'Key đã được xóa vĩnh viễn' });
        }
      }

      // POST /api/admin/keys/:key/ban
      const banMatch = path.match(/^\/api\/admin\/keys\/([^\/]+)\/ban$/);
      if (banMatch && method === 'POST') {
        const key = decodeURIComponent(banMatch[1]);
        const license = await env.DB.prepare('SELECT * FROM licenses WHERE key = ?').bind(key).first();
        if (!license) return sendError('KEY_NOT_FOUND', 'Key not found', 404);
        if (auth.role === 'seller' && license.created_by !== auth.username) {
          return sendError('FORBIDDEN', 'Không có quyền thao tác', 403);
        }
        await env.DB.prepare("UPDATE licenses SET status = 'BANNED' WHERE key = ?").bind(key).run();
        return jsonResponse({ success: true, message: 'Key banned' });
      }

      // POST /api/admin/keys/:key/unban
      const unbanMatch = path.match(/^\/api\/admin\/keys\/([^\/]+)\/unban$/);
      if (unbanMatch && method === 'POST') {
        const key = decodeURIComponent(unbanMatch[1]);
        const license = await env.DB.prepare('SELECT * FROM licenses WHERE key = ?').bind(key).first();
        if (!license) return sendError('KEY_NOT_FOUND', 'Key not found', 404);
        if (auth.role === 'seller' && license.created_by !== auth.username) {
          return sendError('FORBIDDEN', 'Không có quyền thao tác', 403);
        }
        const newStatus = license.device_id ? 'ACTIVE' : 'UNUSED';
        await env.DB.prepare('UPDATE licenses SET status = ? WHERE key = ?').bind(newStatus, key).run();
        return jsonResponse({ success: true, message: 'Key unbanned', status: newStatus });
      }

      // POST /api/admin/keys/:key/revoke
      const revokeMatch = path.match(/^\/api\/admin\/keys\/([^\/]+)\/revoke$/);
      if (revokeMatch && method === 'POST') {
        const key = decodeURIComponent(revokeMatch[1]);
        const license = await env.DB.prepare('SELECT * FROM licenses WHERE key = ?').bind(key).first();
        if (!license) return sendError('KEY_NOT_FOUND', 'Key not found', 404);
        if (auth.role === 'seller' && license.created_by !== auth.username) {
          return sendError('FORBIDDEN', 'Không có quyền thao tác', 403);
        }
        await env.DB.prepare("UPDATE licenses SET status = 'REVOKED' WHERE key = ?").bind(key).run();
        return jsonResponse({ success: true, message: 'Key revoked' });
      }

      // POST /api/admin/keys/:key/reset-device
      const resetMatch = path.match(/^\/api\/admin\/keys\/([^\/]+)\/reset-device$/);
      if (resetMatch && method === 'POST') {
        const key = decodeURIComponent(resetMatch[1]);
        const license = await env.DB.prepare('SELECT * FROM licenses WHERE key = ?').bind(key).first();
        if (!license) return sendError('KEY_NOT_FOUND', 'Key not found', 404);
        if (auth.role === 'seller' && license.created_by !== auth.username) {
          return sendError('FORBIDDEN', 'Không có quyền thao tác', 403);
        }
        await env.DB.prepare(`
          UPDATE licenses
          SET device_id = NULL, device_name = NULL, status = 'UNUSED'
          WHERE key = ?
        `).bind(key).run();
        return jsonResponse({ success: true, message: 'Đã reset HWID thiết bị thành công' });
      }

      // 8. Seller Management (Master Admin Only)
      if (path.startsWith('/api/admin/sellers')) {
        if (auth.role !== 'admin') {
          return sendError('FORBIDDEN', 'Chỉ Master Admin mới có quyền quản lý danh sách Đại Lý (Sellers)', 403);
        }

        // GET /api/admin/sellers
        if (path === '/api/admin/sellers' && method === 'GET') {
          const { results } = await env.DB.prepare(`
            SELECT id, username, name, role, allowed_tiers, max_keys, used_keys, status, created_at
            FROM sellers
            ORDER BY id DESC
          `).all();
          return jsonResponse({ success: true, sellers: results || [] });
        }

        // POST /api/admin/sellers/create
        if (path === '/api/admin/sellers/create' && method === 'POST') {
          const body = await request.json().catch(() => ({}));
          const username = (body.username || '').trim().toLowerCase();
          const password = (body.password || '').trim();
          const name = (body.name || username).trim();
          const maxKeys = parseInt(body.max_keys ?? 100);
          const allowedTiers = body.allowed_tiers || 'all,aimlock,sensitive,regedit';

          if (!username || !password) {
            return sendError('INVALID_REQUEST', 'Vui lòng điền tên đăng nhập và mật khẩu cho Seller');
          }

          try {
            await env.DB.prepare(`
              INSERT INTO sellers (username, password, name, max_keys, used_keys, allowed_tiers, status, created_at)
              VALUES (?, ?, ?, ?, 0, ?, 'active', CURRENT_TIMESTAMP)
            `).bind(username, password, name, maxKeys, allowedTiers).run();

            return jsonResponse({ success: true, message: `Tạo tài khoản đại lý ${username} thành công!` });
          } catch (e) {
            return sendError('DB_ERROR', e.message.includes('UNIQUE') ? 'Tên đăng nhập đại lý đã tồn tại' : e.message, 400);
          }
        }

        // POST /api/admin/sellers/:id/quota
        const quotaMatch = path.match(/^\/api\/admin\/sellers\/(\d+)\/quota$/);
        if (quotaMatch && method === 'POST') {
          const id = parseInt(quotaMatch[1]);
          const body = await request.json().catch(() => ({}));
          const maxKeys = parseInt(body.max_keys ?? 100);
          await env.DB.prepare('UPDATE sellers SET max_keys = ? WHERE id = ?').bind(maxKeys, id).run();
          return jsonResponse({ success: true, message: 'Đã cập nhật hạn mức quota thành công' });
        }

        // DELETE /api/admin/sellers/:id
        const delSellerMatch = path.match(/^\/api\/admin\/sellers\/(\d+)$/);
        if (delSellerMatch && method === 'DELETE') {
          const id = parseInt(delSellerMatch[1]);
          await env.DB.prepare('DELETE FROM sellers WHERE id = ?').bind(id).run();
          return jsonResponse({ success: true, message: 'Đã xóa tài khoản đại lý' });
        }
      }
    }

    return jsonResponse({ success: false, error: 'NOT_FOUND', message: 'Endpoint not found' }, 404);
  }
};

// ----------------------------------------------------------------------------
// Cyber Dark Glass Admin Panel HTML
// ----------------------------------------------------------------------------
function renderAdminHtml() {
  return `<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>DNTWEAKS KEY SERVER - Cyber Admin Panel</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg: #07090e;
      --card-bg: rgba(17, 24, 39, 0.7);
      --card-border: rgba(255, 255, 255, 0.08);
      --card-hover: rgba(255, 255, 255, 0.12);
      --primary: #06b6d4;
      --primary-glow: rgba(6, 182, 212, 0.25);
      --accent: #8b5cf6;
      --accent-glow: rgba(139, 92, 246, 0.25);
      --success: #10b981;
      --danger: #ef4444;
      --warning: #f59e0b;
      --text: #f1f5f9;
      --text-muted: #94a3b8;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Plus Jakarta Sans', sans-serif;
      background: radial-gradient(circle at 50% 0%, #1e1b4b 0%, var(--bg) 70%);
      color: var(--text);
      min-height: 100vh;
      padding: 24px 16px;
    }
    .container { max-width: 1200px; margin: 0 auto; }
    .glass {
      background: var(--card-bg);
      backdrop-filter: blur(16px);
      -webkit-backdrop-filter: blur(16px);
      border: 1px solid var(--card-border);
      border-radius: 16px;
      box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
    }
    header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 18px 24px;
      margin-bottom: 24px;
    }
    .brand { display: flex; align-items: center; gap: 12px; }
    .brand-logo {
      width: 40px; height: 40px; border-radius: 10px;
      background: linear-gradient(135deg, var(--primary), var(--accent));
      display: flex; align-items: center; justify-content: center;
      font-weight: 800; font-size: 20px; color: #fff;
      box-shadow: 0 0 15px var(--primary-glow);
    }
    .brand-title { font-size: 20px; font-weight: 800; letter-spacing: -0.5px; }
    .brand-badge {
      font-size: 11px; padding: 2px 8px; border-radius: 20px;
      background: rgba(6, 182, 212, 0.15); color: var(--primary);
      border: 1px solid rgba(6, 182, 212, 0.3); font-weight: 700;
    }
    .user-info { display: flex; align-items: center; gap: 14px; }
    .role-tag {
      font-size: 12px; font-weight: 700; padding: 4px 10px; border-radius: 8px;
      background: rgba(139, 92, 246, 0.15); color: #c4b5fd;
      border: 1px solid rgba(139, 92, 246, 0.3);
    }
    .btn-logout {
      background: rgba(239, 68, 68, 0.15); border: 1px solid rgba(239, 68, 68, 0.3);
      color: #fca5a5; padding: 6px 14px; border-radius: 8px; font-size: 13px;
      font-weight: 600; cursor: pointer; transition: all 0.2s;
    }
    .btn-logout:hover { background: var(--danger); color: #fff; }

    /* Tabs */
    .tabs { display: flex; gap: 8px; margin-bottom: 24px; }
    .tab-btn {
      padding: 10px 20px; border-radius: 10px; border: 1px solid var(--card-border);
      background: rgba(255, 255, 255, 0.03); color: var(--text-muted);
      font-weight: 600; font-size: 14px; cursor: pointer; transition: all 0.2s;
    }
    .tab-btn.active {
      background: linear-gradient(135deg, rgba(6, 182, 212, 0.2), rgba(139, 92, 246, 0.2));
      color: #fff; border-color: var(--primary);
      box-shadow: 0 0 15px var(--primary-glow);
    }

    /* Stats Grid */
    .stats-grid {
      display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 16px; margin-bottom: 24px;
    }
    .stat-card { padding: 18px; display: flex; flex-direction: column; gap: 6px; }
    .stat-title { font-size: 13px; color: var(--text-muted); font-weight: 600; }
    .stat-val { font-size: 28px; font-weight: 800; font-family: 'JetBrains Mono', monospace; }

    /* Generator Card */
    .section-card { padding: 24px; margin-bottom: 24px; }
    .section-title {
      font-size: 16px; font-weight: 700; margin-bottom: 18px;
      display: flex; align-items: center; gap: 8px; color: #fff;
    }
    .form-grid {
      display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
      gap: 18px; margin-bottom: 20px;
    }
    .form-group { display: flex; flex-direction: column; gap: 8px; }
    label { font-size: 13px; font-weight: 600; color: #cbd5e1; }
    input, select {
      background: rgba(15, 23, 42, 0.8); border: 1px solid var(--card-border);
      color: var(--text); padding: 10px 14px; border-radius: 10px;
      font-size: 14px; outline: none; transition: border-color 0.2s;
      font-family: inherit;
    }
    input:focus, select:focus { border-color: var(--primary); }

    /* Checkboxes Group */
    .modules-picker {
      background: rgba(15, 23, 42, 0.6); padding: 16px; border-radius: 12px;
      border: 1px solid var(--card-border); margin-bottom: 18px;
    }
    .checkbox-row {
      display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 12px; margin-top: 10px;
    }
    .checkbox-btn {
      display: flex; align-items: center; gap: 10px;
      padding: 10px 14px; border-radius: 8px;
      background: rgba(255, 255, 255, 0.02);
      border: 1px solid rgba(255, 255, 255, 0.08);
      cursor: pointer; user-select: none; transition: all 0.2s;
    }
    .checkbox-btn:hover { background: rgba(255, 255, 255, 0.05); }
    .checkbox-btn input[type="checkbox"] { width: 18px; height: 18px; accent-color: var(--primary); }
    .checkbox-btn span { font-size: 13px; font-weight: 600; }

    /* Quick combos */
    .quick-combos { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 10px; }
    .combo-btn {
      background: rgba(255, 255, 255, 0.04); border: 1px solid rgba(255, 255, 255, 0.1);
      color: #94a3b8; padding: 5px 12px; border-radius: 6px; font-size: 12px;
      font-weight: 600; cursor: pointer; transition: all 0.15s;
    }
    .combo-btn:hover { background: rgba(6, 182, 212, 0.2); color: #fff; border-color: var(--primary); }

    /* Submit Button */
    .btn-primary {
      background: linear-gradient(135deg, var(--primary), var(--accent));
      color: #fff; border: none; padding: 12px 24px; border-radius: 10px;
      font-weight: 700; font-size: 14px; cursor: pointer;
      display: inline-flex; align-items: center; gap: 8px;
      box-shadow: 0 4px 15px var(--primary-glow); transition: all 0.2s;
    }
    .btn-primary:hover { transform: translateY(-1px); opacity: 0.95; }

    /* Key Output Box */
    .key-result-box {
      margin-top: 18px; padding: 18px; border-radius: 12px;
      background: rgba(6, 182, 212, 0.08); border: 1px solid rgba(6, 182, 212, 0.3);
      display: none; align-items: center; justify-content: space-between; gap: 14px;
    }
    .key-result-text {
      font-family: 'JetBrains Mono', monospace; font-size: 18px; font-weight: 700;
      color: var(--primary); letter-spacing: 1px; user-select: all;
    }
    .btn-copy {
      background: rgba(6, 182, 212, 0.2); border: 1px solid var(--primary);
      color: #fff; padding: 8px 16px; border-radius: 8px; font-size: 13px;
      font-weight: 600; cursor: pointer; transition: all 0.2s;
    }
    .btn-copy:hover { background: var(--primary); }

    /* Search & Filter Bar */
    .filter-bar {
      display: flex; flex-wrap: wrap; gap: 12px; margin-bottom: 16px;
    }
    .filter-bar input { flex: 1; min-width: 200px; }
    .filter-bar select { min-width: 140px; }

    /* Table Styles */
    .table-container { overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; font-size: 13px; text-align: left; }
    th {
      padding: 12px 14px; color: var(--text-muted); font-weight: 600;
      border-bottom: 1px solid var(--card-border); background: rgba(0, 0, 0, 0.2);
    }
    td { padding: 12px 14px; border-bottom: 1px solid rgba(255, 255, 255, 0.04); vertical-align: middle; }
    tr:hover { background: rgba(255, 255, 255, 0.02); }
    .key-cell {
      font-family: 'JetBrains Mono', monospace; font-size: 13px; font-weight: 600;
      color: #38bdf8; user-select: all;
    }

    /* Badges */
    .badge {
      display: inline-block; padding: 3px 8px; border-radius: 6px;
      font-size: 11px; font-weight: 700; text-transform: uppercase;
    }
    .badge-ACTIVE { background: rgba(16, 185, 129, 0.15); color: #6ee7b7; border: 1px solid rgba(16, 185, 129, 0.3); }
    .badge-UNUSED { background: rgba(148, 163, 184, 0.15); color: #cbd5e1; border: 1px solid rgba(148, 163, 184, 0.3); }
    .badge-BANNED { background: rgba(239, 68, 68, 0.15); color: #fca5a5; border: 1px solid rgba(239, 68, 68, 0.3); }
    .badge-REVOKED { background: rgba(245, 158, 11, 0.15); color: #fcd34d; border: 1px solid rgba(245, 158, 11, 0.3); }
    .badge-EXPIRED { background: rgba(100, 116, 139, 0.2); color: #94a3b8; border: 1px solid rgba(100, 116, 139, 0.3); }

    .mod-tag {
      font-size: 10px; font-weight: 700; padding: 2px 6px; border-radius: 4px;
      margin-right: 4px; display: inline-block;
    }
    .mod-aim { background: rgba(239, 68, 68, 0.2); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.4); }
    .mod-sens { background: rgba(245, 158, 11, 0.2); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.4); }
    .mod-reg { background: rgba(16, 185, 129, 0.2); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.4); }

    /* Action Buttons in Table */
    .action-group { display: flex; gap: 6px; }
    .btn-act {
      padding: 4px 8px; border-radius: 6px; font-size: 11px; font-weight: 600;
      border: 1px solid transparent; cursor: pointer; transition: all 0.15s;
    }
    .btn-act-copy { background: rgba(6, 182, 212, 0.15); color: #38bdf8; border-color: rgba(6, 182, 212, 0.3); }
    .btn-act-reset { background: rgba(139, 92, 246, 0.15); color: #c4b5fd; border-color: rgba(139, 92, 246, 0.3); }
    .btn-act-ban { background: rgba(245, 158, 11, 0.15); color: #fbbf24; border-color: rgba(245, 158, 11, 0.3); }
    .btn-act-unban { background: rgba(16, 185, 129, 0.15); color: #6ee7b7; border-color: rgba(16, 185, 129, 0.3); }
    .btn-act-del { background: rgba(239, 68, 68, 0.15); color: #fca5a5; border-color: rgba(239, 68, 68, 0.3); }
    .btn-act:hover { opacity: 0.8; }

    /* Login Modal Overlay */
    #loginOverlay {
      position: fixed; inset: 0; background: rgba(7, 9, 14, 0.95);
      backdrop-filter: blur(20px); display: flex; align-items: center;
      justify-content: center; z-index: 9999; padding: 20px;
    }
    .login-box {
      width: 100%; max-width: 420px; padding: 32px; text-align: center;
    }
    .login-logo {
      width: 54px; height: 54px; border-radius: 14px;
      background: linear-gradient(135deg, var(--primary), var(--accent));
      display: inline-flex; align-items: center; justify-content: center;
      font-size: 26px; color: #fff; margin-bottom: 16px;
      box-shadow: 0 0 25px var(--primary-glow);
    }
    .login-mode-switch {
      display: flex; gap: 8px; margin: 20px 0 16px 0; background: rgba(0,0,0,0.3);
      padding: 4px; border-radius: 10px; border: 1px solid var(--card-border);
    }
    .mode-btn {
      flex: 1; padding: 8px; border-radius: 8px; border: none; background: transparent;
      color: var(--text-muted); font-size: 13px; font-weight: 600; cursor: pointer;
    }
    .mode-btn.active { background: rgba(255, 255, 255, 0.08); color: #fff; }
  </style>
</head>
<body>

  <!-- Modal Đăng Nhập -->
  <div id="loginOverlay">
    <div class="glass login-box">
      <div class="login-logo">⚡</div>
      <h2 style="font-weight: 800; font-size: 22px;">DNTWEAKS PANEL</h2>
      <p style="font-size: 13px; color: var(--text-muted); margin-top: 4px;">Đăng nhập để quản lý Key & Bản quyền</p>

      <div class="login-mode-switch">
        <button class="mode-btn active" id="btnModeAdmin" onclick="setLoginMode('admin')">Master Admin</button>
        <button class="mode-btn" id="btnModeSeller" onclick="setLoginMode('seller')">Đại Lý (Seller)</button>
      </div>

      <div id="formAdminLogin">
        <div class="form-group" style="text-align: left; margin-bottom: 12px;">
          <label>Tài Khoản Master Admin</label>
          <input type="text" id="adminUserInput" value="DucNamTweaks" placeholder="Nhập DucNamTweaks..." onkeyup="if(event.key==='Enter') doLogin()">
        </div>
        <div class="form-group" style="text-align: left; margin-bottom: 16px;">
          <label>Mật Khẩu Master Admin</label>
          <input type="password" id="adminPassInput" placeholder="Nhập mật khẩu (18042010)..." onkeyup="if(event.key==='Enter') doLogin()">
        </div>
      </div>

      <div id="formSellerLogin" style="display: none;">
        <div class="form-group" style="text-align: left; margin-bottom: 12px;">
          <label>Tên đăng nhập (Username)</label>
          <input type="text" id="sellerUserInput" placeholder="Nhập tên đăng nhập..." onkeyup="if(event.key==='Enter') doLogin()">
        </div>
        <div class="form-group" style="text-align: left; margin-bottom: 16px;">
          <label>Mật khẩu</label>
          <input type="password" id="sellerPassInput" placeholder="Nhập mật khẩu..." onkeyup="if(event.key==='Enter') doLogin()">
        </div>
      </div>

      <button class="btn-primary" style="width: 100%; justify-content: center; padding: 12px;" onclick="doLogin()">
        VÀO HỆ THỐNG QUẢN TRỊ 🚀
      </button>

      <div style="margin-top: 16px; font-size: 11px; color: var(--text-muted);">
        Hỗ trợ: <a href="https://t.me/dntweaks" target="_blank" style="color: var(--primary); text-decoration: none;">Telegram @dntweaks</a> • 
        <a href="https://zalo.me/0395109314" target="_blank" style="color: var(--primary); text-decoration: none;">Zalo 0395109314</a>
      </div>
    </div>
  </div>

  <!-- Giao Diện Chính -->
  <div class="container" id="mainApp" style="display: none;">
    <header class="glass">
      <div class="brand">
        <div class="brand-logo">⚡</div>
        <div>
          <div style="display: flex; align-items: center; gap: 8px;">
            <span class="brand-title">DNTWEAKS EXTERNAL</span>
            <span class="brand-badge">v2.5 PRO VIP</span>
          </div>
          <div style="font-size: 12px; color: var(--text-muted); margin-top: 2px;">Hệ Thống Phân Phối Key Bản Quyền Tự Động</div>
        </div>
      </div>
      <div class="user-info">
        <span class="role-tag" id="userRoleBadge">ADMIN</span>
        <span id="sellerQuotaBadge" style="display:none; font-size: 12px; color: var(--primary);">Quota: 0</span>
        <button class="btn-logout" onclick="logout()">Đăng Xuất</button>
      </div>
    </header>

    <!-- Navigation Tabs -->
    <div class="tabs">
      <button class="tab-btn active" id="tabKeysBtn" onclick="switchTab('keys')">🔑 Quản Lý Keys Bản Quyền</button>
      <button class="tab-btn" id="tabSellersBtn" onclick="switchTab('sellers')" style="display: none;">👥 Quản Lý Đại Lý (Sellers)</button>
    </div>

    <!-- TAB 1: KEYS MANAGEMENT -->
    <div id="tabKeysContent">
      <!-- Thống Kê Tổng Quan -->
      <div class="stats-grid">
        <div class="glass stat-card">
          <div class="stat-title">TỔNG SỐ KEYS</div>
          <div class="stat-val" id="statTotal" style="color: #38bdf8;">0</div>
        </div>
        <div class="glass stat-card">
          <div class="stat-title">ĐANG HOẠT ĐỘNG</div>
          <div class="stat-val" id="statActive" style="color: #34d399;">0</div>
        </div>
        <div class="glass stat-card">
          <div class="stat-title">KEY CHƯA KÍCH HOẠT</div>
          <div class="stat-val" id="statUnused" style="color: #cbd5e1;">0</div>
        </div>
        <div class="glass stat-card">
          <div class="stat-title">HẾT HẠN / ĐÃ KHÓA</div>
          <div class="stat-val" id="statBanned" style="color: #f87171;">0</div>
        </div>
      </div>

      <!-- Card Tạo Key Mới -->
      <div class="glass section-card">
        <div class="section-title">
          <span>⚡ TẠO KEY BẢN QUYỀN MỚI</span>
        </div>

        <!-- Bộ Chọn Phân Hệ (Modules Checkboxes) -->
        <div class="modules-picker">
          <label style="color: #fff; font-size: 13px;">Tùy chọn phân hệ được phép kích hoạt trong Key:</label>
          <div class="checkbox-row">
            <label class="checkbox-btn">
              <input type="checkbox" id="modAimlock" checked>
              <span>🎯 Aimlock VIP (V1 - V5)</span>
            </label>
            <label class="checkbox-btn">
              <input type="checkbox" id="modSensitive" checked>
              <span>⚡ Sensitive VIP (V1 - V5)</span>
            </label>
            <label class="checkbox-btn">
              <input type="checkbox" id="modRegedit" checked>
              <span>⚙️ Regedit VIP (V1 - V5)</span>
            </label>
          </div>
          <div class="quick-combos">
            <span style="font-size: 12px; color: var(--text-muted); align-self: center;">Chọn nhanh:</span>
            <button class="combo-btn" onclick="selectCombos('all')">VIP ALL (Trọn Bộ)</button>
            <button class="combo-btn" onclick="selectCombos('aim')">Chỉ Aimlock</button>
            <button class="combo-btn" onclick="selectCombos('sens')">Chỉ Sensitive</button>
            <button class="combo-btn" onclick="selectCombos('reg')">Chỉ Regedit</button>
            <button class="combo-btn" onclick="selectCombos('aim_reg')">Aim + Reg</button>
            <button class="combo-btn" onclick="selectCombos('aim_sens')">Aim + Sens</button>
          </div>
        </div>

        <div class="form-grid">
          <div class="form-group">
            <label>Thời Hạn Bản Quyền</label>
            <select id="keyDuration">
              <option value="1">1 Ngày (Dùng Thử)</option>
              <option value="3">3 Ngày (Trải Nghiệm)</option>
              <option value="7">7 Ngày (1 Tuần)</option>
              <option value="30" selected>30 Ngày (1 Tháng VIP)</option>
              <option value="90">90 Ngày (3 Tháng)</option>
              <option value="365">365 Ngày (1 Năm)</option>
              <option value="-1">Vĩnh Viễn (Lifetime VIP)</option>
            </select>
          </div>
          <div class="form-group">
            <label>Số Thiết Bị Tối Đa (Max Devices)</label>
            <input type="number" id="maxDevices" value="1" min="1">
          </div>
          <div class="form-group">
            <label>Ghi Chú Khách Hàng / Đơn Hàng</label>
            <input type="text" id="keyNote" placeholder="Ví dụ: Khách Facebook Zalo, Order #88...">
          </div>
        </div>

        <button class="btn-primary" onclick="createKey()">
          <span>🚀 TẠO MÃ KEY NGAY</span>
        </button>

        <div class="key-result-box" id="keyResultBox">
          <div>
            <div style="font-size: 12px; color: var(--text-muted); margin-bottom: 4px;">KEY MỚI ĐÃ TẠO THÀNH CÔNG:</div>
            <div class="key-result-text" id="createdKeyText">DNT-ALL-XXXX-YYYY-ZZZZ</div>
            <div id="createdKeyDetails" style="font-size: 12px; color: #cbd5e1; margin-top: 4px;"></div>
          </div>
          <button class="btn-copy" onclick="copyCreatedKey()">📋 SAO CHÉP KEY</button>
        </div>
      </div>

      <!-- Danh Sách Keys -->
      <div class="glass section-card">
        <div class="section-title">
          <span>📋 DANH SÁCH KEY BẢN QUYỀN TRÊN MÁY CHỦ</span>
        </div>

        <div class="filter-bar">
          <input type="text" id="searchInput" placeholder="🔍 Tìm kiếm theo Key, HWID Thiết bị, Ghi chú..." oninput="debounceLoadKeys()">
          <select id="statusFilter" onchange="loadKeys()">
            <option value="">Tất cả trạng thái</option>
            <option value="ACTIVE">Đang hoạt động (ACTIVE)</option>
            <option value="UNUSED">Chưa kích hoạt (UNUSED)</option>
            <option value="BANNED">Đã khóa (BANNED)</option>
            <option value="EXPIRED">Đã hết hạn (EXPIRED)</option>
          </select>
          <select id="tierFilter" onchange="loadKeys()">
            <option value="">Tất cả phân hệ</option>
            <option value="all">VIP ALL</option>
            <option value="aimlock">Aimlock</option>
            <option value="sensitive">Sensitive</option>
            <option value="regedit">Regedit</option>
          </select>
        </div>

        <div class="table-container">
          <table>
            <thead>
              <tr>
                <th>MÃ KEY</th>
                <th>PHÂN HỆ CẤP PHÉP</th>
                <th>TRẠNG THÁI</th>
                <th>THỜI HẠN</th>
                <th>THIẾT BỊ LIÊN KẾT (HWID)</th>
                <th>NGƯỜI TẠO</th>
                <th>THAO TÁC</th>
              </tr>
            </thead>
            <tbody id="keysTableBody">
              <tr><td colspan="7" style="text-align: center; color: var(--text-muted); padding: 24px;">Đang tải dữ liệu...</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- TAB 2: SELLERS MANAGEMENT (ADMIN ONLY) -->
    <div id="tabSellersContent" style="display: none;">
      <!-- Card Thêm Đại Lý -->
      <div class="glass section-card">
        <div class="section-title">
          <span>👥 TẠO TÀI KHOẢN ĐẠI LÝ (SELLER) MỚI</span>
        </div>
        <div class="form-grid">
          <div class="form-group">
            <label>Tên Đăng Nhập (Username)</label>
            <input type="text" id="sellerUsername" placeholder="ví dụ: seller_vip01">
          </div>
          <div class="form-group">
            <label>Mật Khẩu</label>
            <input type="text" id="sellerPassword" placeholder="Nhập mật khẩu cho seller">
          </div>
          <div class="form-group">
            <label>Tên Hiển Thị (Display Name)</label>
            <input type="text" id="sellerName" placeholder="ví dụ: Đại Lý Miền Nam">
          </div>
          <div class="form-group">
            <label>Hạn Mức Tạo Key (Quota)</label>
            <input type="number" id="sellerMaxKeys" value="100" min="0" placeholder="0 = Không giới hạn">
          </div>
        </div>
        <button class="btn-primary" onclick="createSeller()">
          <span>➕ TẠO ĐẠI LÝ MỚI</span>
        </button>
      </div>

      <!-- Bảng Danh Sách Đại Lý -->
      <div class="glass section-card">
        <div class="section-title">
          <span>👥 DANH SÁCH ĐẠI LÝ ĐANG HOẠT ĐỘNG</span>
        </div>
        <div class="table-container">
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>TÊN ĐĂNG NHẬP</th>
                <th>TÊN HIỂN THỊ</th>
                <th>QUOTA (ĐÃ DÙNG / TỐI ĐA)</th>
                <th>NGÀY TẠO</th>
                <th>THAO TÁC</th>
              </tr>
            </thead>
            <tbody id="sellersTableBody">
              <tr><td colspan="6" style="text-align: center; color: var(--text-muted); padding: 24px;">Đang tải danh sách đại lý...</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>

  <script>
    let currentToken = localStorage.getItem('dnt_token') || '';
    let currentRole = localStorage.getItem('dnt_role') || 'admin';
    let currentUsername = localStorage.getItem('dnt_user') || 'admin';
    let loginMode = 'admin';
    let debounceTimer = null;

    window.addEventListener('DOMContentLoaded', () => {
      if (currentToken) {
        initSession();
      }
    });

    function setLoginMode(mode) {
      loginMode = mode;
      document.getElementById('btnModeAdmin').classList.toggle('active', mode === 'admin');
      document.getElementById('btnModeSeller').classList.toggle('active', mode === 'seller');
      document.getElementById('formAdminLogin').style.display = mode === 'admin' ? 'block' : 'none';
      document.getElementById('formSellerLogin').style.display = mode === 'seller' ? 'block' : 'none';
    }

    async function doLogin() {
      if (loginMode === 'admin') {
        const username = document.getElementById('adminUserInput').value.trim();
        const password = document.getElementById('adminPassInput').value.trim();
        if (!username || !password) return alert('Vui lòng nhập tài khoản và mật khẩu Admin');
        const res = await fetch('/api/admin/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ username, password })
        });
        const data = await res.json();
        if (data && data.success) {
          saveSession(data.token, data.role, data.username);
        } else {
          alert(data.message || 'Sai tài khoản hoặc mật khẩu Master Admin!');
        }
      } else {
        const username = document.getElementById('sellerUserInput').value.trim();
        const password = document.getElementById('sellerPassInput').value.trim();
        if (!username || !password) return alert('Vui lòng nhập tên đăng nhập và mật khẩu');
        const res = await fetch('/api/admin/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ username, password })
        });
        const data = await res.json();
        if (data && data.success) {
          saveSession(data.token, data.role, data.username, data.quota_remaining);
        } else {
          alert(data.message || 'Sai thông tin đăng nhập!');
        }
      }
    }

    function saveSession(token, role, username, quota = null) {
      currentToken = token;
      currentRole = role;
      currentUsername = username;
      localStorage.setItem('dnt_token', token);
      localStorage.setItem('dnt_role', role);
      localStorage.setItem('dnt_user', username);
      initSession();
    }

    function initSession() {
      document.getElementById('loginOverlay').style.display = 'none';
      document.getElementById('mainApp').style.display = 'block';
      document.getElementById('userRoleBadge').textContent = currentRole === 'admin' ? '👑 MASTER ADMIN' : '👤 SELLER: ' + currentUsername.toUpperCase();
      
      if (currentRole === 'admin') {
        document.getElementById('tabSellersBtn').style.display = 'inline-block';
      } else {
        document.getElementById('tabSellersBtn').style.display = 'none';
      }

      loadStats();
      loadKeys();
    }

    function logout() {
      localStorage.removeItem('dnt_token');
      localStorage.removeItem('dnt_role');
      localStorage.removeItem('dnt_user');
      location.reload();
    }

    function switchTab(tab) {
      document.getElementById('tabKeysBtn').classList.toggle('active', tab === 'keys');
      document.getElementById('tabSellersBtn').classList.toggle('active', tab === 'sellers');
      document.getElementById('tabKeysContent').style.display = tab === 'keys' ? 'block' : 'none';
      document.getElementById('tabSellersContent').style.display = tab === 'sellers' ? 'block' : 'none';
      if (tab === 'sellers') loadSellers();
      if (tab === 'keys') loadKeys();
    }

    async function apiCall(endpoint, method = 'GET', body = null) {
      const headers = {
        'Authorization': 'Bearer ' + currentToken,
        'Content-Type': 'application/json'
      };
      const opt = { method, headers };
      if (body) opt.body = JSON.stringify(body);

      try {
        const res = await fetch(endpoint, opt);
        if (res.status === 401) {
          alert('Phiên làm việc đã hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.');
          logout();
          return null;
        }
        return await res.json();
      } catch (err) {
        alert('Lỗi kết nối máy chủ: ' + err.message);
        return null;
      }
    }

    // Quick Combo Buttons
    function selectCombos(type) {
      const aim = document.getElementById('modAimlock');
      const sens = document.getElementById('modSensitive');
      const reg = document.getElementById('modRegedit');
      if (type === 'all') { aim.checked = true; sens.checked = true; reg.checked = true; }
      else if (type === 'aim') { aim.checked = true; sens.checked = false; reg.checked = false; }
      else if (type === 'sens') { aim.checked = false; sens.checked = true; reg.checked = false; }
      else if (type === 'reg') { aim.checked = false; sens.checked = false; reg.checked = true; }
      else if (type === 'aim_reg') { aim.checked = true; sens.checked = false; reg.checked = true; }
      else if (type === 'aim_sens') { aim.checked = true; sens.checked = true; reg.checked = false; }
    }

    async function createKey() {
      const modules = [];
      if (document.getElementById('modAimlock').checked) modules.push('aimlock');
      if (document.getElementById('modSensitive').checked) modules.push('sensitive');
      if (document.getElementById('modRegedit').checked) modules.push('regedit');

      if (modules.length === 0) {
        return alert('Vui lòng chọn ít nhất 1 phân hệ cho Key (Aimlock, Sensitive, hoặc Regedit)!');
      }

      const duration_days = parseInt(document.getElementById('keyDuration').value);
      const max_devices = parseInt(document.getElementById('maxDevices').value);
      const note = document.getElementById('keyNote').value.trim();

      const data = await apiCall('/api/admin/keys/create', 'POST', {
        modules,
        duration_days,
        max_devices,
        note
      });

      if (data && data.success) {
        document.getElementById('keyResultBox').style.display = 'flex';
        document.getElementById('createdKeyText').textContent = data.key;
        document.getElementById('createdKeyDetails').textContent = 
          'Phân hệ: ' + (data.tierName || data.tier) + ' • Hạn dùng: ' + (data.duration_days === -1 ? 'Vĩnh viễn' : data.duration_days + ' Ngày');
        loadStats();
        loadKeys();
      } else if (data) {
        alert('Lỗi tạo key: ' + (data.message || data.error));
      }
    }

    function copyCreatedKey() {
      const key = document.getElementById('createdKeyText').textContent;
      navigator.clipboard.writeText(key).then(() => {
        alert('Đã sao chép Key: ' + key);
      });
    }

    async function loadStats() {
      const data = await apiCall('/api/admin/stats');
      if (data && data.success) {
        document.getElementById('statTotal').textContent = data.stats.total_keys || 0;
        document.getElementById('statActive').textContent = data.stats.active_keys || 0;
        document.getElementById('statUnused').textContent = data.stats.unused_keys || 0;
        document.getElementById('statBanned').textContent = (data.stats.banned_keys || 0) + (data.stats.expired_keys || 0);
      }
    }

    function debounceLoadKeys() {
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(loadKeys, 300);
    }

    async function loadKeys() {
      const search = document.getElementById('searchInput').value.trim();
      const status = document.getElementById('statusFilter').value;
      const tier = document.getElementById('tierFilter').value;

      let q = '/api/admin/keys?search=' + encodeURIComponent(search);
      if (status) q += '&status=' + encodeURIComponent(status);
      if (tier) q += '&tier=' + encodeURIComponent(tier);

      const data = await apiCall(q);
      const tbody = document.getElementById('keysTableBody');
      if (!data || !data.success) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: var(--danger); padding: 20px;">Lỗi tải dữ liệu</td></tr>';
        return;
      }

      if (!data.keys || data.keys.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: var(--text-muted); padding: 24px;">Không tìm thấy Key nào phù hợp</td></tr>';
        return;
      }

      tbody.innerHTML = '';
      data.keys.forEach(k => {
        const tr = document.createElement('tr');

        // Module badges
        let modBadges = '';
        const mods = k.allowed_modules_list || [];
        if (mods.includes('aimlock')) modBadges += '<span class="mod-tag mod-aim">AIM</span>';
        if (mods.includes('sensitive')) modBadges += '<span class="mod-tag mod-sens">SENS</span>';
        if (mods.includes('regedit')) modBadges += '<span class="mod-tag mod-reg">REG</span>';
        if (!modBadges) modBadges = '<span class="mod-tag" style="background:#334155;color:#94a3b8;">' + (k.product || 'ALL') + '</span>';

        // Duration text
        let durText = k.duration_days === -1 ? 'Vĩnh viễn' : (k.duration_days + ' Ngày');
        if (k.expires_at) {
          const expDate = new Date(k.expires_at);
          durText += '<br><span style="font-size: 11px; color: var(--text-muted);">' + expDate.toLocaleDateString('vi-VN') + '</span>';
        }

        // Action Buttons
        let actBtns = \`
          <button class="btn-act btn-act-copy" onclick="copyText('\${k.key}')" title="Sao chép">📋 Copy</button>
        \`;

        if (k.device_id) {
          actBtns += \`<button class="btn-act btn-act-reset" onclick="resetDevice('\${k.key}')" title="Reset HWID">🔄 Reset HWID</button>\`;
        }

        if (k.status === 'UNUSED' || k.status === 'ACTIVE') {
          actBtns += \`<button class="btn-act btn-act-ban" onclick="banKey('\${k.key}')">🚫 Ban</button>\`;
        } else if (k.status === 'BANNED') {
          actBtns += \`<button class="btn-act btn-act-unban" onclick="unbanKey('\${k.key}')">✓ Mở Ban</button>\`;
        }

        actBtns += \`<button class="btn-act btn-act-del" onclick="deleteKey('\${k.key}')">🗑️ Xóa</button>\`;

        tr.innerHTML = \`
          <td><span class="key-cell">\${k.key}</span></td>
          <td>\${modBadges}</td>
          <td><span class="badge badge-\${k.status}">\${k.status}</span></td>
          <td>\${durText}</td>
          <td style="font-family: monospace; font-size: 11px; color: var(--text-muted);">
            \${k.device_id ? (k.device_id.substring(0, 16) + '...<br><span style="color:#38bdf8;">' + (k.device_name || 'iOS Device') + '</span>') : 'Chưa liên kết'}
          </td>
          <td><span style="font-size: 12px; color: #a78bfa;">\${k.created_by || 'admin'}</span></td>
          <td><div class="action-group">\${actBtns}</div></td>
        \`;
        tbody.appendChild(tr);
      });
    }

    function copyText(str) {
      navigator.clipboard.writeText(str).then(() => alert('Đã sao chép: ' + str));
    }

    async function banKey(key) {
      if (!confirm('Khóa (Ban) mã key: ' + key + '?')) return;
      await apiCall('/api/admin/keys/' + key + '/ban', 'POST');
      loadKeys(); loadStats();
    }

    async function unbanKey(key) {
      await apiCall('/api/admin/keys/' + key + '/unban', 'POST');
      loadKeys(); loadStats();
    }

    async function resetDevice(key) {
      if (!confirm('Reset HWID thiết bị cho key: ' + key + '? Người dùng sẽ có thể kích hoạt trên thiết bị mới.')) return;
      await apiCall('/api/admin/keys/' + key + '/reset-device', 'POST');
      loadKeys();
    }

    async function deleteKey(key) {
      if (!confirm('XÓA VĨNH VIỄN mã key này khỏi hệ thống?')) return;
      await apiCall('/api/admin/keys/' + key, 'DELETE');
      loadKeys(); loadStats();
    }

    // Sellers Logic
    async function loadSellers() {
      const data = await apiCall('/api/admin/sellers');
      const tbody = document.getElementById('sellersTableBody');
      if (!data || !data.success) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: var(--danger); padding: 20px;">Lỗi tải đại lý</td></tr>';
        return;
      }
      if (!data.sellers || data.sellers.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: var(--text-muted); padding: 20px;">Chưa có tài khoản đại lý nào</td></tr>';
        return;
      }

      tbody.innerHTML = '';
      data.sellers.forEach(s => {
        const tr = document.createElement('tr');
        const quotaStr = s.max_keys === 0 ? (s.used_keys + ' / Vô hạn') : (s.used_keys + ' / ' + s.max_keys);
        tr.innerHTML = \`
          <td>#\${s.id}</td>
          <td style="font-weight: 700; color: #38bdf8;">\${s.username}</td>
          <td>\${s.name || s.username}</td>
          <td><span style="font-family: monospace; font-weight: 700;">\${quotaStr}</span></td>
          <td style="font-size: 11px; color: var(--text-muted);">\${new Date(s.created_at).toLocaleDateString('vi-VN')}</td>
          <td>
            <div class="action-group">
              <button class="btn-act btn-act-reset" onclick="updateSellerQuota(\${s.id}, \${s.max_keys})">⚡ Đổi Quota</button>
              <button class="btn-act btn-act-del" onclick="deleteSeller(\${s.id}, '\${s.username}')">🗑️ Xóa</button>
            </div>
          </td>
        \`;
        tbody.appendChild(tr);
      });
    }

    async function createSeller() {
      const username = document.getElementById('sellerUsername').value.trim();
      const password = document.getElementById('sellerPassword').value.trim();
      const name = document.getElementById('sellerName').value.trim();
      const max_keys = parseInt(document.getElementById('sellerMaxKeys').value);

      if (!username || !password) return alert('Vui lòng nhập Username và Mật khẩu cho đại lý');

      const data = await apiCall('/api/admin/sellers/create', 'POST', { username, password, name, max_keys });
      if (data && data.success) {
        alert(data.message);
        document.getElementById('sellerUsername').value = '';
        document.getElementById('sellerPassword').value = '';
        document.getElementById('sellerName').value = '';
        loadSellers();
      } else if (data) {
        alert('Lỗi: ' + data.message);
      }
    }

    async function updateSellerQuota(id, current) {
      const val = prompt('Nhập hạn mức số Key tối đa cho đại lý này (0 = Không giới hạn):', current);
      if (val === null) return;
      const max_keys = parseInt(val);
      if (isNaN(max_keys)) return alert('Hạn mức phải là số nguyên hợp lệ');
      const data = await apiCall('/api/admin/sellers/' + id + '/quota', 'POST', { max_keys });
      if (data && data.success) {
        alert('Đã cập nhật Quota thành công!');
        loadSellers();
      }
    }

    async function deleteSeller(id, username) {
      if (!confirm('Xóa vĩnh viễn đại lý ' + username + '?')) return;
      const data = await apiCall('/api/admin/sellers/' + id, 'DELETE');
      if (data && data.success) {
        alert('Đã xóa đại lý thành công');
        loadSellers();
      }
    }
  </script>
</body>
</html>`;
}
