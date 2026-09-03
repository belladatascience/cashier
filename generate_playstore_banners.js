const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const outDir = path.join(__dirname, 'playstore_graphics');
if (!fs.existsSync(outDir)) {
  fs.mkdirSync(outDir, { recursive: true });
}

const imgDir = path.join(__dirname, 'assets', 'images');
function getB64(filename) {
  const p = path.join(imgDir, filename);
  if (!fs.existsSync(p)) return '';
  const ext = path.extname(filename).toLowerCase().replace('.', '');
  const mime = ext === 'png' ? 'image/png' : ext === 'webp' ? 'image/webp' : 'image/jpeg';
  return `data:${mime};base64,` + fs.readFileSync(p).toString('base64');
}

const logoBGA = getB64('logobellacashier.png');
const cartoonLogo = getB64('cartoon_logo.jpg');
const drinkLatte = getB64('drink_latte.jpg');
const drinkMatcha = getB64('drink_matcha.jpg');
const dessertCheesecake = getB64('dessert_cheesecake.jpg');
const foodCroissant = getB64('food_croissant.jpg');
const foodSourdough = getB64('food_sourdough.jpg');
const snackTahu = getB64('snack_tahucabegaram.jpg');
const foodBurger = getB64('food_burger.jpg');
const iceCaramel = getB64('Ice Caramel Machiato.jpg');

const chromePath = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

const baseStyle = `
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 1024px;
    height: 500px;
    overflow: hidden;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    background: radial-gradient(circle at 85% 15%, #3d2319 0%, #24120B 60%, #150A06 100%);
    color: #FFFFFF;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 48px;
    -webkit-font-smoothing: antialiased;
  }
  .bg-glow {
    position: absolute;
    width: 450px;
    height: 450px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(240, 189, 139, 0.18) 0%, rgba(125, 86, 45, 0) 70%);
    top: -100px;
    right: 150px;
    pointer-events: none;
    z-index: 0;
  }
  .bg-glow-2 {
    position: absolute;
    width: 350px;
    height: 350px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(200, 140, 80, 0.12) 0%, rgba(44, 22, 14, 0) 70%);
    bottom: -80px;
    left: 20px;
    pointer-events: none;
    z-index: 0;
  }
  .left-col {
    position: relative;
    z-index: 2;
    width: 490px;
    display: flex;
    flex-direction: column;
    gap: 14px;
  }
  .brand-bar {
    display: flex;
    align-items: center;
    gap: 12px;
  }
  .brand-logo-img {
    width: 46px;
    height: 46px;
    border-radius: 12px;
    object-fit: cover;
    box-shadow: 0 4px 14px rgba(0,0,0,0.4);
    border: 1.5px solid rgba(240,189,139,0.5);
  }
  .pill-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 14px;
    background: rgba(125, 86, 45, 0.45);
    border: 1px solid rgba(240, 189, 139, 0.5);
    border-radius: 20px;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.8px;
    text-transform: uppercase;
    color: #F0BD8B;
    backdrop-filter: blur(8px);
  }
  .headline {
    font-size: 34px;
    font-weight: 800;
    line-height: 1.18;
    color: #FFFFFF;
    text-shadow: 0 2px 10px rgba(0,0,0,0.5);
  }
  .headline span {
    background: linear-gradient(135deg, #F0BD8B 0%, #D89C63 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }
  .subtitle {
    font-size: 14.5px;
    line-height: 1.5;
    color: #D6C8BF;
    font-weight: 400;
  }
  .features-pills {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-top: 6px;
  }
  .feature-tag {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: rgba(255, 255, 255, 0.08);
    border: 1px solid rgba(255, 255, 255, 0.15);
    border-radius: 8px;
    padding: 6px 12px;
    font-size: 11.5px;
    color: #FAF7F2;
    font-weight: 500;
  }
  .feature-tag .dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: #F0BD8B;
  }
  .right-col {
    position: relative;
    z-index: 2;
    width: 440px;
    height: 440px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .phone-mockup {
    width: 280px;
    height: 420px;
    background: #1C1512;
    border: 8px solid #33221A;
    border-radius: 36px;
    box-shadow: 0 24px 48px rgba(0,0,0,0.7), 0 0 0 1px rgba(240,189,139,0.3);
    overflow: hidden;
    position: relative;
    display: flex;
    flex-direction: column;
  }
  .phone-header {
    background: #2C160E;
    padding: 10px 14px 8px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid rgba(240,189,139,0.15);
  }
  .phone-header-title {
    font-size: 12px;
    font-weight: 700;
    color: #F0BD8B;
  }
  .phone-content {
    flex: 1;
    background: #FAF7F2;
    color: #2C160E;
    padding: 12px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
`;

const banners = [
  // ==========================================
  // BANNER 1: HERO / BRAND OVERVIEW
  // ==========================================
  {
    filename: 'banner_1_hero_bga_cashier.png',
    html: `
      <!DOCTYPE html><html><head><style>${baseStyle}
        .hero-preview {
          width: 410px;
          height: 380px;
          background: rgba(44, 22, 14, 0.7);
          border: 1px solid rgba(240, 189, 139, 0.35);
          border-radius: 24px;
          padding: 20px;
          box-shadow: 0 20px 40px rgba(0,0,0,0.6);
          backdrop-filter: blur(12px);
          display: flex;
          flex-direction: column;
          justify-content: space-between;
        }
        .hero-top {
          display: flex;
          gap: 16px;
          align-items: center;
        }
        .mascot-box {
          width: 90px;
          height: 90px;
          border-radius: 18px;
          overflow: hidden;
          border: 2px solid #F0BD8B;
          box-shadow: 0 8px 16px rgba(0,0,0,0.5);
          flex-shrink: 0;
        }
        .mascot-box img { width: 100%; height: 100%; object-fit: cover; }
        .hero-card-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 10px;
          margin-top: 10px;
        }
        .stat-card {
          background: rgba(255,255,255,0.06);
          border: 1px solid rgba(255,255,255,0.12);
          border-radius: 14px;
          padding: 12px;
        }
        .stat-label { font-size: 11px; color: #D6C8BF; margin-bottom: 4px; }
        .stat-value { font-size: 17px; font-weight: 800; color: #F0BD8B; }
        .hero-footer-bar {
          background: rgba(125, 86, 45, 0.35);
          border: 1px solid rgba(240, 189, 139, 0.25);
          border-radius: 12px;
          padding: 8px 14px;
          display: flex;
          align-items: center;
          justify-content: space-between;
          font-size: 11.5px;
          color: #FAF7F2;
        }
      </style></head>
      <body>
        <div class="bg-glow"></div><div class="bg-glow-2"></div>
        <div class="left-col">
          <div class="brand-bar">
            <img class="brand-logo-img" src="${logoBGA || cartoonLogo}" />
            <div class="pill-badge">☕ Project Cashier Latte</div>
          </div>
          <h1 class="headline">Sistem Kasir Modern <span>BGA Co. Cashier</span></h1>
          <p class="subtitle">Solusi Point of Sale (POS) F&B, Kafe & Coffee Shop terpadu karya <strong>Bella Gita Asmara, S.E., M.M.</strong> Dirancang cepat, praktis, dan estetik.</p>
          <div class="features-pills">
            <div class="feature-tag"><span class="dot"></span> 100% Offline SQLite</div>
            <div class="feature-tag"><span class="dot"></span> Transaksi Cepat & Praktis</div>
            <div class="feature-tag"><span class="dot"></span> Rekap Penjualan Akurat</div>
            <div class="feature-tag"><span class="dot"></span> Multi-Theme Latte</div>
          </div>
        </div>
        <div class="right-col">
          <div class="hero-preview">
            <div class="hero-top">
              <div class="mascot-box">
                <img src="${cartoonLogo || logoBGA}" />
              </div>
              <div>
                <div style="font-size: 19px; font-weight: 800; color: #FFFFFF; font-family: Georgia, serif;">Bella Cafe & POS</div>
                <div style="font-size: 12px; color: #F0BD8B; margin-top: 2px;">Cabang Utama Jakarta • Shift Pagi</div>
                <div style="font-size: 11px; color: #A89587; margin-top: 4px;">"Making small businesses easier to manage."</div>
              </div>
            </div>
            <div class="hero-card-grid">
              <div class="stat-card">
                <div class="stat-label">Omzet Hari Ini</div>
                <div class="stat-value">Rp 1.485.000</div>
              </div>
              <div class="stat-card">
                <div class="stat-label">Total Transaksi</div>
                <div class="stat-value">48 Pesanan</div>
              </div>
              <div class="stat-card">
                <div class="stat-label">Menu Terlaris</div>
                <div class="stat-value" style="font-size:14px; color:#FFFFFF;">Classic Cafe Latte</div>
              </div>
              <div class="stat-card">
                <div class="stat-label">Status Sistem</div>
                <div class="stat-value" style="font-size:14px; color:#68D391;">● Aktif & Stabil</div>
              </div>
            </div>
            <div class="hero-footer-bar">
              <span>BGA Co. Cashier V1.2.4</span>
              <span style="color:#F0BD8B; font-weight:700;">Material 3 • SQLite</span>
            </div>
          </div>
        </div>
      </body></html>
    `
  },

  // ==========================================
  // BANNER 2: F&B MENU CATALOG MANAGEMENT
  // ==========================================
  {
    filename: 'banner_2_menu_catalog.png',
    html: `
      <!DOCTYPE html><html><head><style>${baseStyle}
        .catalog-grid {
          width: 420px;
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 12px;
        }
        .menu-card {
          background: #FFFFFF;
          border-radius: 16px;
          overflow: hidden;
          box-shadow: 0 10px 24px rgba(0,0,0,0.4);
          display: flex;
          flex-direction: column;
        }
        .menu-thumb {
          width: 100%;
          height: 105px;
          object-fit: cover;
        }
        .menu-info {
          padding: 10px 12px;
          background: #FFFFFF;
        }
        .menu-name { font-size: 13px; font-weight: 700; color: #2C160E; }
        .menu-cat { font-size: 10.5px; color: #7D562D; margin-top: 2px; }
        .menu-price-row {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-top: 6px;
        }
        .menu-price { font-size: 13px; font-weight: 800; color: #B76E28; }
        .add-btn {
          background: #7D562D;
          color: white;
          width: 24px;
          height: 24px;
          border-radius: 6px;
          display: flex;
          align-items: center;
          justify-content: center;
          font-weight: bold;
          font-size: 14px;
        }
      </style></head>
      <body>
        <div class="bg-glow"></div>
        <div class="left-col">
          <div class="brand-bar">
            <img class="brand-logo-img" src="${logoBGA || cartoonLogo}" />
            <div class="pill-badge">☕ Katalog Menu F&B</div>
          </div>
          <h1 class="headline">Katalog Menu & Produk <span>Lengkap & Praktis</span></h1>
          <p class="subtitle">Kelola puluhan varian menu minuman kopi, hidangan utama, pastry, bakery, hingga camilan favorit dengan foto yang menggugah selera.</p>
          <div class="features-pills">
            <div class="feature-tag"><span class="dot"></span> Coffee & Non-Coffee</div>
            <div class="feature-tag"><span class="dot"></span> Pastry & Sourdough Bakery</div>
            <div class="feature-tag"><span class="dot"></span> Snack & Indonesian Bites</div>
            <div class="feature-tag"><span class="dot"></span> Update Harga Real-Time</div>
          </div>
        </div>
        <div class="right-col">
          <div class="catalog-grid">
            <div class="menu-card">
              <img class="menu-thumb" src="${drinkLatte}" />
              <div class="menu-info">
                <div class="menu-name">Classic Cafe Latte</div>
                <div class="menu-cat">Coffee • Hot / Ice</div>
                <div class="menu-price-row">
                  <span class="menu-price">Rp 32.000</span>
                  <div class="add-btn">+</div>
                </div>
              </div>
            </div>
            <div class="menu-card">
              <img class="menu-thumb" src="${drinkMatcha}" />
              <div class="menu-info">
                <div class="menu-name">Artisan Matcha Latte</div>
                <div class="menu-cat">Non-Coffee • Special</div>
                <div class="menu-price-row">
                  <span class="menu-price">Rp 35.000</span>
                  <div class="add-btn">+</div>
                </div>
              </div>
            </div>
            <div class="menu-card">
              <img class="menu-thumb" src="${foodCroissant}" />
              <div class="menu-info">
                <div class="menu-name">Butter Croissant</div>
                <div class="menu-cat">Bakery • Fresh Baked</div>
                <div class="menu-price-row">
                  <span class="menu-price">Rp 28.000</span>
                  <div class="add-btn">+</div>
                </div>
              </div>
            </div>
            <div class="menu-card">
              <img class="menu-thumb" src="${dessertCheesecake}" />
              <div class="menu-info">
                <div class="menu-name">Berry Cheesecake</div>
                <div class="menu-cat">Dessert • Artisan Cake</div>
                <div class="menu-price-row">
                  <span class="menu-price">Rp 28.000</span>
                  <div class="add-btn">+</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </body></html>
    `
  },

  // ==========================================
  // BANNER 3: FAST POS CHECKOUT & CART
  // ==========================================
  {
    filename: 'banner_3_pos_checkout.png',
    html: `
      <!DOCTYPE html><html><head><style>${baseStyle}
        .cart-card {
          width: 380px;
          background: #FFFFFF;
          border-radius: 22px;
          box-shadow: 0 20px 44px rgba(0,0,0,0.6);
          overflow: hidden;
          color: #2C160E;
        }
        .cart-head {
          background: #2C160E;
          color: #FFFFFF;
          padding: 16px 20px;
          display: flex;
          justify-content: space-between;
          align-items: center;
        }
        .cart-body { padding: 16px 20px; display: flex; flex-direction: column; gap: 10px; }
        .cart-item {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding-bottom: 8px;
          border-bottom: 1px dashed #E2D7CC;
        }
        .cart-item-name { font-size: 13px; font-weight: 700; color: #2C160E; }
        .cart-item-sub { font-size: 11px; color: #7D562D; }
        .cart-calc-row {
          display: flex;
          justify-content: space-between;
          font-size: 12.5px;
          color: #6B5E59;
          margin-top: 2px;
        }
        .cart-total-row {
          display: flex;
          justify-content: space-between;
          font-size: 16px;
          font-weight: 800;
          color: #2C160E;
          padding-top: 8px;
          border-top: 2px solid #2C160E;
        }
        .pay-now-btn {
          background: linear-gradient(135deg, #7D562D 0%, #442A22 100%);
          color: #FFFFFF;
          font-weight: 700;
          font-size: 14px;
          text-align: center;
          padding: 12px;
          border-radius: 12px;
          margin-top: 10px;
          box-shadow: 0 6px 14px rgba(68,42,34,0.35);
        }
      </style></head>
      <body>
        <div class="bg-glow"></div>
        <div class="left-col">
          <div class="brand-bar">
            <img class="brand-logo-img" src="${logoBGA || cartoonLogo}" />
            <div class="pill-badge">⚡ Kasir POS Cepat</div>
          </div>
          <h1 class="headline">Transaksi Kilat <span>Tanpa Antrean Panjang</span></h1>
          <p class="subtitle">Perhitungan pesanan otomatis dengan akurasi tinggi: subtotal belanja, kalkulasi PPN 10%, serta fleksibilitas pesanan Dine In atau Take Away.</p>
          <div class="features-pills">
            <div class="feature-tag"><span class="dot"></span> Kalkulasi PPN 10% Otomatis</div>
            <div class="feature-tag"><span class="dot"></span> Opsi Dine In / Take Away</div>
            <div class="feature-tag"><span class="dot"></span> Tambah & Hapus Item Cepat</div>
            <div class="feature-tag"><span class="dot"></span> Antarmuka Ramah Kasir</div>
          </div>
        </div>
        <div class="right-col">
          <div class="cart-card">
            <div class="cart-head">
              <div>
                <div style="font-weight:800; font-size:15px; color:#F0BD8B;">Keranjang Pesanan</div>
                <div style="font-size:11px; opacity:0.8;">Pelanggan: Handky Chang • Meja 04</div>
              </div>
              <span style="background:#7D562D; font-size:11px; padding:4px 8px; border-radius:6px;">Dine In</span>
            </div>
            <div class="cart-body">
              <div class="cart-item">
                <div>
                  <div class="cart-item-name">2x Artisan Matcha Latte</div>
                  <div class="cart-item-sub">@ Rp 35.000 • Less Sugar</div>
                </div>
                <div style="font-weight:700; font-size:13px;">Rp 70.000</div>
              </div>
              <div class="cart-item">
                <div>
                  <div class="cart-item-name">1x Berry Cheesecake</div>
                  <div class="cart-item-sub">@ Rp 28.000 • Slice</div>
                </div>
                <div style="font-weight:700; font-size:13px;">Rp 28.000</div>
              </div>
              <div class="cart-calc-row">
                <span>Subtotal (3 item)</span>
                <span>Rp 98.000</span>
              </div>
              <div class="cart-calc-row">
                <span>Pajak Restoran (PPN 10%)</span>
                <span>Rp 9.800</span>
              </div>
              <div class="cart-total-row">
                <span>Total Tagihan</span>
                <span style="color:#7D562D;">Rp 107.800</span>
              </div>
              <div class="pay-now-btn">Proses Pembayaran Kasir →</div>
            </div>
          </div>
        </div>
      </body></html>
    `
  },

  // ==========================================
  // BANNER 4: QRIS & MULTI-PAYMENT
  // ==========================================
  {
    filename: 'banner_4_smart_payment.png',
    html: `
      <!DOCTYPE html><html><head><style>${baseStyle}
        .pay-modal {
          width: 390px;
          background: #FFFFFF;
          border-radius: 22px;
          box-shadow: 0 20px 44px rgba(0,0,0,0.6);
          padding: 20px;
          color: #2C160E;
          display: flex;
          flex-direction: column;
          align-items: center;
          text-align: center;
        }
        .qris-header {
          font-size: 15px;
          font-weight: 800;
          color: #2C160E;
        }
        .qris-badge {
          background: #C62828;
          color: white;
          font-size: 11px;
          font-weight: bold;
          padding: 3px 10px;
          border-radius: 6px;
          margin-top: 4px;
        }
        .qr-placeholder {
          width: 170px;
          height: 170px;
          background: #FAF7F2;
          border: 2px dashed #7D562D;
          border-radius: 14px;
          margin: 14px 0;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          padding: 10px;
        }
        .qr-grid {
          width: 100%;
          height: 100%;
          background: repeating-linear-gradient(0deg, #2C160E, #2C160E 6px, transparent 6px, transparent 12px),
                      repeating-linear-gradient(90deg, #2C160E, #2C160E 6px, #FAF7F2 6px, #FAF7F2 12px);
          opacity: 0.85;
          border-radius: 8px;
        }
        .pay-status-pill {
          background: #E8F5E9;
          color: #1B5E20;
          font-size: 12px;
          font-weight: 700;
          padding: 6px 16px;
          border-radius: 20px;
          border: 1px solid #A5D6A7;
          display: inline-flex;
          align-items: center;
          gap: 6px;
        }
        .pay-details-table {
          width: 100%;
          margin-top: 12px;
          font-size: 12px;
          color: #6B5E59;
          display: flex;
          justify-content: space-between;
          border-top: 1px solid #EFE8DE;
          padding-top: 10px;
        }
      </style></head>
      <body>
        <div class="bg-glow"></div>
        <div class="left-col">
          <div class="brand-bar">
            <img class="brand-logo-img" src="${logoBGA || cartoonLogo}" />
            <div class="pill-badge">💳 Pembayaran Fleksibel</div>
          </div>
          <h1 class="headline">Dukungan Multi-Payment <span>QRIS & Tunai</span></h1>
          <p class="subtitle">Kemudahan menerima transaksi non-tunai melalui scan QRIS nasional, dompet digital, hingga pembayaran tunai dengan penghitung kembalian akurat.</p>
          <div class="features-pills">
            <div class="feature-tag"><span class="dot"></span> QRIS Dinamis & Cepat</div>
            <div class="feature-tag"><span class="dot"></span> Pembayaran Tunai & Kembalian</div>
            <div class="feature-tag"><span class="dot"></span> E-Wallet (GoPay, OVO, Dana)</div>
            <div class="feature-tag"><span class="dot"></span> Konfirmasi Instan "LUNAS"</div>
          </div>
        </div>
        <div class="right-col">
          <div class="pay-modal">
            <div class="qris-header">Pembayaran Non-Tunai QRIS</div>
            <div class="qris-badge">QRIS STANDAR NASIONAL</div>
            <div class="qr-placeholder">
              <div class="qr-grid"></div>
            </div>
            <div class="pay-status-pill">✔ Transaksi Berhasil: LUNAS</div>
            <div class="pay-details-table">
              <span>Metode: QRIS Digital Wallet</span>
              <span style="font-weight:800; color:#2C160E;">Rp 107.800</span>
            </div>
            <div style="font-size:11px; color:#9E8F87; margin-top:6px;">Invoice: #INV-20260821-001</div>
          </div>
        </div>
      </body></html>
    `
  },

  // ==========================================
  // BANNER 5: SALES REPORT & TRANSACTIONS
  // ==========================================
  {
    filename: 'banner_5_sales_history.png',
    html: `
      <!DOCTYPE html><html><head><style>${baseStyle}
        .history-card {
          width: 410px;
          background: #FFFFFF;
          border-radius: 20px;
          box-shadow: 0 20px 44px rgba(0,0,0,0.6);
          overflow: hidden;
          color: #2C160E;
          padding: 18px;
        }
        .history-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 12px;
          padding-bottom: 10px;
          border-bottom: 1px solid #ECE3D8;
        }
        .tx-item {
          background: #FAF7F2;
          border: 1px solid #E8DDD0;
          border-radius: 12px;
          padding: 10px 14px;
          margin-bottom: 8px;
        }
        .tx-top {
          display: flex;
          justify-content: space-between;
          font-size: 12px;
          font-weight: 700;
          color: #2C160E;
        }
        .tx-mid {
          font-size: 11px;
          color: #7D562D;
          margin-top: 3px;
        }
        .tx-bot {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-top: 6px;
          font-size: 12px;
        }
        .badge-lunas {
          background: #E8F5E9;
          color: #2E7D32;
          padding: 2px 8px;
          border-radius: 4px;
          font-size: 10px;
          font-weight: 800;
        }
      </style></head>
      <body>
        <div class="bg-glow"></div>
        <div class="left-col">
          <div class="brand-bar">
            <img class="brand-logo-img" src="${logoBGA || cartoonLogo}" />
            <div class="pill-badge">📊 Laporan & Riwayat</div>
          </div>
          <h1 class="headline">Riwayat Transaksi & <span>Laporan Omzet Rapi</span></h1>
          <p class="subtitle">Pantau seluruh catatan penjualan kasir harian secara transparan. Filter menurut tanggal, metode bayar, dan cetak invoice untuk rekap pembukuan bisnis.</p>
          <div class="features-pills">
            <div class="feature-tag"><span class="dot"></span> Detail Invoice & Item</div>
            <div class="feature-tag"><span class="dot"></span> Filter Tanggal Penjualan</div>
            <div class="feature-tag"><span class="dot"></span> Audit Omzet Akurat</div>
            <div class="feature-tag"><span class="dot"></span> Pencatatan Otomatis SQLite</div>
          </div>
        </div>
        <div class="right-col">
          <div class="history-card">
            <div class="history-header">
              <div>
                <div style="font-weight:800; font-size:15px; color:#2C160E;">Daftar Transaksi Kasir</div>
                <div style="font-size:11px; color:#7D562D;">Bulan Agustus 2026 • Kasir: Bee</div>
              </div>
              <span style="font-size:11px; background:#2C160E; color:white; padding:4px 8px; border-radius:6px;">Filter: Semua</span>
            </div>
            <div class="tx-item">
              <div class="tx-top">
                <span>#INV-20260821-001</span>
                <span class="badge-lunas">LUNAS</span>
              </div>
              <div class="tx-mid">Pelanggan: Handky Chang • 2x Matcha, 1x Cake</div>
              <div class="tx-bot">
                <span style="color:#8A7A73;">QRIS • 21 Aug, 11:45</span>
                <span style="font-weight:800; color:#7D562D;">Rp 107.800</span>
              </div>
            </div>
            <div class="tx-item">
              <div class="tx-top">
                <span>#INV-20260821-002</span>
                <span class="badge-lunas">LUNAS</span>
              </div>
              <div class="tx-mid">Pelanggan: Siti Aminah • 1x Latte, 2x Croissant</div>
              <div class="tx-bot">
                <span style="color:#8A7A73;">GoPay • 21 Aug, 10:15</span>
                <span style="font-weight:800; color:#7D562D;">Rp 96.800</span>
              </div>
            </div>
            <div class="tx-item">
              <div class="tx-top">
                <span>#INV-20260820-001</span>
                <span class="badge-lunas">LUNAS</span>
              </div>
              <div class="tx-mid">Pelanggan: Umum • 1x Sourdough, 2x Americano</div>
              <div class="tx-bot">
                <span style="color:#8A7A73;">Cash • 20 Aug, 16:30</span>
                <span style="font-weight:800; color:#7D562D;">Rp 102.300</span>
              </div>
            </div>
          </div>
        </div>
      </body></html>
    `
  },

  // ==========================================
  // BANNER 6: STAFF SHIFT MANAGEMENT
  // ==========================================
  {
    filename: 'banner_6_staff_shift.png',
    html: `
      <!DOCTYPE html><html><head><style>${baseStyle}
        .shift-card {
          width: 400px;
          background: #FFFFFF;
          border-radius: 20px;
          box-shadow: 0 20px 44px rgba(0,0,0,0.6);
          padding: 18px;
          color: #2C160E;
        }
        .staff-row {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 10px;
          background: #FAF7F2;
          border-radius: 12px;
          margin-bottom: 8px;
          border: 1px solid #EDE4D8;
        }
        .staff-avatar {
          width: 42px;
          height: 42px;
          border-radius: 10px;
          background: #7D562D;
          color: white;
          display: flex;
          align-items: center;
          justify-content: center;
          font-weight: bold;
          font-size: 15px;
          flex-shrink: 0;
        }
        .staff-info { flex: 1; }
        .staff-name { font-size: 13px; font-weight: 700; color: #2C160E; }
        .staff-role { font-size: 11px; color: #7D562D; }
        .shift-badge-pagi {
          background: #FFF3E0;
          color: #E65100;
          font-size: 10.5px;
          font-weight: 700;
          padding: 4px 10px;
          border-radius: 6px;
        }
        .shift-badge-sore {
          background: #EDE7F6;
          color: #4527A0;
          font-size: 10.5px;
          font-weight: 700;
          padding: 4px 10px;
          border-radius: 6px;
        }
      </style></head>
      <body>
        <div class="bg-glow"></div>
        <div class="left-col">
          <div class="brand-bar">
            <img class="brand-logo-img" src="${logoBGA || cartoonLogo}" />
            <div class="pill-badge">👥 Jadwal & Shift Staf</div>
          </div>
          <h1 class="headline">Manajemen Shift <span>Karyawan & Barista</span></h1>
          <p class="subtitle">Atur pembagian jam kerja shift pagi & sore dengan rapi. Pantau penugasan kasir, barista, dan staf operasional di setiap cabang kedai Anda.</p>
          <div class="features-pills">
            <div class="feature-tag"><span class="dot"></span> Shift Pagi & Sore</div>
            <div class="feature-tag"><span class="dot"></span> Manajemen Multi Cabang</div>
            <div class="feature-tag"><span class="dot"></span> Rekam Penanggung Jawab</div>
            <div class="feature-tag"><span class="dot"></span> Kalender Shift Rapi</div>
          </div>
        </div>
        <div class="right-col">
          <div class="shift-card">
            <div style="font-weight:800; font-size:15px; color:#2C160E; margin-bottom:4px;">Jadwal Shift Staf Hari Ini</div>
            <div style="font-size:11px; color:#7D562D; margin-bottom:12px;">Cabang: Bella Cafe Jakarta • 21 Agustus 2026</div>
            <div class="staff-row">
              <div class="staff-avatar">B</div>
              <div class="staff-info">
                <div class="staff-name">Bee (Bella Gita Asmara)</div>
                <div class="staff-role">Head Barista & Kasir</div>
              </div>
              <span class="shift-badge-pagi">Shift Pagi (07:00 - 15:00)</span>
            </div>
            <div class="staff-row">
              <div class="staff-avatar" style="background:#442A22;">R</div>
              <div class="staff-info">
                <div class="staff-name">Rian Pratama</div>
                <div class="staff-role">Junior Barista</div>
              </div>
              <span class="shift-badge-pagi">Shift Pagi (07:00 - 15:00)</span>
            </div>
            <div class="staff-row">
              <div class="staff-avatar" style="background:#2C160E;">D</div>
              <div class="staff-info">
                <div class="staff-name">Dina Oktavia</div>
                <div class="staff-role">Kasir Shift Siang</div>
              </div>
              <span class="shift-badge-sore">Shift Sore (15:00 - 22:00)</span>
            </div>
          </div>
        </div>
      </body></html>
    `
  },

  // ==========================================
  // BANNER 7: MULTI-THEME & CUSTOMIZATION
  // ==========================================
  {
    filename: 'banner_7_multi_themes.png',
    html: `
      <!DOCTYPE html><html><head><style>${baseStyle}
        .theme-compare {
          width: 420px;
          display: flex;
          gap: 12px;
        }
        .theme-half {
          flex: 1;
          border-radius: 18px;
          padding: 14px;
          box-shadow: 0 16px 36px rgba(0,0,0,0.5);
          display: flex;
          flex-direction: column;
          gap: 10px;
        }
        .dark-theme {
          background: #2C160E;
          border: 1px solid rgba(240, 189, 139, 0.4);
          color: #FFFFFF;
        }
        .light-theme {
          background: #FAF7F2;
          border: 1px solid #E6DACB;
          color: #2C160E;
        }
        .theme-mini-item {
          padding: 8px 10px;
          border-radius: 8px;
          font-size: 11px;
          display: flex;
          justify-content: space-between;
          align-items: center;
        }
      </style></head>
      <body>
        <div class="bg-glow"></div>
        <div class="left-col">
          <div class="brand-bar">
            <img class="brand-logo-img" src="${logoBGA || cartoonLogo}" />
            <div class="pill-badge">🎨 Kustomisasi Tema</div>
          </div>
          <h1 class="headline">Mode Espresso Dark & <span>Warm Latte Cream</span></h1>
          <p class="subtitle">Sesuaikan estetika tampilan aplikasi dengan suasana kafe Anda. Dilengkapi mode gelap untuk pencahayaan temaram dan mode terang bernuansa krim lembut.</p>
          <div class="features-pills">
            <div class="feature-tag"><span class="dot"></span> Espresso Dark Mode</div>
            <div class="feature-tag"><span class="dot"></span> Warm Latte Light Mode</div>
            <div class="feature-tag"><span class="dot"></span> Tipografi Work Sans Elegan</div>
            <div class="feature-tag"><span class="dot"></span> Desain Responsif & Halus</div>
          </div>
        </div>
        <div class="right-col">
          <div class="theme-compare">
            <div class="theme-half dark-theme">
              <div style="font-weight:800; font-size:13px; color:#F0BD8B;">☕ Dark Espresso</div>
              <div style="font-size:10px; color:#A89587;">Elegan & Nyaman di Malam Hari</div>
              <div class="theme-mini-item" style="background:#3D2015; border:1px solid #5D3E33;">
                <span>Classic Cafe Latte</span>
                <span style="color:#F0BD8B; font-weight:bold;">Rp 32.000</span>
              </div>
              <div class="theme-mini-item" style="background:#3D2015; border:1px solid #5D3E33;">
                <span>Matcha Artisan</span>
                <span style="color:#F0BD8B; font-weight:bold;">Rp 35.000</span>
              </div>
              <div style="margin-top:auto; font-size:10px; text-align:center; color:#F0BD8B; padding:6px; background:#442A22; border-radius:6px;">Aktifkan Mode Gelap</div>
            </div>
            <div class="theme-half light-theme">
              <div style="font-weight:800; font-size:13px; color:#7D562D;">🥛 Warm Cream Latte</div>
              <div style="font-size:10px; color:#6B5E59;">Cerah & Bersih di Siang Hari</div>
              <div class="theme-mini-item" style="background:#FFFFFF; border:1px solid #E6DACB;">
                <span>Butter Croissant</span>
                <span style="color:#7D562D; font-weight:bold;">Rp 28.000</span>
              </div>
              <div class="theme-mini-item" style="background:#FFFFFF; border:1px solid #E6DACB;">
                <span>Berry Cheesecake</span>
                <span style="color:#7D562D; font-weight:bold;">Rp 28.000</span>
              </div>
              <div style="margin-top:auto; font-size:10px; text-align:center; color:#FFFFFF; padding:6px; background:#7D562D; border-radius:6px;">Aktifkan Mode Terang</div>
            </div>
          </div>
        </div>
      </body></html>
    `
  },

  // ==========================================
  // BANNER 8: 100% OFFLINE-FIRST SQLITE LOCAL DB
  // ==========================================
  {
    filename: 'banner_8_offline_sqlite.png',
    html: `
      <!DOCTYPE html><html><head><style>${baseStyle}
        .offline-box {
          width: 400px;
          background: rgba(44, 22, 14, 0.75);
          border: 1px solid rgba(240, 189, 139, 0.4);
          border-radius: 24px;
          padding: 24px;
          box-shadow: 0 20px 44px rgba(0,0,0,0.6);
          backdrop-filter: blur(12px);
          display: flex;
          flex-direction: column;
          gap: 14px;
        }
        .offline-status-bar {
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 10px 14px;
          background: rgba(46, 125, 50, 0.25);
          border: 1px solid #81C784;
          border-radius: 12px;
          color: #A5D6A7;
          font-size: 12px;
          font-weight: 700;
        }
        .offline-item {
          display: flex;
          gap: 12px;
          align-items: flex-start;
          background: rgba(255,255,255,0.06);
          padding: 10px 12px;
          border-radius: 12px;
        }
        .offline-icon {
          width: 32px;
          height: 32px;
          border-radius: 8px;
          background: #7D562D;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 16px;
          flex-shrink: 0;
        }
        .offline-title { font-size: 13px; font-weight: 700; color: #FFFFFF; }
        .offline-desc { font-size: 11px; color: #D6C8BF; margin-top: 2px; }
      </style></head>
      <body>
        <div class="bg-glow"></div>
        <div class="left-col">
          <div class="brand-bar">
            <img class="brand-logo-img" src="${logoBGA || cartoonLogo}" />
            <div class="pill-badge">🔒 100% Offline-First</div>
          </div>
          <h1 class="headline">Tetap Berjalan Lancar <span>Tanpa Sinyal Internet</span></h1>
          <p class="subtitle">Didukung SQLite Local Database berkecepatan tinggi. Bebas khawatir sinyal internet padam, data transaksi kasir Anda tetap tersimpan rapi dan aman di perangkat.</p>
          <div class="features-pills">
            <div class="feature-tag"><span class="dot"></span> Tanpa Biaya Server Bulanan</div>
            <div class="feature-tag"><span class="dot"></span> Privasi Data Bisnis Terjaga</div>
            <div class="feature-tag"><span class="dot"></span> Respon Kasir Seketika (0ms Lag)</div>
            <div class="feature-tag"><span class="dot"></span> SQLite Local DB Storage</div>
          </div>
        </div>
        <div class="right-col">
          <div class="offline-box">
            <div class="offline-status-bar">
              <span style="font-size:16px;">●</span>
              <span>Mode Operasional: 100% Offline & Mandiri</span>
            </div>
            <div class="offline-item">
              <div class="offline-icon">💾</div>
              <div>
                <div class="offline-title">Basis Data SQLite Lokal</div>
                <div class="offline-desc">Semua transaksi, katalog, dan pelanggan tersimpan langsung di HP / Tablet Anda.</div>
              </div>
            </div>
            <div class="offline-item">
              <div class="offline-icon">🛡</div>
              <div>
                <div class="offline-title">Kerahasiaan Data Terjamin</div>
                <div class="offline-desc">Omzet usaha dan data penjualan tidak dibagikan atau diunggah ke pihak ketiga manapun.</div>
              </div>
            </div>
            <div class="offline-item">
              <div class="offline-icon">⚡</div>
              <div>
                <div class="offline-title">Nol Downtime</div>
                <div class="offline-desc">Kasir dapat terus melayani pelanggan tanpa terhambat internet mati atau lemot.</div>
              </div>
            </div>
          </div>
        </div>
      </body></html>
    `
  }
];

console.log('Generating 8 Play Store banners (1024x500)...');
banners.forEach((b, idx) => {
  const tempHtml = path.join(outDir, `temp_${idx}.html`);
  const outPng = path.join(outDir, b.filename);
  fs.writeFileSync(tempHtml, b.html);

  const fileUrl = 'file:///' + tempHtml.replace(/\\/g, '/');
  const cmd = `"${chromePath}" --headless=new --disable-gpu --force-device-scale-factor=1 --window-size=1024,500 --screenshot="${outPng}" "${fileUrl}"`;
  execSync(cmd);
  fs.unlinkSync(tempHtml);

  const stats = fs.statSync(outPng);
  console.log(`[${idx + 1}/8] Created: ${b.filename} (${stats.size} bytes)`);
});

console.log('All 8 Play Store banners generated successfully in:', outDir);
