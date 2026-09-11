export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    // Giao diện Admin (Web)
    if (url.pathname === "/admin" && request.method === "GET") {
      const html = `
        <!DOCTYPE html>
        <html lang="vi">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>DNXTWEAKS - Notification Center</title>
          <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
          <style>
            * { box-sizing: border-box; margin: 0; padding: 0; }
            body { 
              font-family: 'Inter', sans-serif; 
              min-height: 100vh; 
              display: flex; 
              align-items: center; 
              justify-content: center; 
              background: linear-gradient(135deg, #1e1e2f 0%, #2a2a40 100%);
              color: #fff;
              padding: 20px;
            }
            .container {
              background: rgba(255, 255, 255, 0.05);
              backdrop-filter: blur(10px);
              -webkit-backdrop-filter: blur(10px);
              border: 1px solid rgba(255, 255, 255, 0.1);
              border-radius: 20px;
              padding: 40px 30px;
              width: 100%;
              max-width: 450px;
              box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            }
            .header { text-align: center; margin-bottom: 30px; }
            .header h2 { font-size: 24px; font-weight: 700; margin-bottom: 5px; color: #fff; }
            .header p { font-size: 14px; color: #a0a0b0; }
            
            .form-group { margin-bottom: 20px; text-align: left; }
            .form-group label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 8px; color: #c0c0d0; text-transform: uppercase; letter-spacing: 0.5px; }
            
            input, textarea {
              width: 100%;
              background: rgba(0, 0, 0, 0.2);
              border: 1px solid rgba(255, 255, 255, 0.1);
              color: #fff;
              padding: 14px;
              border-radius: 12px;
              font-size: 15px;
              font-family: 'Inter', sans-serif;
              transition: all 0.3s ease;
            }
            input:focus, textarea:focus {
              outline: none;
              border-color: #6c5ce7;
              background: rgba(0, 0, 0, 0.3);
              box-shadow: 0 0 0 3px rgba(108, 92, 231, 0.2);
            }
            textarea { resize: vertical; min-height: 100px; }
            
            button {
              width: 100%;
              padding: 16px;
              background: linear-gradient(135deg, #6c5ce7 0%, #a29bfe 100%);
              color: white;
              border: none;
              border-radius: 12px;
              font-size: 16px;
              font-weight: 700;
              cursor: pointer;
              transition: transform 0.2s, box-shadow 0.2s;
              margin-top: 10px;
            }
            button:hover {
              transform: translateY(-2px);
              box-shadow: 0 8px 20px rgba(108, 92, 231, 0.4);
            }
            button:active { transform: translateY(0); }
            
            #toast {
              position: fixed;
              top: 20px;
              right: 20px;
              padding: 15px 25px;
              border-radius: 10px;
              color: white;
              font-weight: 600;
              font-size: 14px;
              transform: translateX(150%);
              transition: transform 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
              z-index: 1000;
              box-shadow: 0 5px 15px rgba(0,0,0,0.3);
            }
            #toast.show { transform: translateX(0); }
            #toast.success { background: #00b894; }
            #toast.error { background: #d63031; }
          </style>
        </head>
        <body>
          <div id="toast"></div>
          
          <div class="container">
            <div class="header">
              <h2>Quản Lý Thông Báo</h2>
              <p>Hệ thống đẩy thông báo tới người dùng App</p>
            </div>
            
            <form id="notifyForm">
              <div class="form-group">
                <label>Mật Khẩu Admin</label>
                <input type="password" id="password" placeholder="Nhập mật khẩu..." required>
              </div>
              
              <div class="form-group">
                <label>Tiêu Đề Thông Báo</label>
                <input type="text" id="title" placeholder="VD: Cập nhật tính năng mới..." required>
              </div>
              
              <div class="form-group">
                <label>Nội Dung Thông Báo</label>
                <textarea id="message" placeholder="Nhập nội dung (Để trống nếu muốn TẮT thông báo)"></textarea>
              </div>
              
              <button type="submit" id="submitBtn">Đẩy Thông Báo Lên App</button>
            </form>
          </div>

          <script>
            function showToast(msg, isSuccess) {
              const toast = document.getElementById('toast');
              toast.textContent = msg;
              toast.className = isSuccess ? 'success show' : 'error show';
              setTimeout(() => { toast.classList.remove('show'); }, 3000);
            }

            document.getElementById('notifyForm').addEventListener('submit', async (e) => {
              e.preventDefault();
              const btn = document.getElementById('submitBtn');
              const password = document.getElementById('password').value;
              const title = document.getElementById('title').value;
              const message = document.getElementById('message').value;
              
              btn.textContent = 'Đang đẩy...';
              btn.style.opacity = '0.7';
              
              try {
                const res = await fetch('/admin', {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify({ password, title, message })
                });
                const result = await res.json();
                
                if (res.ok) {
                  showToast(result.status, true);
                  document.getElementById('password').value = '';
                } else {
                  showToast(result.error, false);
                }
              } catch(e) {
                showToast('Lỗi kết nối máy chủ', false);
              } finally {
                btn.textContent = 'Đẩy Thông Báo Lên App';
                btn.style.opacity = '1';
              }
            });
          </script>
        </body>
        </html>
      `;
      return new Response(html, { headers: { "Content-Type": "text/html;charset=UTF-8" } });
    }

    // Xử lý POST
    if (url.pathname === "/admin" && request.method === "POST") {
      try {
        const body = await request.json();
        if (body.password !== "admin123") {
          return new Response(JSON.stringify({ error: "Mật khẩu không chính xác!" }), { status: 401 });
        }

        const notificationData = {
          title: body.title || "Thông Báo",
          message: body.message || "",
          timestamp: Date.now()
        };

        await env.NOTIFICATIONS.put("latest", JSON.stringify(notificationData));

        return new Response(JSON.stringify({ status: "Đã cập nhật thông báo tới App!" }), {
          headers: { "Content-Type": "application/json" }
        });
      } catch (e) {
        return new Response(JSON.stringify({ error: "Lỗi hệ thống" }), { status: 500 });
      }
    }

    // API cho iOS App
    if (url.pathname === "/api/get-notification" && request.method === "GET") {
      const data = await env.NOTIFICATIONS.get("latest");
      if (data) {
        return new Response(data, { headers: { "Content-Type": "application/json" } });
      } else {
        return new Response(JSON.stringify({ title: "", message: "", timestamp: 0 }), {
          headers: { "Content-Type": "application/json" }
        });
      }
    }

    return new Response("Not found", { status: 404 });
  }
};
