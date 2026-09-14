const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const htmlContent = `<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Laporan Komprehensif CRUD & Firebase - Aplikasi Cashier Latte</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap');

    @page {
      size: A4 portrait;
      margin: 14mm 12mm 14mm 12mm;
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
      font-size: 10pt;
      -webkit-print-color-adjust: exact !important;
      print-color-adjust: exact !important;
    }

    .page-break {
      page-break-before: always;
      break-before: page;
    }

    .avoid-break {
      page-break-inside: avoid;
      break-inside: avoid;
    }

    /* HEADER */
    .header-banner {
      background: linear-gradient(135deg, #1e1b4b 0%, #312e81 50%, #4338ca 100%);
      color: #ffffff;
      padding: 18px 20px;
      border-radius: 12px;
      margin-bottom: 16px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      box-shadow: 0 4px 14px rgba(67, 56, 202, 0.2);
    }

    .header-title h1 {
      font-size: 17pt;
      font-weight: 800;
      letter-spacing: -0.02em;
      margin-bottom: 4px;
      color: #ffffff;
    }

    .header-title p {
      font-size: 9.5pt;
      color: #c7d2fe;
      font-weight: 500;
    }

    .meta-tag {
      background: rgba(255, 255, 255, 0.15);
      backdrop-filter: blur(8px);
      border: 1px solid rgba(255, 255, 255, 0.25);
      color: #ffffff;
      padding: 6px 12px;
      border-radius: 8px;
      font-size: 8.5pt;
      font-weight: 600;
      text-align: right;
      line-height: 1.4;
    }

    /* SECTION TITLE */
    .section-header {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-top: 16px;
      margin-bottom: 10px;
      padding-bottom: 6px;
      border-bottom: 2px solid #e2e8f0;
    }

    .section-number {
      background: #4338ca;
      color: #ffffff;
      width: 24px;
      height: 24px;
      border-radius: 6px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 10pt;
      font-weight: 700;
      flex-shrink: 0;
    }

    .section-header h2 {
      font-size: 12pt;
      font-weight: 700;
      color: #0f172a;
      letter-spacing: -0.01em;
    }

    /* CARDS */
    .card {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 10px;
      padding: 12px 14px;
      margin-bottom: 12px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
    }

    .card-title {
      font-size: 10.5pt;
      font-weight: 700;
      color: #1e293b;
      margin-bottom: 6px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .file-path {
      font-family: 'JetBrains Mono', monospace;
      font-size: 8pt;
      background: #f1f5f9;
      color: #0f766e;
      padding: 3px 8px;
      border-radius: 6px;
      border: 1px solid #cbd5e1;
      font-weight: 600;
    }

    /* BADGES */
    .badge {
      display: inline-block;
      padding: 2px 7px;
      border-radius: 4px;
      font-size: 7.5pt;
      font-weight: 700;
      letter-spacing: 0.03em;
    }

    .badge-c { background: #dcfce7; color: #166534; }
    .badge-r { background: #e0f2fe; color: #075985; }
    .badge-u { background: #fef9c3; color: #854d0e; }
    .badge-d { background: #fee2e2; color: #991b1b; }
    .badge-fb { background: #ffedd5; color: #c2410c; }
    .badge-auth { background: #ede9fe; color: #6b21a8; }
    .badge-sync { background: #ccfbf1; color: #115e59; }

    /* TABLES */
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 6px;
      font-size: 8.5pt;
    }

    th {
      background: #f8fafc;
      color: #475569;
      font-weight: 700;
      text-align: left;
      padding: 6px 8px;
      border-bottom: 2px solid #cbd5e1;
    }

    td {
      padding: 6px 8px;
      border-bottom: 1px solid #e2e8f0;
      vertical-align: top;
    }

    tr:nth-child(even) td {
      background-color: #fafafa;
    }

    code {
      font-family: 'JetBrains Mono', monospace;
      font-size: 8pt;
      background: #f1f5f9;
      color: #334155;
      padding: 1px 4px;
      border-radius: 4px;
    }

    /* CODE BOX */
    .code-box {
      font-family: 'JetBrains Mono', monospace;
      font-size: 8pt;
      background: #0f172a;
      color: #f8fafc;
      padding: 10px 12px;
      border-radius: 8px;
      margin-top: 6px;
      line-height: 1.45;
    }

    .kw { color: #f472b6; }
    .fn { color: #38bdf8; }
    .st { color: #a3e635; }
    .cm { color: #94a3b8; font-style: italic; }

    /* GRID */
    .grid-2 {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
    }

    /* ARCHITECTURE BOX */
    .arch-container {
      display: grid;
      grid-template-columns: 1fr 1fr 1fr;
      gap: 8px;
      margin-top: 6px;
    }

    .arch-card {
      background: #f8fafc;
      border: 1px solid #cbd5e1;
      border-radius: 8px;
      padding: 8px 10px;
      text-align: center;
    }

    .arch-card h4 {
      font-size: 9pt;
      color: #1e293b;
      margin-bottom: 3px;
    }

    .arch-card p {
      font-size: 7.5pt;
      color: #64748b;
    }

    /* FOOTER */
    .footer {
      border-top: 1px solid #e2e8f0;
      margin-top: 16px;
      padding-top: 8px;
      font-size: 7.5pt;
      color: #94a3b8;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
  </style>
</head>
<body>

  <!-- HEADER -->
  <div class="header-banner">
    <div class="header-title">
      <h1>Laporan Teknis CRUD & Firebase</h1>
      <p>Arsitektur Data & Sinkronisasi Cloud Aplikasi Cashier Latte</p>
    </div>
    <div class="meta-tag">
      <div>Platform: Flutter / Dart</div>
      <div>Database: SQLite & Firebase Firestore</div>
    </div>
  </div>

  <!-- RINGKASAN ARSITEKTUR -->
  <div class="card avoid-break" style="background: #fdfefe; border-left: 4px solid #4338ca;">
    <div class="card-title" style="margin-bottom: 4px;">
      <span>Ringkasan Arsitektur Data Aplikasi</span>
      <span class="badge badge-sync">Hybrid Architecture</span>
    </div>
    <p style="font-size: 8.5pt; color: #475569; margin-bottom: 8px;">
      Aplikasi menggunakan pola <strong>Hybrid Offline-First</strong>: Operasi kasir inti (transaksi penjualan, pembukaan shift, cetak nota, dan katalog menu) berjalan cepat dan stabil secara offline via <strong>SQLite & In-Memory DataStore</strong>. Layanan <strong>Firebase (Auth & Cloud Firestore)</strong> diintegrasikan untuk manajemen akun cloud, sinkronisasi state acak/picker, dan analitik interaksi.
    </p>
    <div class="arch-container">
      <div class="arch-card">
        <h4>1. SQLite Database</h4>
        <p>Database relasional lokal (sqflite) untuk transaksi kasir, shifts, dan users.</p>
      </div>
      <div class="arch-card">
        <h4>2. DataStore In-Memory</h4>
        <p>Manajemen menu kustom & kategori dinamis dengan sinkronisasi instan.</p>
      </div>
      <div class="arch-card">
        <h4>3. Firebase Cloud</h4>
        <p>Firebase Auth, Firestore real-time listener, dan Button Analytics.</p>
      </div>
    </div>
  </div>

  <!-- BAGIAN 1: CRUD -->
  <div class="section-header avoid-break">
    <div class="section-number">1</div>
    <h2>Implementasi Operasi CRUD (Create, Read, Update, Delete)</h2>
  </div>

  <!-- A. SQLite POS Helper -->
  <div class="card avoid-break">
    <div class="card-title">
      <span>A. Database Utama Kasir (SQLite Database Helper)</span>
      <span class="file-path">lib/halaman1/database/database_helper.dart</span>
    </div>
    <table>
      <thead>
        <tr>
          <th style="width: 12%;">Aksi</th>
          <th style="width: 32%;">Method / Function</th>
          <th style="width: 26%;">Tabel SQLite</th>
          <th>Deskripsi Operasional</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><span class="badge badge-c">CREATE</span></td>
          <td>
            <code>insertTransaction(Map row)</code><br>
            <code>insertStaff(Staff s)</code><br>
            <code>insertShift(Shift sh)</code><br>
            <code>insertExpense(Expense e)</code><br>
            <code>insertDraftOrder(DraftOrder d)</code>
          </td>
          <td>
            <code>transactions</code><br>
            <code>transaction_items</code><br>
            <code>staff</code>, <code>shifts</code><br>
            <code>expenses</code>, <code>draft_orders</code>
          </td>
          <td>Menyimpan transaksi kasir baru, mendaftarkan staf baru, mencatat pembukaan shift kerja, pengeluaran kas, serta menyimpan pesanan tertunda (draft/hold).</td>
        </tr>
        <tr>
          <td><span class="badge badge-r">READ</span></td>
          <td>
            <code>getAllTransactions()</code><br>
            <code>getTransactionById(int id)</code><br>
            <code>getAllStaff()</code> / <code>loginStaff()</code><br>
            <code>getActiveShift()</code><br>
            <code>getTopSellingItems()</code>
          </td>
          <td>
            <code>transactions</code><br>
            <code>staff</code>, <code>shifts</code><br>
            <code>activity_logs</code><br>
            <code>attendance</code>
          </td>
          <td>Menampilkan riwayat pesanan, memverifikasi PIN login kasir, mengambil status shift yang sedang berjalan, dan kalkulasi rekap penjualan per metode bayar.</td>
        </tr>
        <tr>
          <td><span class="badge badge-u">UPDATE</span></td>
          <td>
            <code>updateTransaction(id, row)</code><br>
            <code>updateStaff(Staff s)</code><br>
            <code>closeShift(...)</code><br>
            <code>updateDraftOrder(...)</code>
          </td>
          <td>
            <code>transactions</code><br>
            <code>staff</code><br>
            <code>shifts</code><br>
            <code>draft_orders</code>
          </td>
          <td>Memperbarui status pembayaran transaksi, edit data staf, menutup shift serta merekonsiliasi total kas fisik vs kas sistem, dan mengubah isi pesanan draft.</td>
        </tr>
        <tr>
          <td><span class="badge badge-d">DELETE</span></td>
          <td>
            <code>deleteTransaction(int id)</code><br>
            <code>deleteStaff(int id)</code><br>
            <code>deleteDraftOrder(int id)</code><br>
            <code>deleteExpense(int id)</code>
          </td>
          <td>
            <code>transactions</code><br>
            <code>staff</code><br>
            <code>draft_orders</code><br>
            <code>expenses</code>
          </td>
          <td>Menghapus data transaksi penjualan yang dibatalkan, menghapus akun staf kasir, membersihkan pesanan draft yang sudah selesai/dibuang, dan membatalkan pengeluaran.</td>
        </tr>
      </tbody>
    </table>
  </div>

  <div class="grid-2 avoid-break">
    <!-- B. Modul Latihan CRUD SQLite -->
    <div class="card">
      <div class="card-title">
        <span>B. Modul CRUD User (Latihan)</span>
      </div>
      <p style="font-size: 8pt; color: #64748b; margin-bottom: 6px;">
        File: <span class="file-path">lib/8SQFLITE_CRUD/database/db_helper.dart</span>
      </p>
      <table>
        <thead><tr><th>Tipe</th><th>Method</th><th>Keterangan</th></tr></thead>
        <tbody>
          <tr><td><span class="badge badge-c">CREATE</span></td><td><code>saveUser(user)</code></td><td>Registrasi user baru</td></tr>
          <tr><td><span class="badge badge-r">READ</span></td><td><code>getUser()</code> / <code>getLoginUser()</code></td><td>Ambil list & validasi login</td></tr>
          <tr><td><span class="badge badge-u">UPDATE</span></td><td><code>updateUser(user)</code></td><td>Update info user/password</td></tr>
          <tr><td><span class="badge badge-d">DELETE</span></td><td><code>deleteUser(id)</code></td><td>Hapus baris user di SQLite</td></tr>
        </tbody>
      </table>
      <p style="font-size: 7.5pt; color: #475569; margin-top: 6px;">
        UI: <code>lib/8SQFLITE_CRUD/views/data_user.dart</code> & <code>login.dart</code>
      </p>
    </div>

    <!-- C. Menu Data Store CRUD -->
    <div class="card">
      <div class="card-title">
        <span>C. Katalog Menu (DataStore)</span>
      </div>
      <p style="font-size: 8pt; color: #64748b; margin-bottom: 6px;">
        File: <span class="file-path">lib/halaman1/utils/menu_data_store.dart</span>
      </p>
      <table>
        <thead><tr><th>Tipe</th><th>Method</th><th>Keterangan</th></tr></thead>
        <tbody>
          <tr><td><span class="badge badge-c">CREATE</span></td><td><code>addItem()</code>, <code>addCategory()</code></td><td>Tambah menu & kategori baru</td></tr>
          <tr><td><span class="badge badge-r">READ</span></td><td><code>getMenuItems()</code></td><td>Ambil produk aktif/filter</td></tr>
          <tr><td><span class="badge badge-u">UPDATE</span></td><td><code>updateItem()</code>, <code>toggleItem()</code></td><td>Ubah harga, nama, stok</td></tr>
          <tr><td><span class="badge badge-d">DELETE</span></td><td><code>deleteItem()</code>, <code>deleteCat()</code></td><td>Hapus menu dari katalog</td></tr>
        </tbody>
      </table>
      <p style="font-size: 7.5pt; color: #475569; margin-top: 6px;">
        Pengelolaan real-time state menu pada tampilan POS & halaman kasir.
      </p>
    </div>
  </div>

  <div class="page-break"></div>

  <!-- BAGIAN 2: FIREBASE -->
  <div class="section-header avoid-break">
    <div class="section-number">2</div>
    <h2>Implementasi Layanan Firebase Cloud</h2>
  </div>

  <!-- A. Inisialisasi Firebase -->
  <div class="card avoid-break">
    <div class="card-title">
      <span>A. Konfigurasi Multi-Platform & Inisialisasi Core</span>
      <span class="file-path">lib/main.dart & lib/firebase_options.dart</span>
    </div>
    <p style="font-size: 8.5pt; color: #475569; margin-bottom: 6px;">
      Firebase diinisialisasi secara asynchronous pada fungsi <code>main()</code> sebelum <code>runApp()</code> dengan dukungan <strong>Offline Persistence Cache</strong> tak terbatas:
    </p>
    <div class="code-box">
<span class="cm">// lib/main.dart (Baris 32 - 48)</span>
<span class="kw">await</span> Firebase.<span class="fn">initializeApp</span>(
  options: DefaultFirebaseOptions.currentPlatformSafe,
);

<span class="cm">// Konfigurasi Firestore Offline Cache</span>
FirebaseFirestore.instance.settings = <span class="kw">const</span> <span class="fn">Settings</span>(
  persistenceEnabled: <span class="kw">true</span>,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
    </div>
    <div style="margin-top: 8px; font-size: 8pt; color: #64748b;">
      File <code>firebase_options.dart</code> memuat konfigurasi API Key, App ID, Messaging Sender ID, dan Project ID untuk Android, iOS, Windows, Web, dan macOS.
    </div>
  </div>

  <!-- B. Cloud Firestore & Realtime Sync -->
  <div class="card avoid-break">
    <div class="card-title">
      <span>B. Cloud Firestore & Real-Time Sync Service</span>
      <span class="file-path">lib/random_picker/picker_logic.dart & random_picker_screen.dart</span>
    </div>
    <table>
      <thead>
        <tr>
          <th style="width: 22%;">Modul / Fitur</th>
          <th style="width: 28%;">Method / Operasi</th>
          <th style="width: 22%;">Koleksi Firestore</th>
          <th>Penjelasan Fungsi Cloud</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><span class="badge badge-fb">STATE SYNC</span></td>
          <td><code>saveStateToFirebase(...)</code></td>
          <td><code>picker_state</code></td>
          <td>Menyimpan konfigurasi roda acak staf, segmen pilihan, dan tema visual ke Firestore document.</td>
        </tr>
        <tr>
          <td><span class="badge badge-fb">HISTORY LOG</span></td>
          <td><code>logPickWinnerToFirebase(...)</code></td>
          <td><code>picker_history</code></td>
          <td>Mencatat riwayat nama pemenang undian acak secara otomatis ke cloud database.</td>
        </tr>
        <tr>
          <td><span class="badge badge-sync">REALTIME STREAM</span></td>
          <td><code>streamState()</code></td>
          <td><code>picker_state</code> (Doc Snapshot)</td>
          <td>Mendengarkan event perubahan data langsung melalui <code>snapshots().listen()</code> untuk sinkronisasi live multi-device.</td>
        </tr>
        <tr>
          <td><span class="badge badge-r">CLOUD FETCH</span></td>
          <td><code>fetchStaffNamesFromFirebase()</code></td>
          <td><code>staff</code> / <code>users</code></td>
          <td>Mengambil daftar nama staf langsung dari koleksi Firestore untuk dimuat ke wheel picker.</td>
        </tr>
      </tbody>
    </table>
  </div>

  <!-- C. Firebase Auth & Button Analytics -->
  <div class="grid-2 avoid-break">
    <div class="card">
      <div class="card-title">
        <span>C. Firebase Authentication</span>
        <span class="badge badge-auth">firebase_auth</span>
      </div>
      <p style="font-size: 8pt; color: #475569; margin-bottom: 6px;">
        File: <span class="file-path">lib/main.dart</span> & <span class="file-path">picker_logic.dart</span>
      </p>
      <ul style="padding-left: 16px; font-size: 8pt; color: #334155; line-height: 1.6;">
        <li><strong>Sesi User Aktif:</strong> Pengecekan <code>FirebaseAuth.instance.currentUser</code> saat startup untuk mendeteksi user yang login.</li>
        <li><strong>User-Scoped Data:</strong> Penggunaan <code>currentUser?.uid</code> sebagai identifier pemilik dokumen pada Firestore collection.</li>
      </ul>
    </div>

    <div class="card">
      <div class="card-title">
        <span>D. Firebase Button Analytics</span>
        <span class="badge badge-fb">cloud_firestore</span>
      </div>
      <p style="font-size: 8pt; color: #64748b; margin-bottom: 6px;">
        File: <span class="file-path">lib/utils/button.dart</span> (Class <code>FirebaseAsyncButton</code>)
      </p>
      <ul style="padding-left: 16px; font-size: 8pt; color: #334155; line-height: 1.6;">
        <li><strong>Async Action Handler:</strong> Otomatis menampilkan loading spinner saat eksekusi async Firebase.</li>
        <li><strong>Logging Otomatis:</strong> Mencatat log event tombol ke koleksi <code>button_analytics</code> lengkap dengan metadata & user ID.</li>
      </ul>
    </div>
  </div>

  <!-- RINGKASAN STRUKTUR FILE -->
  <div class="card avoid-break" style="margin-top: 10px; background: #f8fafc;">
    <div class="card-title" style="margin-bottom: 6px;">
      <span>Daftar Berkas Utama Terkait CRUD & Firebase</span>
    </div>
    <table>
      <thead>
        <tr>
          <th style="width: 40%;">Lokasi Berkas</th>
          <th style="width: 25%;">Komponen Utama</th>
          <th>Fungsi Utama</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><code>lib/halaman1/database/database_helper.dart</code></td>
          <td>SQLite Helper (POS)</td>
          <td>Pusat CRUD offline transaksi, staf, shifts, dan expenses.</td>
        </tr>
        <tr>
          <td><code>lib/8SQFLITE_CRUD/database/db_helper.dart</code></td>
          <td>SQLite Helper (User)</td>
          <td>CRUD data user & registrasi login latihan.</td>
        </tr>
        <tr>
          <td><code>lib/halaman1/utils/menu_data_store.dart</code></td>
          <td>Menu DataStore</td>
          <td>CRUD katalog makanan, minuman, dan kategori.</td>
        </tr>
        <tr>
          <td><code>lib/firebase_options.dart</code> & <code>lib/main.dart</code></td>
          <td>Firebase Core Init</td>
          <td>Inisialisasi multi-platform & offline cache settings.</td>
        </tr>
        <tr>
          <td><code>lib/random_picker/picker_logic.dart</code></td>
          <td>FirebasePickerService</td>
          <td>Firestore Create/Read/Stream state & histori pemenang.</td>
        </tr>
        <tr>
          <td><code>lib/utils/button.dart</code></td>
          <td>FirebaseAsyncButton</td>
          <td>Widget tombol dengan tracking analitik Firestore.</td>
        </tr>
      </tbody>
    </table>
  </div>

  <!-- FOOTER -->
  <div class="footer">
    <div>Cashier Latte Project - Dokumentasi Teknis Sistem CRUD & Firebase</div>
    <div>Dicetak Secara Otomatis ke Format PDF</div>
  </div>

</body>
</html>
`;

const htmlFilePath = path.join(__dirname, 'Laporan_CRUD_dan_Firebase.html');
const pdfFilePath = path.join(__dirname, 'Laporan_CRUD_dan_Firebase.pdf');

fs.writeFileSync(htmlFilePath, htmlContent, 'utf8');
console.log('HTML file created at: ' + htmlFilePath);

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

console.log('Executing command to generate PDF...');
try {
  execSync(cmd, { stdio: 'inherit' });
  console.log('PDF successfully generated at: ' + pdfFilePath);
} catch (err) {
  console.error('Error generating PDF:', err);
  process.exit(1);
}
