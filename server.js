const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// 🔗 LINK DISCORD WEBHOOK CỦA BẠN ĐÃ ĐƯỢC GẮN VÀO ĐÂY
const DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1553331523300630549/FwKvG9WxIdwmDeg4cAqTqJ4SRtQdhIz8Gz-dD9Rdz8Q6TjnoigyQ6cEEdL_cXte0_wuE";

let currentAdminKey = "";
const scriptStorage = new Map();

app.use(express.json());

// Hàm tạo chuỗi ngẫu nhiên đúng 20 ký tự (Chữ hoa, chữ thường và số)
function generate20CharKey() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < 20; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
}

// Hàm gửi mật khẩu mới về Discord Webhook
async function sendKeyToDiscord(newKey) {
    try {
        await fetch(DISCORD_WEBHOOK_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                embeds: [{
                    title: "🔑 Mật Khẩu Admin 20 Ký Tự Mới",
                    description: `Mật khẩu mới cho hôm nay là:\n\`\`\`${newKey}\`\`\`\n*Mật khẩu này sẽ tự động đổi sau 24 giờ.*`,
                    color: 65280, // Màu xanh lá
                    timestamp: new Date().toISOString()
                }]
            })
        });
        console.log("Đã gửi mật khẩu 20 ký tự tới Discord!");
    } catch (error) {
        console.error("Lỗi gửi Discord Webhook:", error);
    }
}

// Hàm xoay vòng mật khẩu
function rotateAdminKey() {
    currentAdminKey = generate20CharKey();
    console.log(`[${new Date().toLocaleTimeString()}] Mật khẩu mới (20 ký tự): ${currentAdminKey}`);
    sendKeyToDiscord(currentAdminKey);
}

// Khởi tạo mã lần đầu khi chạy server
rotateAdminKey();

// Tự động đổi mã mỗi 24 giờ (24h * 60p * 60s * 1000ms)
setInterval(rotateAdminKey, 24 * 60 * 60 * 1000);

// GIAO DIỆN WEB HTML
app.get('/', (req, res) => {
    res.send(`
    <!DOCTYPE html>
    <html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Web Loadstring Roblox Private</title>
        <style>
            body { font-family: Arial, sans-serif; background: #121212; color: #fff; margin: 0; padding: 20px; }
            .container { max-width: 600px; margin: 0 auto; background: #1e1e1e; padding: 20px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.5); }
            h2 { color: #00ff88; margin-bottom: 15px; text-align: center; }
            label { font-weight: bold; margin-top: 10px; display: block; color: #bbb; }
            input[type="password"] { width: 100%; padding: 10px; margin-top: 5px; margin-bottom: 15px; background: #0d0d0d; color: #fff; border: 1px solid #333; border-radius: 5px; box-sizing: border-box; }
            textarea { width: 100%; height: 230px; background: #0d0d0d; color: #00ff00; border: 1px solid #333; border-radius: 5px; padding: 10px; box-sizing: border-box; font-family: monospace; font-size: 13px; }
            button { background: #008cff; color: white; border: none; padding: 12px; font-size: 16px; font-weight: bold; border-radius: 5px; cursor: pointer; width: 100%; margin-top: 10px; }
            button:hover { background: #0066cc; }
            .result { margin-top: 20px; word-break: break-all; background: #2a2a2a; padding: 15px; border-radius: 5px; display: none; }
            code { color: #ffcc00; font-family: monospace; display: block; background: #111; padding: 10px; border-radius: 5px; margin-top: 5px; font-size: 13px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h2>Hệ Thống Loadstring (Key 20 Ký Tự)</h2>
            
            <label>Mật Khẩu Admin (20 Ký Tự):</label>
            <input type="password" id="adminKeyInput" placeholder="Nhập mã 20 ký tự gửi từ Discord..." />

            <label>Nội Dung Code Lua:</label>
            <textarea id="scriptInput" placeholder="Dán code Lua vào đây..."></textarea>
            
            <button onclick="createLink()">Tạo Link Raw</button>

            <div id="resultBox" class="result">
                <p><b>Link Raw:</b> <a id="rawLink" href="#" target="_blank" style="color: #00ff88;"></a></p>
                <p><b>Lệnh Roblox Lua:</b></p>
                <code id="robloxCode"></code>
            </div>
        </div>

        <script>
            async function createLink() {
                const key = document.getElementById('adminKeyInput').value.trim();
                const code = document.getElementById('scriptInput').value;

                if (!key) return alert("Vui lòng nhập Mật Khẩu Admin (20 ký tự)!");
                if (!code.trim()) return alert("Vui lòng dán code Lua!");

                const res = await fetch('/api/save', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ key, code })
                });

                const data = await res.json();
                
                if (res.status !== 200) {
                    return alert(data.error || "Lỗi không xác định!");
                }

                document.getElementById('resultBox').style.display = 'block';
                document.getElementById('rawLink').href = data.url;
                document.getElementById('rawLink').innerText = data.url;
                document.getElementById('robloxCode').innerText = \`loadstring(game:HttpGet("\${data.url}"))()\`;
            }
        </script>
    </body>
    </html>
    `);
});

// API LƯU SCRIPT DÀNH CHO ADMIN
app.post('/api/save', (req, res) => {
    const { key, code } = req.body;

    if (key !== currentAdminKey) {
        return res.status(403).json({ error: '❌ Sai mật khẩu! Hãy lấy mã 20 ký tự mới nhất trong Discord.' });
    }

    if (!code) {
        return res.status(400).json({ error: '❌ Thiếu nội dung script!' });
    }

    const id = generate20CharKey();
    scriptStorage.set(id, code);

    const protocol = req.headers['x-forwarded-proto'] || req.protocol;
    const fullUrl = `${protocol}://${req.get('host')}/raw/${id}`;
    
    res.json({ url: fullUrl });
});

// TRẢ VỀ TEXT/PLAIN CHO ROBLOX LUA
app.get('/raw/:id', (req, res) => {
    const id = req.params.id;
    const script = scriptStorage.get(id);

    if (!script) {
        return res.status(404).type('text/plain').send('-- Lỗi: Script không tồn tại hoặc đã bị xóa!');
    }

    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.send(script);
});

app.listen(PORT, () => console.log(`Server đang chạy ở cổng ${PORT}`));
