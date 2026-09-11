export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    // Bảng điều khiển dành cho Admin (Giao diện web)
    if (url.pathname === "/admin" && request.method === "GET") {
      const html = `
        <!DOCTYPE html>
        <html>
        <head>
          <title>Admin - Đăng Thông Báo</title>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            body { font-family: sans-serif; padding: 20px; max-width: 500px; margin: auto; background: #f4f4f9; }
            h2 { color: #333; }
            input, textarea, button { width: 100%; margin-bottom: 15px; padding: 10px; font-size: 16px; border: 1px solid #ccc; border-radius: 5px; box-sizing: border-box; }
            button { background: #007bff; color: white; border: none; cursor: pointer; font-weight: bold; }
            button:hover { background: #0056b3; }
          </style>
        </head>
        <body>
          <h2>Đăng Thông Báo Cho App</h2>
          <form id="notifyForm">
            <label>Mật khẩu Admin:</label>
            <input type="password" id="password" required>
            <label>Tiêu đề thông báo:</label>
            <input type="text" id="title" required>
            <label>Nội dung thông báo (Để trống nếu muốn tắt thông báo):</label>
            <textarea id="message" rows="5"></textarea>
            <button type="submit">Cập Nhật Thông Báo</button>
          </form>
          <script>
            document.getElementById('notifyForm').addEventListener('submit', async (e) => {
              e.preventDefault();
              const password = document.getElementById('password').value;
              const title = document.getElementById('title').value;
              const message = document.getElementById('message').value;
              
              const res = await fetch('/admin', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ password, title, message })
              });
              const result = await res.json();
              alert(result.status || result.error);
            });
          </script>
        </body>
        </html>
      `;
      return new Response(html, { headers: { "Content-Type": "text/html;charset=UTF-8" } });
    }

    // Xử lý khi Admin bấm nút Cập nhật
    if (url.pathname === "/admin" && request.method === "POST") {
      try {
        const body = await request.json();
        // MẬT KHẨU ADMIN (Bạn có thể đổi mật khẩu ở đây)
        if (body.password !== "admin123") {
          return new Response(JSON.stringify({ error: "Sai mật khẩu!" }), { status: 401 });
        }

        const notificationData = {
          title: body.title || "Thông Báo",
          message: body.message || "",
          timestamp: Date.now()
        };

        // Lưu vào Cloudflare KV có tên là NOTIFICATIONS
        await env.NOTIFICATIONS.put("latest", JSON.stringify(notificationData));

        return new Response(JSON.stringify({ status: "Đã cập nhật thông báo thành công!" }), {
          headers: { "Content-Type": "application/json" }
        });
      } catch (e) {
        return new Response(JSON.stringify({ error: "Lỗi xử lý" }), { status: 500 });
      }
    }

    // API để App iOS lấy thông báo
    if (url.pathname === "/api/get-notification" && request.method === "GET") {
      const data = await env.NOTIFICATIONS.get("latest");
      if (data) {
        return new Response(data, {
          headers: { "Content-Type": "application/json" }
        });
      } else {
        return new Response(JSON.stringify({ title: "", message: "", timestamp: 0 }), {
          headers: { "Content-Type": "application/json" }
        });
      }
    }

    return new Response("Not found", { status: 404 });
  }
};
