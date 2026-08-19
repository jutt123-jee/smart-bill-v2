<!DOCTYPE html>
<html lang="ur" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Smart Meter App</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    :root {
      --primary: #00695c;
      --primary-dark: #004d40;
      --accent: #ffa000;
      --bg: #f5f7fa;
      --card: #ffffff;
      --text: #333333;
    }

    * { box-sizing: border-box; }
    body {
      font-family: system-ui, -apple-system, sans-serif;
      background: var(--bg);
      color: var(--text);
      margin: 0;
      padding-bottom: 90px;
      direction: rtl;
    }

    /* Top Bar Header */
    .app-bar {
      background: var(--primary-dark);
      color: white;
      padding: 12px 15px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      box-shadow: 0 2px 6px rgba(0,0,0,0.2);
      position: sticky;
      top: 0;
      z-index: 100;
    }

    .app-bar-left { display: flex; align-items: center; gap: 12px; }
    .icon-btn { background: none; border: none; color: white; font-size: 18px; cursor: pointer; }

    select.meter-dropdown {
      background: var(--primary);
      color: white;
      border: 1px solid rgba(255,255,255,0.3);
      padding: 6px 10px;
      border-radius: 6px;
      font-size: 14px;
      font-weight: bold;
    }

    /* Side Drawer Menu */
    .drawer-overlay {
      position: fixed; top: 0; bottom: 0; left: 0; right: 0;
      background: rgba(0,0,0,0.5); display: none; z-index: 200;
    }
    .drawer {
      position: fixed; top: 0; bottom: 0; right: -280px; width: 280px;
      background: white; transition: right 0.3s ease; z-index: 201;
      box-shadow: -2px 0 10px rgba(0,0,0,0.2);
    }
    .drawer.open { right: 0; }
    .drawer-header { background: var(--primary-dark); color: white; padding: 20px 15px; }
    .drawer-menu { list-style: none; padding: 0; margin: 0; }
    .drawer-menu li {
      padding: 12px 18px; border-bottom: 1px solid #eee; display: flex; align-items: center; gap: 12px; font-size: 13px; cursor: pointer;
    }

    /* Main Content Containers */
    .container { padding: 15px; max-width: 500px; margin: 0 auto; }
    .tab-view { display: none; }
    .tab-view.active { display: block; }

    /* Banner & Cards */
    .smart-banner {
      background: #fff8e1; border: 1px solid #ffe082; color: #8c6b00;
      padding: 12px; border-radius: 10px; display: flex; align-items: center; gap: 10px; font-size: 12px; font-weight: bold; margin-bottom: 15px;
    }
    .card {
      background: var(--card); border-radius: 12px; padding: 16px; margin-bottom: 15px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.05); border: 1px solid #e0e0e0;
    }
    .balance-header { display: flex; justify-content: space-between; font-size: 12px; color: #666; margin-bottom: 10px; }
    .balance-amount { font-size: 26px; font-weight: bold; color: #2e7d32; text-align: center; margin: 8px 0; }

    .meter-card {
      display: flex; align-items: center; justify-content: space-between;
      padding: 12px; border-radius: 10px; border: 1px solid #eee; margin-bottom: 10px; background: white;
    }
    .meter-info { display: flex; align-items: center; gap: 10px; }
    .meter-icon { width: 36px; height: 36px; border-radius: 50%; background: #e0f2f1; color: var(--primary); display: flex; align-items: center; justify-content: center; }

    /* Floating Action Button */
    .fab {
      position: fixed; bottom: 70px; left: 15px;
      background: var(--accent); color: black; border: none; padding: 12px 18px;
      border-radius: 25px; font-weight: bold; display: flex; align-items: center; gap: 8px;
      box-shadow: 0 4px 10px rgba(0,0,0,0.2); cursor: pointer; z-index: 90;
    }

    /* Navigation Bar */
    .nav-bar {
      position: fixed; bottom: 0; left: 0; right: 0;
      background: white; display: flex; justify-content: space-around;
      padding: 8px 0; border-top: 1px solid #ddd; z-index: 100;
    }
    .nav-item { text-align: center; font-size: 10px; color: #777; cursor: pointer; flex: 1; }
    .nav-item.active { color: var(--primary); font-weight: bold; }
    .nav-item i { font-size: 18px; margin-bottom: 3px; display: block; }
  </style>
</head>
<body>

  <!-- Top App Bar -->
  <div class="app-bar">
    <div class="app-bar-left">
      <button class="icon-btn" onclick="toggleDrawer()"><i class="fa-solid fa-bars"></i></button>
      <select class="meter-dropdown" id="meterFilter" onchange="filterMeters()">
        <option value="all">All Meters</option>
        <option value="meter1">Meter 1 (Ground Floor)</option>
        <option value="meter2">Meter 2 (Upper Floor)</option>
        <option value="meter3">Meter 3 (Motor/Heavy)</option>
        <option value="gas">Gas Meter</option>
      </select>
    </div>
    <button class="icon-btn"><i class="fa-solid fa-bell" style="color:#ffe082;"></i></button>
  </div>

  <!-- Side Drawer Menu -->
  <div class="drawer-overlay" id="drawerOverlay" onclick="toggleDrawer()"></div>
  <div class="drawer" id="sideDrawer">
    <div class="drawer-header">
      <h3 style="margin:0; font-size:16px;">Smart Meter Control</h3>
      <small style="color:#ffe082;" id="selectedFilterText">Selected: All Meters</small>
    </div>
    <ul class="drawer-menu">
      <li onclick="alert('01. Export & Reports')"><i class="fa-solid fa-file-arrow-down"></i> 01. Export & Reports (ڈیٹا ڈاؤن لوڈ)</li>
      <li onclick="alert('02. Voice Alerts')"><i class="fa-solid fa-bullhorn"></i> 02. Voice Alerts (وائس سیٹنگ)</li>
      <li onclick="alert('03. Meter Names')"><i class="fa-solid fa-pen-to-square"></i> 03. Meter Names (نام تبدیل کریں)</li>
      <li onclick="alert('04. Due Dates')"><i class="fa-solid fa-calendar-check"></i> 04. Bill Expire & Due Dates</li>
      <li onclick="alert('05. Tariff Settings')"><i class="fa-solid fa-gear"></i> 05. Main Settings & Tariff</li>
      <li onclick="alert('06. Limit Control')"><i class="fa-solid fa-gauge-high"></i> 06. Limit & Budget Control</li>
      <li onclick="alert('07. Backup')"><i class="fa-solid fa-cloud-arrow-up"></i> 07. Backup & Restore</li>
    </ul>
  </div>

  <!-- Main Views -->
  <div class="container">
    <div id="tab-dashboard" class="tab-view active">
      <div class="smart-banner">
        <i class="fa-solid fa-lightbulb" style="font-size: 18px; color:#f57f17;"></i>
        <div>سمارٹ تجویز: میٹر 1 کے 280 یونٹس ہو چکے ہیں۔ بوجھ دوسرے میٹر پر شفٹ کریں!</div>
      </div>

      <div class="card">
        <div class="balance-header">
          <span>Total Budget: PKR 30,000</span>
          <span>Est. Bill: PKR 17,600</span>
        </div>
        <hr style="border:none; border-top:1px solid #eee;">
        <div style="text-align:center; font-size:11px; color:#777; margin-top:5px;">REMAINING BALANCE</div>
        <div class="balance-amount">PKR 12,400</div>
      </div>

      <h4 style="margin:10px 0;">Meter Status</h4>

      <div class="meter-card m-meter1">
        <div class="meter-info">
          <div class="meter-icon"><i class="fa-solid fa-bolt"></i></div>
          <div>
            <strong>Meter 1 (Ground)</strong><br>
            <small style="color:#666;">Slab Status: 280 / 300 Units</small>
          </div>
        </div>
        <div style="text-align:left;">
          <strong style="color:var(--primary);">PKR 8,200</strong><br>
          <small style="color:red; font-weight:bold;">⚠️ Limit Near</small>
        </div>
      </div>

      <div class="meter-card m-meter2">
        <div class="meter-info">
          <div class="meter-icon"><i class="fa-solid fa-bolt"></i></div>
          <div>
            <strong>Meter 2 (Upper)</strong><br>
            <small style="color:#666;">Slab Status: 140 / 300 Units</small>
          </div>
        </div>
        <div style="text-align:left;"><strong style="color:var(--primary);">PKR 4,100</strong></div>
      </div>

      <div class="meter-card m-meter3">
        <div class="meter-info">
          <div class="meter-icon"><i class="fa-solid fa-bolt"></i></div>
          <div>
            <strong>Meter 3 (Motor)</strong><br>
            <small style="color:#666;">Slab Status: 190 / 300 Units</small>
          </div>
        </div>
        <div style="text-align:left;"><strong style="color:var(--primary);">PKR 5,300</strong></div>
      </div>

      <div class="meter-card m-gas">
        <div class="meter-info">
          <div class="meter-icon" style="background:#fbe9e7; color:#d84315;"><i class="fa-solid fa-fire"></i></div>
          <div>
            <strong>Gas Meter</strong><br>
            <small style="color:#666;">Slab Status: 1.2 Hm3 (Slab 1)</small>
          </div>
        </div>
        <div style="text-align:left;"><strong style="color:var(--primary);">PKR 1,200</strong></div>
      </div>
    </div>

    <div id="tab-electricity" class="tab-view"><div class="card"><h3>⚡ Electricity Meters Detail</h3></div></div>
    <div id="tab-gas" class="tab-view"><div class="card"><h3>🔥 Gas Meter Detail</h3></div></div>
    <div id="tab-analytics" class="tab-view"><div class="card"><h3>📊 Analytics & History</h3></div></div>
    <div id="tab-alerts" class="tab-view"><div class="card"><h3>🔔 Active Alerts</h3></div></div>
  </div>

  <!-- Floating Action Button -->
  <button class="fab" onclick="showQuickReading()"><i class="fa-solid fa-camera"></i> ➕ Quick Reading</button>

  <!-- Bottom Nav -->
  <div class="nav-bar">
    <div class="nav-item active" onclick="switchTab('dashboard', this)"><i class="fa-solid fa-chart-pie"></i>Dashboard</div>
    <div class="nav-item" onclick="switchTab('electricity', this)"><i class="fa-solid fa-bolt"></i>Electricity</div>
    <div class="nav-item" onclick="switchTab('gas', this)"><i class="fa-solid fa-fire"></i>Gas Meter</div>
    <div class="nav-item" onclick="switchTab('analytics', this)"><i class="fa-solid fa-chart-line"></i>Analytics</div>
    <div class="nav-item" onclick="switchTab('alerts', this)"><i class="fa-solid fa-bell"></i>Alerts</div>
  </div>

  <script>
    function toggleDrawer() {
      document.getElementById('sideDrawer').classList.toggle('open');
      let overlay = document.getElementById('drawerOverlay');
      overlay.style.display = overlay.style.display === 'block' ? 'none' : 'block';
    }

    function switchTab(tabId, el) {
      document.querySelectorAll('.tab-view').forEach(t => t.classList.remove('active'));
      document.querySelectorAll('.nav-item').forEach(i => i.classList.remove('active'));
      document.getElementById('tab-' + tabId).classList.add('active');
      el.classList.add('active');
    }

    function filterMeters() {
      let val = document.getElementById('meterFilter').value;
      document.getElementById('selectedFilterText').innerText = 'Selected: ' + val;
      let cards = document.querySelectorAll('.meter-card');
      cards.forEach(c => {
        if(val === 'all' || c.classList.contains('m-' + val)) {
          c.style.display = 'flex';
        } else {
          c.style.display = 'none';
        }
      });
    }

    function showQuickReading() {
      let val = prompt("Enter Current Reading Value:");
      if(val) alert("ریڈنگ کامیابی سے محفوظ کر لی گئی ہے: " + val);
    }

    // Offline Cache Logic
    if ('serviceWorker' in navigator) {
      window.addEventListener('load', () => {
        const swCode = `
          self.addEventListener('install', e => e.waitUntil(caches.open('app-cache').then(c => c.addAll(['/']))));
          self.addEventListener('fetch', e => e.respondWith(caches.match(e.request).then(r => r || fetch(e.request))));
        `;
        const blob = new Blob([swCode], { type: 'text/javascript' });
        navigator.serviceWorker.register(URL.createObjectURL(blob));
      });
    }
  </script>
</body>
</html>
