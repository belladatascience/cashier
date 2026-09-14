const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const htmlContent = `<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Laporan Komprehensif Fungsi CRUD - Aplikasi Cashier Latte</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap');

    @page {
      size: A4 portrait;
      margin: 16mm 14mm 16mm 14mm;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      color: #1e293b;
      background-color: #ffffff;
      line-height: 1.5;
      font-size: 10.5pt;
      -webkit-print-color-adjust: exact;
      print-color-adjust: exact;
    }

    .page-break {
      page-break-before: always;
      break-before: page;
    }

    .avoid-break {
      page-break-inside: avoid;
      break-inside: avoid;
    }

    /* Header & Cover */
    .cover-container {
      background: linear-gradient(135deg, #1e1b18 0%, #3d271d 50%, #6f4e37 100%);
      color: #ffffff;
      padding: 30px 26px;
      border-radius: 14px;
      margin-bottom: 20px;
      position: relative;
      overflow: hidden;
      box-shadow: 0 8px 20px rgba(61, 39, 29, 0.2);
    }

    .cover-container::after {
      content: '';
      position: absolute;
      right: -30px;
      bottom: -30px;
      width: 180px;
      height: 180px;
      background: radial-gradient(circle, rgba(217, 119, 6, 0.3) 0%, transparent 70%);
      border-radius: 50%;
    }

    .badge-tag {
      display: inline-block;
      background: rgba(255, 255, 255, 0.15);
      border: 1px solid rgba(255, 255, 255, 0.3);
      padding: 3px 10px;
      border-radius: 20px;
      font-size: 8pt;
      font-weight: 600;
      letter-spacing: 0.5px;
      text-transform: uppercase;
      margin-bottom: 10px;
      color: #fde68a;
    }

    .cover-title {
      font-size: 20pt;
      font-weight: 800;
      line-height: 1.25;
      margin-bottom: 6px;
      letter-spacing: -0.5px;
    }

    .cover-subtitle {
      font-size: 10.5pt;
      font-weight: 400;
      color: #e2e8f0;
      margin-bottom: 16px;
      max-width: 95%;
    }

    .meta-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 10px;
      background: rgba(0, 0, 0, 0.25);
      padding: 10px 14px;
      border-radius: 8px;
      font-size: 8.5pt;
      border: 1px solid rgba(255, 255, 255, 0.1);
    }

    .meta-item span {
      display: block;
      color: #94a3b8;
      font-size: 7pt;
      text-transform: uppercase;
      font-weight: 600;
    }

    .meta-item strong {
      color: #ffffff;
      font-weight: 600;
    }

    /* Section Styling */
    .section-header {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-top: 18px;
      margin-bottom: 10px;
      padding-bottom: 5px;
      border-bottom: 2px solid #f1f5f9;
    }

    .section-icon {
      width: 24px;
      height: 24px;
      background: #78350f;
      color: #ffffff;
      border-radius: 6px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      font-size: 9pt;
    }

    .section-title {
      font-size: 12.5pt;
      font-weight: 700;
      color: #0f172a;
      letter-spacing: -0.3px;
    }

    .section-desc {
      font-size: 9pt;
      color: #475569;
      margin-bottom: 10px;
    }

    /* Cards */
    .crud-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 10px;
      margin-bottom: 12px;
    }

    .crud-card {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      padding: 10px 12px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.02);
    }

    .crud-card-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 6px;
    }

    .badge-op {
      padding: 2px 7px;
      border-radius: 5px;
      font-size: 7pt;
      font-weight: 700;
      text-transform: uppercase;
    }

    .op-create { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
    .op-read { background: #e0f2fe; color: #075985; border: 1px solid #bae6fd; }
    .op-update { background: #fef3c7; color: #92400e; border: 1px solid #fde68a; }
    .op-delete { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

    .card-title {
      font-size: 9pt;
      font-weight: 700;
      color: #1e293b;
    }

    .card-body {
      font-size: 8pt;
      color: #475569;
    }

    .card-body ul {
      margin-left: 14px;
      margin-top: 3px;
    }

    .card-body li {
      margin-bottom: 2px;
    }

    /* Code Snippets */
    .code-box {
      background: #0f172a;
      border-radius: 8px;
      padding: 8px 12px;
      margin: 6px 0 10px 0;
      overflow: hidden;
      border: 1px solid #1e293b;
    }

    .code-title {
      font-size: 7.2pt;
      color: #94a3b8;
      text-transform: uppercase;
      font-weight: 600;
      letter-spacing: 0.5px;
      margin-bottom: 5px;
      display: flex;
      justify-content: space-between;
      border-bottom: 1px solid #334155;
      padding-bottom: 3px;
    }

    pre {
      font-family: 'JetBrains Mono', monospace;
      font-size: 7.2pt;
      color: #e2e8f0;
      white-space: pre-wrap;
      word-break: break-all;
      line-height: 1.4;
    }

    .kw { color: #f43f5e; font-weight: 600; }
    .fn { color: #38bdf8; }
    .str { color: #a3e635; }
    .cm { color: #64748b; font-style: italic; }
    .tp { color: #fbbf24; }

    /* Tables */
    table.data-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 8pt;
      margin: 8px 0 12px 0;
      background: #ffffff;
      border-radius: 8px;
      overflow: hidden;
      border: 1px solid #e2e8f0;
    }

    table.data-table th {
      background: #f8fafc;
      color: #334155;
      font-weight: 700;
      text-align: left;
      padding: 6px 8px;
      border-bottom: 2px solid #e2e8f0;
      font-size: 7.5pt;
      text-transform: uppercase;
    }

    table.data-table td {
      padding: 6px 8px;
      border-bottom: 1px solid #f1f5f9;
      color: #475569;
      vertical-align: top;
    }

    table.data-table tr:last-child td {
      border-bottom: none;
    }

    table.data-table tr:nth-child(even) {
      background: #fcfdfe;
    }

    .pill {
      display: inline-block;
      padding: 1px 5px;
      border-radius: 4px;
      font-size: 6.8pt;
      font-weight: 600;
      background: #f1f5f9;
      color: #475569;
    }

    .pill-cloud {
      background: #eff6ff;
      color: #1d4ed8;
      border: 1px solid #bfdbfe;
    }

    .pill-local {
      background: #fefce8;
      color: #854d0e;
      border: 1px solid #fef08a;
    }

    /* Architecture Block */
    .arch-container {
      background: #f8fafc;
      border: 1px solid #e2e8f0;
      border-radius: 10px;
      padding: 10px 12px;
      margin-bottom: 12px;
    }

    .arch-flow {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 6px;
      margin-top: 6px;
    }

    .arch-step {
      flex: 1;
      background: #ffffff;
      border: 1px solid #cbd5e1;
      border-radius: 6px;
      padding: 6px 8px;
      text-align: center;
    }

    .arch-step-title {
      font-size: 8pt;
      font-weight: 700;
      color: #1e293b;
      margin-bottom: 1px;
    }

    .arch-step-desc {
      font-size: 7pt;
      color: #64748b;
    }

    .arch-arrow {
      color: #94a3b8;
      font-size: 11pt;
      font-weight: 700;
    }

    .footer-note {
      text-align: center;
      font-size: 7.5pt;
      color: #94a3b8;
      margin-top: 16px;
      padding-top: 10px;
      border-top: 1px solid #e2e8f0;
    }
  </style>
</head>
<body>

  <!-- ==================== HALAMAN 1: COVER & RINGKASAN EKSEKUTIF ==================== -->
  <div class="cover-container">
    <div class="badge-tag">Dokumentasi Teknis & Arsitektur Database</div>
    <h1 class="cover-title">Laporan Analisis Fungsi CRUD<br>Aplikasi Cashier Latte</h1>
    <p class="cover-subtitle">
      Pemetaan komprehensif implementasi operasi Create, Read, Update, dan Delete pada layer Cloud Firestore, SQLite Lokal, State Notifier, serta Antarmuka Pengguna (UI).
    </p>

    <div class="meta-grid">
      <div class="meta-item">
        <span>Nama Aplikasi</span>
        <strong>Cashier BGA Co. Latte</strong>
      </div>
      <div class="meta-item">
        <span>Framework & Database</span>
        <strong>Flutter + Firestore & SQLite</strong>
      </div>
      <div class="meta-item">
        <span>Status Implementasi</span>
        <strong>100% Aktif & Sinkron</strong>
      </div>
    </div>
  </div>

  <div class="section-header">
    <div class="section-icon">1</div>
    <div>
      <h2 class="section-title">Arsitektur Multi-Tier CRUD Aplikasi</h2>
    </div>
  </div>
  <p class="section-desc">
    Aplikasi Cashier Latte menerapkan arsitektur ganda database: <strong>Cloud Firestore</strong> sebagai sistem database utama yang sinkron secara real-time dan multi-device, serta <strong>SQLite (sqflite)</strong> sebagai modul database lokal terstruktur dan pembelajaran.
  </p>

  <div class="arch-container avoid-break">
    <div style="font-weight: 700; font-size: 8.5pt; color: #334155; margin-bottom: 4px;">Alur Eksekusi Data CRUD (Optimistic UI & Real-Time Sync)</div>
    <div class="arch-flow">
      <div class="arch-step">
        <div class="arch-step-title">1. UI View Layer</div>
        <div class="arch-step-desc">Dialog Form / Swipe / POS</div>
      </div>
      <div class="arch-arrow">➔</div>
      <div class="arch-step">
        <div class="arch-step-title">2. State Store</div>
        <div class="arch-step-desc">MenuDataStore (ValueNotifier)</div>
      </div>
      <div class="arch-arrow">➔</div>
      <div class="arch-step">
        <div class="arch-step-title">3. Database Helper</div>
        <div class="arch-step-desc">DataBaseHelper CRUD Services</div>
      </div>
      <div class="arch-arrow">➔</div>
      <div class="arch-step">
        <div class="arch-step-title">4. Cloud / Local DB</div>
        <div class="arch-step-desc">Firestore & SQLite (ppkd.db)</div>
      </div>
    </div>
  </div>

  <div class="section-header">
    <div class="section-icon">2</div>
    <div>
      <h2 class="section-title">Matriks Entitas CRUD Utama</h2>
    </div>
  </div>

  <table class="data-table avoid-break">
    <thead>
      <tr>
        <th style="width: 22%;">Entitas Data</th>
        <th style="width: 18%;">Tipe Penyimpanan</th>
        <th style="width: 32%;">Operasi CRUD yang Tersedia</th>
        <th style="width: 28%;">Lokasi File Source</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><strong>Menu Items (Katalog Produk)</strong></td>
        <td><span class="pill pill-cloud">Cloud Firestore</span></td>
        <td>Create Menu, Read All / Filter, Update Menu, Soft/Hard Delete</td>
        <td><code>database_helper.dart</code><br><code>menu_data_store.dart</code></td>
      </tr>
      <tr>
        <td><strong>Categories (Kategori Menu)</strong></td>
        <td><span class="pill pill-cloud">Cloud Firestore</span></td>
        <td>Add Category, Fetch Sorted, Rename/Update, Cascade Delete</td>
        <td><code>database_helper.dart</code><br><code>menu_data_store.dart</code></td>
      </tr>
      <tr>
        <td><strong>Transactions & Invoices</strong></td>
        <td><span class="pill pill-cloud">Cloud Firestore</span></td>
        <td>Insert POS Order, Stream Invoices, Filter by Store, Fetch Detail</td>
        <td><code>database_helper.dart</code><br><code>qris_payment_screen.dart</code></td>
      </tr>
      <tr>
        <td><strong>Staff & Shift Roster</strong></td>
        <td><span class="pill pill-cloud">Cloud Firestore</span></td>
        <td>Register Staff, Assign Shift, Update Status Hadir/Break, Delete</td>
        <td><code>database_helper.dart</code><br><code>staff_shift_screen.dart</code></td>
      </tr>
      <tr>
        <td><strong>User Login & Profile</strong></td>
        <td><span class="pill pill-cloud">Cloud Firestore</span> + <span class="pill pill-local">SQLite</span></td>
        <td>Register, Query Login Auth, Edit Bio & Avatar, Remove User</td>
        <td><code>database_helper.dart</code><br><code>db_helper.dart</code></td>
      </tr>
      <tr>
        <td><strong>Store Branches (Cabang)</strong></td>
        <td><span class="pill pill-cloud">Cloud Firestore</span></td>
        <td>Insert Store, Get All Stores, Delete Store by ID / Name</td>
        <td><code>database_helper.dart</code><br><code>store_showcase_screen.dart</code></td>
      </tr>
    </tbody>
  </table>

  <!-- ==================== HALAMAN 2: DETAIL CRUD MENU & KATEGORI ==================== -->
  <div class="page-break"></div>

  <div class="section-header">
    <div class="section-icon">3</div>
    <div>
      <h2 class="section-title">Detail Implementasi CRUD: Menu Items & Kategori</h2>
    </div>
  </div>
  <p class="section-desc">
    Modul Menu dan Kategori merupakan inti dari aplikasi POS Cashier Latte. Terintegrasi penuh dengan <strong>Firestore Collection <code>'menu_items'</code></strong> dan <strong><code>'categories'</code></strong> dengan sinkronisasi reaktif ke UI.
  </p>

  <div class="crud-grid avoid-break">
    <div class="crud-card">
      <div class="crud-card-header">
        <span class="card-title">1. CREATE (Insert Menu & Category)</span>
        <span class="badge-op op-create">CREATE</span>
      </div>
      <div class="card-body">
        <ul>
          <li><strong>Insert Menu:</strong> Menambahkan menu baru lengkap dengan nama, harga, deskripsi, kategori, serta foto (Path Asset / Base64 Bytes).</li>
          <li><strong>Insert Category:</strong> Membuat kategori baru dengan penomoran urut (sort order) otomatis.</li>
          <li><strong>Optimistic State:</strong> Ditambahkan langsung ke <code>ValueNotifier</code> agar UI merespons 0ms tanpa menunggu latency jaringan.</li>
        </ul>
      </div>
    </div>

    <div class="crud-card">
      <div class="crud-card-header">
        <span class="card-title">2. READ (Fetch & Real-time Stream)</span>
        <span class="badge-op op-read">READ</span>
      </div>
      <div class="card-body">
        <ul>
          <li><strong>Get All Menu:</strong> Memuat seluruh menu yang berstatus <code>is_active == 1</code>.</li>
          <li><strong>Get by Category:</strong> Filter instan berdasarkan kategori tab yang dipilih pengguna (Food, Drink, Snack, Dessert).</li>
          <li><strong>Real-time Stream:</strong> Listener Firestore aktif meng-update katalog jika ada perubahan dari admin lain.</li>
        </ul>
      </div>
    </div>

    <div class="crud-card">
      <div class="crud-card-header">
        <span class="card-title">3. UPDATE (Edit Menu & Rename Category)</span>
        <span class="badge-op op-update">UPDATE</span>
      </div>
      <div class="card-body">
        <ul>
          <li><strong>Update Menu:</strong> Memperbarui harga, deskripsi, foto baru, atau perpindahan kategori produk.</li>
          <li><strong>Rename Category:</strong> Mengubah nama kategori dan secara otomatis meng-update seluruh menu yang berelasi dengan kategori tersebut (Cascade sync).</li>
        </ul>
      </div>
    </div>

    <div class="crud-card">
      <div class="crud-card-header">
        <span class="card-title">4. DELETE (Hapus Menu & Kategori)</span>
        <span class="badge-op op-delete">DELETE</span>
      </div>
      <div class="card-body">
        <ul>
          <li><strong>Delete Menu Item:</strong> Menghapus dokumen menu berdasarkan ID spesifik dari Firestore.</li>
          <li><strong>Delete Category:</strong> Menghapus kategori beserta membersihkan item terkait agar integritas data tetap konsisten.</li>
          <li><strong>UI Action:</strong> Disediakan konfirmasi modal sebelum aksi penghapusan permanen.</li>
        </ul>
      </div>
    </div>
  </div>

  <div class="code-box avoid-break">
    <div class="code-title">
      <span>Snippet Code CRUD Menu (lib/halaman1/database/database_helper.dart)</span>
      <span>Dart / Firestore</span>
    </div>
    <pre><span class="cm">/// 1. CREATE: Tambah Item Menu Baru</span>
<span class="tp">Future</span>&lt;<span class="tp">int</span>&gt; <span class="fn">insertMenuItem</span>(<span class="tp">MenuItemModel</span> item) <span class="kw">async</span> {
  <span class="kw">final</span> map = item.toMap();
  <span class="kw">final</span> newId = item.id ?? <span class="tp">DateTime</span>.now().millisecondsSinceEpoch;
  map[<span class="str">'id'</span>] = newId;
  <span class="kw">if</span> (item.imageBytes != <span class="kw">null</span>) map[<span class="str">'image_bytes'</span>] = _bytesToBase64(item.imageBytes);
  <span class="kw">await</span> _menuItemsCol.doc('menu_' + newId.toString()).set(map);
  <span class="kw">return</span> newId;
}

<span class="cm">/// 2. READ: Ambil Semua Menu Aktif</span>
<span class="tp">Future</span>&lt;<span class="tp">List</span>&lt;<span class="tp">MenuItemModel</span>&gt;&gt; <span class="fn">getAllMenuItems</span>() <span class="kw">async</span> {
  <span class="kw">final</span> snapshot = <span class="kw">await</span> _menuItemsCol.where(<span class="str">'is_active'</span>, isEqualTo: <span class="tp">1</span>).get();
  <span class="kw">return</span> snapshot.docs.map((doc) => <span class="tp">MenuItemModel</span>.fromMap(doc.data())).toList();
}

<span class="cm">/// 3. UPDATE: Perbarui Data Menu</span>
<span class="tp">Future</span>&lt;<span class="tp">bool</span>&gt; <span class="fn">updateMenuItem</span>(<span class="tp">MenuItemModel</span> item) <span class="kw">async</span> {
  <span class="kw">final</span> map = item.toMap();
  <span class="kw">await</span> _menuItemsCol.doc('menu_' + item.id.toString()).set(map, <span class="tp">SetOptions</span>(merge: <span class="kw">true</span>));
  <span class="kw">return</span> <span class="kw">true</span>;
}

<span class="cm">/// 4. DELETE: Hapus Menu Berdasarkan ID</span>
<span class="tp">Future</span>&lt;<span class="tp">bool</span>&gt; <span class="fn">deleteMenuItem</span>(<span class="tp">int</span> id) <span class="kw">async</span> {
  <span class="kw">final</span> snapshot = <span class="kw">await</span> _menuItemsCol.where(<span class="str">'id'</span>, isEqualTo: id).get();
  <span class="kw">for</span> (<span class="kw">final</span> doc <span class="kw">in</span> snapshot.docs) { <span class="kw">await</span> doc.reference.delete(); }
  <span class="kw">return</span> <span class="kw">true</span>;
}</pre>
  </div>

  <!-- ==================== HALAMAN 3: CRUD TRANSAKSI, STAFF & SQLITE ==================== -->
  <div class="page-break"></div>

  <div class="section-header">
    <div class="section-icon">4</div>
    <div>
      <h2 class="section-title">Detail Implementasi CRUD: Transaksi POS & Kasir</h2>
    </div>
  </div>

  <div class="crud-grid avoid-break">
    <div class="crud-card">
      <div class="crud-card-header">
        <span class="card-title">Transaksi POS (Orders & Invoices)</span>
        <span class="badge-op op-create">CREATE / READ</span>
      </div>
      <div class="card-body">
        <ul>
          <li><strong>CREATE (Checkout POS):</strong> Menyimpan transaksi ke Firestore dengan rincian item belanja (array objek), subtotal, pajak PPN 10%, metode pembayaran (QRIS/Cash), serta nomor Invoice unik otomatis (contoh: <code>#INV-20260914-001</code>).</li>
          <li><strong>READ (Riwayat & Struk):</strong> Stream transaksi langsung ke halaman Riwayat, pencarian invoice per cabang toko (Bella Cafe, Central Perk, dll).</li>
        </ul>
      </div>
    </div>

    <div class="crud-card">
      <div class="crud-card-header">
        <span class="card-title">Staff & Jadwal Shift Karyawan</span>
        <span class="badge-op op-update">FULL CRUD</span>
      </div>
      <div class="card-body">
        <ul>
          <li><strong>CREATE:</strong> Form Tambah Karyawan baru (Nama, Role, No HP, Foto Avatar).</li>
          <li><strong>READ:</strong> Roster harian shift (Pagi/Sore) berdasarkan tanggal aktif.</li>
          <li><strong>UPDATE:</strong> Ubah status absensi (Hadir, Istirahat, Izin, Selesai Shift).</li>
          <li><strong>DELETE:</strong> Hapus data staf atau jadwal shift lama.</li>
        </ul>
      </div>
    </div>
  </div>

  <div class="section-header">
    <div class="section-icon">5</div>
    <div>
      <h2 class="section-title">Implementasi CRUD SQLite Lokal (Modul 8SQFLITE)</h2>
    </div>
  </div>
  <p class="section-desc">
    Modul <code>lib/8SQFLITE_CRUD/database/db_helper.dart</code> menggunakan engine SQL lokal murni dengan file database <code>ppkd.db</code> untuk mengelola autentikasi dan data pengguna secara offline.
  </p>

  <div class="code-box avoid-break">
    <div class="code-title">
      <span>Operasi CRUD SQLite (lib/8SQFLITE_CRUD/database/db_helper.dart)</span>
      <span>SQLite / Sqflite</span>
    </div>
    <pre><span class="cm">/// 1. CREATE: Insert data user ke tabel 'users'</span>
<span class="tp">Future</span>&lt;<span class="tp">bool</span>&gt; <span class="fn">registerUser</span>(<span class="tp">UserModelSQL</span> pengguna) <span class="kw">async</span> {
  <span class="kw">final</span> db = <span class="kw">await</span> database;
  <span class="kw">try</span> {
    <span class="kw">await</span> db.insert(<span class="str">'users'</span>, pengguna.toMap());
    <span class="kw">return</span> <span class="kw">true</span>;
  } <span class="kw">catch</span> (e) { <span class="kw">return</span> <span class="kw">false</span>; }
}

<span class="cm">/// 2. READ: Query user untuk verifikasi login & get all users</span>
<span class="tp">Future</span>&lt;<span class="tp">List</span>&lt;<span class="tp">UserModelSQL</span>&gt;&gt; <span class="fn">getAllUsers</span>() <span class="kw">async</span> {
  <span class="kw">final</span> db = <span class="kw">await</span> database;
  <span class="kw">final</span> <span class="tp">List</span>&lt;<span class="tp">Map</span>&lt;<span class="tp">String</span>, <span class="tp">dynamic</span>&gt;&gt; results = <span class="kw">await</span> db.query(<span class="str">'users'</span>);
  <span class="kw">return</span> results.map((map) => <span class="tp">UserModelSQL</span>.fromMap(map)).toList();
}

<span class="cm">/// 3. UPDATE: Update data user berdasarkan id</span>
<span class="tp">Future</span>&lt;<span class="tp">bool</span>&gt; <span class="fn">updateUser</span>(<span class="tp">UserModelSQL</span> pengguna) <span class="kw">async</span> {
  <span class="kw">final</span> db = <span class="kw">await</span> database;
  <span class="kw">int</span> count = <span class="kw">await</span> db.update(<span class="str">'users'</span>, pengguna.toMap(), where: <span class="str">'id = ?'</span>, whereArgs: [pengguna.id]);
  <span class="kw">return</span> count > <span class="tp">0</span>;
}

<span class="cm">/// 4. DELETE: Hapus user berdasarkan id</span>
<span class="tp">Future</span>&lt;<span class="tp">void</span>&gt; <span class="fn">deleteUser</span>(<span class="tp">int</span> id) <span class="kw">async</span> {
  <span class="kw">final</span> db = <span class="kw">await</span> database;
  <span class="kw">await</span> db.delete(<span class="str">'users'</span>, where: <span class="str">'id = ?'</span>, whereArgs: [id]);
}</pre>
  </div>

  <div class="section-header">
    <div class="section-icon">6</div>
    <div>
      <h2 class="section-title">Kesimpulan & Ringkasan Validasi</h2>
    </div>
  </div>
  <table class="data-table avoid-break">
    <thead>
      <tr>
        <th>Aspek Pengujian</th>
        <th>Hasil Analisis Kode</th>
        <th>Status</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><strong>Kesiapan Fungsi CRUD</strong></td>
        <td>Semua fungsi Create, Read, Update, Delete telah diimplementasikan lengkap di helper dan UI view.</td>
        <td><strong style="color: #16a34a;">Lengkap (100%)</strong></td>
      </tr>
      <tr>
        <td><strong>Penanganan Error (Exception Safety)</strong></td>
        <td>Dilengkapi blok <code>try-catch</code>, fallback data default, serta logging <code>debugPrint</code>.</td>
        <td><strong style="color: #16a34a;">Aman & Terproteksi</strong></td>
      </tr>
      <tr>
        <td><strong>Sinkronisasi Realtime</strong></td>
        <td>Mendukung stream snapshots Firestore dan ValueNotifier untuk pengalaman kasir responsif.</td>
        <td><strong style="color: #16a34a;">Real-Time Aktif</strong></td>
      </tr>
    </tbody>
  </table>

  <div class="footer-note">
    Dokumentasi Otomatis Aplikasi Cashier BGA Co. &bull; Dibuat secara resmi untuk Laporan Teknis CRUD &bull; Tanggal: 14 September 2026
  </div>

</body>
</html>
`;

const htmlFilePath = path.join(__dirname, 'laporan_crud_cashier.html');
const pdfFilePath = path.join(__dirname, 'Laporan_Fungsi_CRUD_Aplikasi_Cashier.pdf');

fs.writeFileSync(htmlFilePath, htmlContent, 'utf8');
console.log('HTML file written to: ' + htmlFilePath);

// Locate Chrome or Edge
const chromePath = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const edgePath = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';

let browserPath = '';
if (fs.existsSync(chromePath)) {
  browserPath = chromePath;
} else if (fs.existsSync(edgePath)) {
  browserPath = edgePath;
}

if (!browserPath) {
  console.error('No suitable browser found for PDF rendering');
  process.exit(1);
}

console.log('Using browser binary: ' + browserPath);

const fileUrl = 'file:///' + htmlFilePath.replace(/\\/g, '/');
const cmd = `"${browserPath}" --headless=new --disable-gpu --no-pdf-header-footer --print-to-pdf="${pdfFilePath}" "${fileUrl}"`;

console.log('Executing PDF generation command...');
try {
  execSync(cmd, { stdio: 'inherit' });
  console.log('PDF successfully generated at: ' + pdfFilePath);
} catch (err) {
  console.error('Error generating PDF:', err);
  process.exit(1);
}
