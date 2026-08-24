const pptxgen = require('pptxgenjs');
const path = require('path');
const fs = require('fs');

async function createPresentation() {
  const pres = new pptxgen();
  pres.layout = 'LAYOUT_16x9'; // 10 x 5.625 inches
  pres.title = 'BGA Co. Cashier - Presentation & Pivot Analysis';
  pres.author = 'Bella Gita Asmara, S.E., M.M.';
  pres.company = 'BGA Co. / Project Cashier Latte';
  pres.subject = 'Aplikasi POS Kasir F&B Modern Berbasis Flutter & SQLite dengan Pivot Analysis Komprehensif';

  // Base Colors
  const C_DARK_BG = '2C160E';      // Deep espresso brown
  const C_LIGHT_BG = 'FAF7F2';     // Soft warm cream
  const C_PRIMARY = '442A22';      // Rich roast coffee
  const C_SECONDARY = '7D562D';    // Warm caramel
  const C_ACCENT = 'F0BD8B';       // Amber latte foam
  const C_SURFACE = 'FFFFFF';      // Pure card white
  const C_CARD_BG = 'F4ECE1';      // Soft sand beige
  const C_TEXT_MAIN = '1A1C19';    // Dark charcoal
  const C_TEXT_MUTED = '6B5E59';   // Muted warm grey
  const C_BORDER = 'E6DACB';       // Subtle border
  const C_GREEN = '1B5E20';        // Success green
  const C_GREEN_BG = 'E8F5E9';

  // Asset Paths
  const imgDir = path.join(__dirname, 'assets', 'images');
  const getImg = (name) => {
    const p = path.join(imgDir, name);
    return fs.existsSync(p) ? p : null;
  };

  const logoBGA = getImg('logobellacashier.png');
  const cartoonLogo = getImg('cartoon_logo.jpg');
  const cashierLogo = getImg('cashier_logo.png');
  const foodCroissant = getImg('food_croissant.jpg');
  const foodSourdough = getImg('food_sourdough.jpg');
  const foodTart = getImg('food_tart.jpg');
  const foodAvocado = getImg('food_avocado.jpg');
  const drinkLatte = getImg('drink_latte.jpg');
  const drinkMatcha = getImg('drink_matcha.jpg');
  const dessertCheesecake = getImg('dessert_cheesecake.jpg');
  const snackCookie = getImg('snack_cookie.jpg');
  const imgJakarta = getImg('Jakarta.jpg');
  const imgBandung = getImg('Bandung.jpg');
  const imgYogya = getImg('Yogyakarta.jpg');

  // Helper for adding standard header to light slides
  const addHeader = (slide, category, title, subtitle) => {
    // Top category badge
    slide.addShape(pres.ShapeType.roundRect, {
      x: 0.8, y: 0.45, w: 2.3, h: 0.32,
      fill: { color: C_SECONDARY },
      rectRadius: 0.15,
      line: { color: C_SECONDARY, width: 0 }
    });
    slide.addText(category.toUpperCase(), {
      x: 0.8, y: 0.45, w: 2.3, h: 0.32,
      fontSize: 9.5, bold: true, color: 'FFFFFF',
      align: 'center', fontFace: 'Calibri'
    });

    // Title
    slide.addText(title, {
      x: 0.8, y: 0.82, w: 8.4, h: 0.5,
      fontSize: 20, bold: true, color: C_PRIMARY,
      fontFace: 'Georgia'
    });

    // Subtitle
    if (subtitle) {
      slide.addText(subtitle, {
        x: 0.8, y: 1.32, w: 8.4, h: 0.3,
        fontSize: 11, color: C_TEXT_MUTED,
        fontFace: 'Calibri'
      });
    }

    // Divider Line
    slide.addShape(pres.ShapeType.line, {
      x: 0.8, y: 1.68, w: 8.4, h: 0,
      line: { color: C_BORDER, width: 1.2 }
    });

    // Footer
    slide.addText('BGA Co. Cashier System  •  Bella Gita Asmara, S.E., M.M.', {
      x: 0.8, y: 5.25, w: 7.0, h: 0.3,
      fontSize: 8.5, color: C_TEXT_MUTED, fontFace: 'Calibri'
    });
  };

  // Helper for Card Box
  const addCard = (slide, x, y, w, h, bg = C_SURFACE, border = C_BORDER) => {
    slide.addShape(pres.ShapeType.roundRect, {
      x, y, w, h,
      fill: { color: bg },
      line: { color: border, width: 1 },
      rectRadius: 0.12
    });
  };

  // ==========================================
  // SLIDE 1: COVER / TITLE SLIDE (Dark Luxury)
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_DARK_BG };

    // Background Accents
    slide.addShape(pres.ShapeType.ellipse, {
      x: -1.5, y: -1.5, w: 5.5, h: 5.5,
      fill: { color: '3D2015', transparency: 70 },
      line: { color: '3D2015', width: 0 }
    });
    slide.addShape(pres.ShapeType.ellipse, {
      x: 7.5, y: 2.8, w: 4.5, h: 4.5,
      fill: { color: '442A22', transparency: 60 },
      line: { color: '442A22', width: 0 }
    });

    // Pill Badge
    slide.addShape(pres.ShapeType.roundRect, {
      x: 0.9, y: 0.8, w: 3.2, h: 0.38,
      fill: { color: C_SECONDARY },
      rectRadius: 0.19,
      line: { color: C_ACCENT, width: 1 }
    });
    slide.addText('ENTERPRISE F&B POS SOLUTION', {
      x: 0.9, y: 0.8, w: 3.2, h: 0.38,
      fontSize: 9.5, bold: true, color: C_ACCENT,
      align: 'center', fontFace: 'Calibri'
    });

    // Main Title
    slide.addText('BGA Co. Cashier', {
      x: 0.85, y: 1.35, w: 5.8, h: 0.9,
      fontSize: 34, bold: true, color: 'FFFFFF',
      fontFace: 'Georgia'
    });
    slide.addText('Project Cashier Latte', {
      x: 0.9, y: 2.2, w: 5.8, h: 0.5,
      fontSize: 18, color: C_ACCENT, bold: true,
      fontFace: 'Calibri'
    });

    // Subtitle / Tagline
    slide.addText(
      'Sistem Kasir Point-of-Sale Terintegrasi Berbasis Flutter & SQLite:\nDari Fondasi Kurikulum Menjadi Solusi Manajemen Bisnis Cafe & UMKM Modern.',
      {
        x: 0.9, y: 2.8, w: 5.6, h: 0.9,
        fontSize: 11.5, color: 'D9CBC1', lineSpacing: 16,
        fontFace: 'Calibri'
      }
    );

    // Meta Badges
    const metaBadges = [
      { text: 'Flutter 3.x & Dart', x: 0.9 },
      { text: 'SQLite Local DB', x: 2.5 },
      { text: 'Material 3 & Themes', x: 4.1 },
    ];
    metaBadges.forEach(b => {
      slide.addShape(pres.ShapeType.roundRect, {
        x: b.x, y: 3.85, w: 1.5, h: 0.32,
        fill: { color: '442A22' },
        rectRadius: 0.08,
        line: { color: '5D3E33', width: 1 }
      });
      slide.addText(b.text, {
        x: b.x, y: 3.85, w: 1.5, h: 0.32,
        fontSize: 8.5, color: 'FFFFFF', align: 'center', fontFace: 'Calibri'
      });
    });

    // Author Info Card
    slide.addShape(pres.ShapeType.roundRect, {
      x: 0.9, y: 4.45, w: 5.6, h: 0.65,
      fill: { color: '3D2015', transparency: 30 },
      line: { color: '5D3E33', width: 1 },
      rectRadius: 0.1
    });
    slide.addText('Inisiator & Founder: Bella Gita Asmara, S.E., M.M.', {
      x: 1.1, y: 4.52, w: 5.2, h: 0.25,
      fontSize: 10.5, bold: true, color: 'FFFFFF', fontFace: 'Calibri'
    });
    slide.addText('Sistem Kasir V1.2.4  •  Tahun Rilis: 2026', {
      x: 1.1, y: 4.78, w: 5.2, h: 0.22,
      fontSize: 9, color: C_ACCENT, fontFace: 'Calibri'
    });

    // Right Side Brand Image / Logo Showcase
    if (cartoonLogo || logoBGA) {
      slide.addShape(pres.ShapeType.roundRect, {
        x: 6.9, y: 1.1, w: 2.4, h: 3.8,
        fill: { color: '3D2015' },
        line: { color: C_ACCENT, width: 2 },
        rectRadius: 0.2
      });
      const heroImg = cartoonLogo || logoBGA;
      slide.addImage({
        path: heroImg,
        x: 7.1, y: 1.35, w: 2.0, h: 2.0
      });
      slide.addText('BELLA CAFE & POS', {
        x: 6.9, y: 3.5, w: 2.4, h: 0.3,
        fontSize: 11, bold: true, color: 'FFFFFF', align: 'center', fontFace: 'Georgia'
      });
      slide.addText('"Making small businesses\neasier to manage."', {
        x: 7.0, y: 3.85, w: 2.2, h: 0.7,
        fontSize: 9, italic: true, color: C_ACCENT, align: 'center', fontFace: 'Calibri'
      });
    }
  }

  // ==========================================
  // SLIDE 2: EXECUTIVE SUMMARY & PROBLEM BACKGROUND
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'Executive Summary', 'Latar Belakang & Urgensi Digitalisasi Kasir', 'Transformasi operasional UMKM F&B dari pencatatan manual menuju ekosistem terpadu.');

    // Left Column: The Problem (Manual Era)
    addCard(slide, 0.8, 1.85, 4.0, 3.2, 'FFF5F5', 'FFCDD2');
    slide.addShape(pres.ShapeType.roundRect, {
      x: 1.0, y: 2.05, w: 1.6, h: 0.28,
      fill: { color: 'C62828' }, rectRadius: 0.08
    });
    slide.addText('TANTANGAN UMKM', {
      x: 1.0, y: 2.05, w: 1.6, h: 0.28,
      fontSize: 8.5, bold: true, color: 'FFFFFF', align: 'center', fontFace: 'Calibri'
    });
    slide.addText('Masalah Operasional Tradisional', {
      x: 1.0, y: 2.4, w: 3.6, h: 0.3,
      fontSize: 13, bold: true, color: 'B71C1C', fontFace: 'Georgia'
    });

    const problems = [
      'Pencatatan nota kertas rawan hilang, rusak, dan salah hitung nominal.',
      'Kesulitan menghitung omset harian dan pajak PPN secara cepat dan akurat.',
      'Jadwal shift staf cafe yang tumpang tindih tanpa sistem presensi terpusat.',
      'Software kasir komersial di pasaran umumnya mahal, lambat, dan butuh koneksi internet stabil.'
    ];
    problems.forEach((p, idx) => {
      slide.addText(`•  ${p}`, {
        x: 1.0, y: 2.75 + (idx * 0.52), w: 3.6, h: 0.48,
        fontSize: 9.5, color: '4A2323', lineSpacing: 13, fontFace: 'Calibri'
      });
    });

    // Right Column: The Solution (BGA Co. Cashier)
    addCard(slide, 5.2, 1.85, 4.0, 3.2, C_GREEN_BG, 'C8E6C9');
    slide.addShape(pres.ShapeType.roundRect, {
      x: 5.4, y: 2.05, w: 1.8, h: 0.28,
      fill: { color: C_GREEN }, rectRadius: 0.08
    });
    slide.addText('SOLUSI BGA CO.', {
      x: 5.4, y: 2.05, w: 1.8, h: 0.28,
      fontSize: 8.5, bold: true, color: 'FFFFFF', align: 'center', fontFace: 'Calibri'
    });
    slide.addText('Keunggulan Sistem Cashier', {
      x: 5.4, y: 2.4, w: 3.6, h: 0.3,
      fontSize: 13, bold: true, color: C_GREEN, fontFace: 'Georgia'
    });

    const solutions = [
      'Offline-First SQLite: Operasional kasir 100% andal tanpa bergantung koneksi internet.',
      'Manajemen Katalog Cepat: Tambah, ubah harga, dan foto menu F&B dalam hitungan detik.',
      'Smart Checkout & QRIS: Kalkulasi PPN 10%, kembalian tunai, & barcode pembayaran dinamis.',
      'Shift Calendar & Multi-Theme: Jadwal karyawan rapi serta 4 pilihan tema visual mewah.'
    ];
    solutions.forEach((s, idx) => {
      slide.addText(`✔  ${s}`, {
        x: 5.4, y: 2.75 + (idx * 0.52), w: 3.6, h: 0.48,
        fontSize: 9.5, color: '1B3820', lineSpacing: 13, fontFace: 'Calibri'
      });
    });
  }

  // ==========================================
  // SLIDE 3: LOGO PHILOSOPHY & BRAND IDENTITY
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'Brand Identity', 'Filosofi Logo & Nilai Visual BGA Co.', 'Representasi kehangatan, keramahan manusiawi, dan standar artisan modern.');

    // Left Box: Visual Logo Preview
    addCard(slide, 0.8, 1.85, 2.7, 3.2, C_SURFACE, C_BORDER);
    if (cartoonLogo || logoBGA) {
      slide.addImage({
        path: cartoonLogo || logoBGA,
        x: 1.15, y: 2.05, w: 2.0, h: 2.0
      });
    }
    slide.addText('BGA Co. Mascot Logo', {
      x: 0.9, y: 4.15, w: 2.5, h: 0.25,
      fontSize: 11, bold: true, color: C_PRIMARY, align: 'center', fontFace: 'Georgia'
    });
    slide.addText('Simbol Barista Ramah & Bersahabat', {
      x: 0.9, y: 4.42, w: 2.5, h: 0.4,
      fontSize: 8.5, color: C_TEXT_MUTED, align: 'center', fontFace: 'Calibri'
    });

    // Right Box: Filosofi Elemen & Warna
    addCard(slide, 3.7, 1.85, 5.5, 3.2, C_SURFACE, C_BORDER);

    // 4 Breakdown Cards
    const pillars = [
      {
        title: 'Karakter Kartun & Lingkaran Emas',
        desc: 'Mencerminkan pendekatan human-centric: kasir dan barista yang menyambut pelanggan dengan ramah, hangat, dan penuh empati.',
        tag: 'Human Connection'
      },
      {
        title: 'Cangkir Kopi & Uap Hangat (Lottie)',
        desc: 'Melambangkan dedikasi produk artisan yang segar, higienis, dan dibuat dengan penuh ketelitian di setiap seduhan.',
        tag: 'Fresh Artisan'
      },
      {
        title: 'Palet Espresso, Caramel & Cream',
        desc: 'Espresso (#442A22) melambangkan kestabilan sistem, Caramel (#7D562D) melambangkan keramahan, dan Cream (#FAF7F2) menandakan transparansi transaksi.',
        tag: 'Color Harmony'
      },
      {
        title: 'Tipografi Source Serif 4 + Work Sans',
        desc: 'Kombinasi klasik serif untuk keanggunan brand artisan dan clean sans-serif untuk kecepatan operasional kasir.',
        tag: 'Modern Typography'
      }
    ];

    pillars.forEach((p, idx) => {
      const px = 3.9 + ((idx % 2) * 2.65);
      const py = 2.0 + (Math.floor(idx / 2) * 1.45);
      addCard(slide, px, py, 2.5, 1.35, C_CARD_BG, C_BORDER);

      slide.addText(p.tag.toUpperCase(), {
        x: px + 0.1, y: py + 0.1, w: 2.3, h: 0.18,
        fontSize: 7.5, bold: true, color: C_SECONDARY, fontFace: 'Calibri'
      });
      slide.addText(p.title, {
        x: px + 0.1, y: py + 0.28, w: 2.3, h: 0.35,
        fontSize: 9.5, bold: true, color: C_PRIMARY, fontFace: 'Georgia'
      });
      slide.addText(p.desc, {
        x: px + 0.1, y: py + 0.65, w: 2.3, h: 0.62,
        fontSize: 8, color: C_TEXT_MUTED, lineSpacing: 11, fontFace: 'Calibri'
      });
    });
  }

  // ==========================================
  // SLIDE 4: CONTINUING INITIAL PROPOSAL
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'Evolusi Ide', 'Melanjutkan Fondasi Ide Proposal Awal', 'Perjalanan kurikulum pelatihan Flutter & SQLite menuju produk komersial mandiri.');

    // 3 Step Roadmap Cards
    const stages = [
      {
        num: '01',
        title: 'Fondasi Kurikulum & Modul Awal',
        sub: 'Tahap Pembelajaran Dasar (1Dart s.d. 8SQFLITE)',
        points: [
          'Eksplorasi fundamental Dart, widget Flutter, dan validasi input.',
          'Penyimpanan lokal dasar dengan SharedPreferences.',
          'Latihan CRUD awal: Tabel siswa & database ppkd.db sederhana.',
          'Model data statis dengan skema tabel minimalis.'
        ]
      },
      {
        num: '02',
        title: 'Inisiasi Ide Kasir Cafe (Fondasi Project)',
        sub: 'Tahap Transisi (9FondasiProject)',
        points: [
          'Pengenalan tema warna coffee (app_colors, app_theme).',
          'Konseptualisasi alur kasir F&B untuk Bella Gita Asmara.',
          'Pemisahan komponen arsitektur modular & perancangan database.',
          'Rencana migrasi dari sistem siswa menjadi POS terpadu.'
        ]
      },
      {
        num: '03',
        title: 'Realisasi BGA Co. Cashier POS',
        sub: 'Tahap Production-Ready (lib/halaman1)',
        points: [
          '27+ Layar antarmuka lengkap dengan Material 3 Design.',
          'Katalog dinamis (Food, Drink, Snack) + Image Picker.',
          'Transaksi multi-channel (Cash, QRIS countdown, E-wallet).',
          'Manajemen jadwal shift staf & multi-theme live switching.'
        ]
      }
    ];

    stages.forEach((st, idx) => {
      const sx = 0.8 + (idx * 2.85);
      addCard(slide, sx, 1.85, 2.7, 3.2, C_SURFACE, idx === 2 ? C_SECONDARY : C_BORDER);

      // Number badge
      slide.addShape(pres.ShapeType.ellipse, {
        x: sx + 0.15, y: 2.0, w: 0.45, h: 0.45,
        fill: { color: idx === 2 ? C_PRIMARY : C_CARD_BG },
        line: { color: C_SECONDARY, width: 1 }
      });
      slide.addText(st.num, {
        x: sx + 0.15, y: 2.0, w: 0.45, h: 0.45,
        fontSize: 11, bold: true, color: idx === 2 ? 'FFFFFF' : C_PRIMARY,
        align: 'center', fontFace: 'Calibri'
      });

      slide.addText(st.title, {
        x: sx + 0.7, y: 2.0, w: 1.85, h: 0.45,
        fontSize: 10.5, bold: true, color: C_PRIMARY, fontFace: 'Georgia'
      });
      slide.addText(st.sub, {
        x: sx + 0.15, y: 2.5, w: 2.4, h: 0.3,
        fontSize: 8, color: C_SECONDARY, bold: true, fontFace: 'Calibri'
      });

      st.points.forEach((pt, pIdx) => {
        slide.addText(`•  ${pt}`, {
          x: sx + 0.15, y: 2.85 + (pIdx * 0.52), w: 2.4, h: 0.48,
          fontSize: 8.5, color: C_TEXT_MAIN, lineSpacing: 11, fontFace: 'Calibri'
        });
      });
    });
  }

  // ==========================================
  // SLIDE 5: PIVOT ANALYSIS 1 - STRATEGIC TRANSFORMATION MATRIX
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'Pivot Analysis 1', 'Matriks Transformasi Strategis dari Proposal ke Realisasi', 'Perbandingan komprehensif antara lingkup proposal awal vs ekosistem POS yang terbangun.');

    const tableHeaders = [
      { text: 'Dimensi Transformasi', options: { bold: true, fill: C_PRIMARY, color: 'FFFFFF', fontSize: 9.5 } },
      { text: 'Proposal / Kurikulum Awal', options: { bold: true, fill: C_PRIMARY, color: 'FFFFFF', fontSize: 9.5 } },
      { text: 'Realisasi Final BGA Co. POS', options: { bold: true, fill: C_SECONDARY, color: 'FFFFFF', fontSize: 9.5 } },
      { text: 'Dampak & Nilai Tambah', options: { bold: true, fill: C_PRIMARY, color: 'FFFFFF', fontSize: 9.5 } }
    ];

    const rows = [
      [
        'Domain & Target Bisnis',
        'Latihan Data Siswa Akademik',
        'Enterprise F&B Point-of-Sale (POS)',
        'Menciptakan nilai bisnis nyata bagi UMKM & Cafe'
      ],
      [
        'Katalog & Produk',
        'Tidak ada katalog',
        'Multi-kategori (Food, Drink, Snack) + Image Picker',
        'Operasional visual & penataan menu profesional'
      ],
      [
        'Transaksi & Kasir',
        'Tidak ada alur belanja',
        'Keranjang live, PPN 10%, Diskon, & Kembalian',
        'Otomatisasi hitung cepat, cegah selisih kas'
      ],
      [
        'Metode Pembayaran',
        'Tidak ada pembayaran',
        'Tunai, QRIS Dinamis + Timer, E-Wallet, Kartu',
        'Mendukung gaya hidup transaksi digital non-tunai'
      ],
      [
        'Manajemen Karyawan',
        'Tidak ada manajemen staf',
        'Kalender shift bulanan & status absensi',
        'Transparansi pembagian jam kerja dan presensi'
      ],
      [
        'Tema & Aksesibilitas',
        '1 Tema Statis / 1 Bahasa',
        '4 Tema Dinamis, Dark Mode, 3 Bahasa (ID/EN/ZH)',
        'Kenyamanan mata, aksesibilitas, dan kesiapan global'
      ]
    ];

    const formattedRows = [
      tableHeaders,
      ...rows.map((r, idx) => r.map((c, cIdx) => ({
        text: c,
        options: {
          fontSize: 8.5,
          color: cIdx === 2 ? C_PRIMARY : C_TEXT_MAIN,
          bold: cIdx === 0 || cIdx === 2,
          fill: idx % 2 === 0 ? C_SURFACE : C_CARD_BG
        }
      })))
    ];

    slide.addTable(formattedRows, {
      x: 0.8, y: 1.85, w: 8.4,
      colW: [1.6, 2.1, 2.5, 2.2],
      border: { color: C_BORDER, width: 0.8 },
      autoPage: false
    });
  }

  // ==========================================
  // SLIDE 6: PIVOT ANALYSIS 2 - DATA SCHEMA & ARCHITECTURE PIVOT
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'Pivot Analysis 2', 'Evolusi Skema Data, Database & Arsitektur Reaktif', 'Perubahan fundamental pada struktur persistensi SQLite dan state management.');

    // Left Box: Before (Basic Student Table)
    addCard(slide, 0.8, 1.85, 4.0, 3.2, 'FFF5F5', 'FFCDD2');
    slide.addShape(pres.ShapeType.roundRect, {
      x: 1.0, y: 2.05, w: 2.0, h: 0.28,
      fill: { color: 'C62828' }, rectRadius: 0.06
    });
    slide.addText('SEBELUM (ppkd.db v1/v2)', {
      x: 1.0, y: 2.05, w: 2.0, h: 0.28,
      fontSize: 8.5, bold: true, color: 'FFFFFF', align: 'center', fontFace: 'Calibri'
    });
    slide.addText('Skema Sederhana Data Siswa', {
      x: 1.0, y: 2.4, w: 3.6, h: 0.28,
      fontSize: 12, bold: true, color: 'B71C1C', fontFace: 'Georgia'
    });

    const beforeData = [
      'Tabel siswa (id, nama, kelas): 3 Kolom statis tanpa relasi komersial.',
      'Tabel users v1 (id, email, password): Login statis tanpa data profil kasir.',
      'State Management: SetState lokal sederhana tanpa sinkronisasi antar-halaman.',
      'Alur Data: Satu arah (One-way static rendering), tanpa model dinamis keranjang belanja.'
    ];
    beforeData.forEach((bd, idx) => {
      slide.addText(`❌  ${bd}`, {
        x: 1.0, y: 2.75 + (idx * 0.52), w: 3.6, h: 0.48,
        fontSize: 8.8, color: '4A2323', lineSpacing: 12, fontFace: 'Calibri'
      });
    });

    // Right Box: After (Enterprise POS Engine)
    addCard(slide, 5.2, 1.85, 4.0, 3.2, C_GREEN_BG, 'C8E6C9');
    slide.addShape(pres.ShapeType.roundRect, {
      x: 5.4, y: 2.05, w: 2.2, h: 0.28,
      fill: { color: C_GREEN }, rectRadius: 0.06
    });
    slide.addText('SESUDAH (ppkd.db v5 + Store)', {
      x: 5.4, y: 2.05, w: 2.2, h: 0.28,
      fontSize: 8.5, bold: true, color: 'FFFFFF', align: 'center', fontFace: 'Calibri'
    });
    slide.addText('Ekosistem POS Reaktif & Terpadu', {
      x: 5.4, y: 2.4, w: 3.6, h: 0.28,
      fontSize: 12, bold: true, color: C_GREEN, fontFace: 'Georgia'
    });

    const afterData = [
      'Tabel users v5: Multi-field (id, email, password, nomor_hp, nama, asalKota) + Auto-seed KASIR01.',
      'Reactive UserDataStore Singleton: Sinkronisasi nama kasir aktif live ke banner Home di bawah nama Cafe / Kingdom Cafe.',
      'Dynamic F&B Catalog State: List & Map reaktif untuk Food, Drink, Snack dengan dukungan byte image upload.',
      'Real-Time Cart Engine: Kalkulasi PPN 10%, diskon, multi-channel payment, & nomor faktur #INV otomatis.'
    ];
    afterData.forEach((ad, idx) => {
      slide.addText(`✔  ${ad}`, {
        x: 5.4, y: 2.75 + (idx * 0.52), w: 3.6, h: 0.48,
        fontSize: 8.8, color: '1B3820', lineSpacing: 12, fontFace: 'Calibri'
      });
    });
  }

  // ==========================================
  // SLIDE 7: PIVOT ANALYSIS 3 - DATA-DRIVEN OPERATIONAL METRICS
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'Pivot Analysis 3', 'Analisis Data Kuantitatif & Metrik Dampak Operasional', 'Tolok ukur efisiensi sebelum dan sesudah penerapan sistem kasir BGA Co.');

    const metricHeaders = [
      { text: 'Parameter Operasional', options: { bold: true, fill: C_PRIMARY, color: 'FFFFFF', fontSize: 9.5 } },
      { text: 'Pencatatan Manual / Awal', options: { bold: true, fill: '7F1D1D', color: 'FFFFFF', fontSize: 9.5 } },
      { text: 'Sistem POS BGA Co.', options: { bold: true, fill: C_GREEN, color: 'FFFFFF', fontSize: 9.5 } },
      { text: 'Efisiensi & Peningkatan', options: { bold: true, fill: C_SECONDARY, color: 'FFFFFF', fontSize: 9.5 } }
    ];

    const metricRows = [
      [
        'Kecepatan Layanan Transaksi',
        '3 - 5 Menit per nota',
        '< 20 Detik per transaksi',
        '+85% Lebih Cepat (Zero Antrean)'
      ],
      [
        'Akurasi Hitung Kas & Pajak',
        '~12% Risiko selisih hitung',
        '100% Akurat (Otomatis PPN 10%)',
        '100% Eliminasi Selisih Kas'
      ],
      [
        'Kecepatan Perubahan Menu',
        '2 - 3 Hari cetak ulang buku',
        '< 5 Detik via Image Picker',
        'Instant Update Real-time'
      ],
      [
        'Kanal Metode Pembayaran',
        'Hanya Tunai (1 Saluran)',
        'Tunai, QRIS, E-Wallet, Kartu (4+)',
        '+300% Fleksibilitas Pembayaran'
      ],
      [
        'Transparansi Shift Staf',
        'Catatan kertas mudah hilang',
        'Kalender interaktif bulanan',
        '0% Tabrakan Jadwal Kerja'
      ],
      [
        'Penyelarasan Profil Kasir',
        'Teks statis terpisah',
        'Reactive UserDataStore Live',
        '100% Tersinkronisasi ke Home'
      ]
    ];

    const formattedMetrics = [
      metricHeaders,
      ...metricRows.map((r, idx) => r.map((c, cIdx) => ({
        text: c,
        options: {
          fontSize: 8.5,
          color: cIdx === 2 ? C_GREEN : (cIdx === 3 ? C_PRIMARY : C_TEXT_MAIN),
          bold: cIdx === 0 || cIdx === 2 || cIdx === 3,
          fill: idx % 2 === 0 ? C_SURFACE : C_CARD_BG
        }
      })))
    ];

    slide.addTable(formattedMetrics, {
      x: 0.8, y: 1.85, w: 8.4,
      colW: [2.0, 2.0, 2.1, 2.3],
      border: { color: C_BORDER, width: 0.8 },
      autoPage: false
    });
  }

  // ==========================================
  // SLIDE 8: TECHNICAL ARCHITECTURE & STACK
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'Arsitektur Sistem', 'Deskripsi Teknis & Pola Desain Perangkat Lunak', 'Struktur berlapis modular yang mengutamakan performa tinggi dan keandalan lokal.');

    // 4 Architectural Layers
    const layers = [
      {
        layer: 'Presentation Layer',
        tag: 'FLUTTER VIEWS & WIDGETS',
        tech: 'Material 3 • GoogleFonts • Lottie • VideoPlayer',
        desc: '27+ File Screen responsif, Custom Animated Logo, Dialog interaktif, SnackBars kontekstual, dan transisi mulus.'
      },
      {
        layer: 'Reactive State & Utils Layer',
        tag: 'VALUE NOTIFIERS & THEME ENGINE',
        tech: 'ValueNotifier • ValueListenableBuilder • AppTheme • AppLocalization',
        desc: 'Manajemen state reaktif tanpa overhead, mendukung pergantian tema live, penskalaan teks, dan lokalisasi 3 bahasa.'
      },
      {
        layer: 'Data & Persistence Layer',
        tag: 'SQLITE & SHARED PREFERENCES',
        tech: 'sqflite (ppkd.db v5) • SharedPreferences • UserDataStore',
        desc: 'Penyimpanan lokal handal (offline-first), Singleton DataBaseHelper, migrasi skema tabel aman, dan sesi kasir.'
      },
      {
        layer: 'Cross-Platform Engine',
        tech: 'Android • iOS • Windows Desktop (video_player_win) • Web Showcase',
        tag: 'MULTI-PLATFORM COMPILATION',
        desc: 'Satu basis kode Dart untuk deploy multi-perangkat (tablet kasir Android, POS Windows Desktop, hingga Web Preview).'
      }
    ];

    layers.forEach((l, idx) => {
      const ly = 1.85 + (idx * 0.8);
      addCard(slide, 0.8, ly, 8.4, 0.72, C_SURFACE, C_BORDER);

      // Left Tag
      slide.addShape(pres.ShapeType.roundRect, {
        x: 0.95, y: ly + 0.12, w: 2.1, h: 0.48,
        fill: { color: C_CARD_BG },
        line: { color: C_SECONDARY, width: 1 },
        rectRadius: 0.08
      });
      slide.addText(l.tag, {
        x: 0.95, y: ly + 0.16, w: 2.1, h: 0.2,
        fontSize: 7, bold: true, color: C_SECONDARY, align: 'center', fontFace: 'Calibri'
      });
      slide.addText(l.layer, {
        x: 0.95, y: ly + 0.34, w: 2.1, h: 0.22,
        fontSize: 9.5, bold: true, color: C_PRIMARY, align: 'center', fontFace: 'Georgia'
      });

      // Middle Tech
      slide.addText(l.tech, {
        x: 3.2, y: ly + 0.12, w: 5.8, h: 0.22,
        fontSize: 9, bold: true, color: C_SECONDARY, fontFace: 'Calibri'
      });
      // Description
      slide.addText(l.desc, {
        x: 3.2, y: ly + 0.34, w: 5.8, h: 0.32,
        fontSize: 8.5, color: C_TEXT_MUTED, fontFace: 'Calibri'
      });
    });
  }

  // ==========================================
  // SLIDE 9: DESIGN SYSTEM & MULTI-THEME ENGINE
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'Design System', 'Multi-Theme Engine & Aksesibilitas Visual', 'Fleksibilitas tampilan dengan 4 palet bertema kafe, mode gelap, dan font scaling.');

    // 4 Theme Palettes Cards
    const themes = [
      {
        name: 'Coffee Caramel',
        sub: 'Signature Warm Roast',
        colorHex: '442A22',
        accentHex: '7D562D',
        bgHex: 'FAF7F2',
        desc: 'Palet bawaan bernuansa kehangatan biji kopi sangrai dan saus karamel manis.'
      },
      {
        name: 'Emerald Matcha',
        sub: 'Botanical Fresh Mint',
        colorHex: '1A332B',
        accentHex: '2D5547',
        bgHex: 'F3F9F5',
        desc: 'Nuansa hijau daun teh matcha Jepang yang segar, menenangkan, dan alami.'
      },
      {
        name: 'Berry Velvet',
        sub: 'Plum & Rose Elegance',
        colorHex: '42243A',
        accentHex: '542E4B',
        bgHex: 'FAF4F7',
        desc: 'Kombinasi berry liar dan beludru anggun untuk cafe berkonsep pastry & tea house.'
      },
      {
        name: 'Midnight Obsidian',
        sub: 'Modern Slate & Gold',
        colorHex: '1F2937',
        accentHex: '374151',
        bgHex: 'F8FAFC',
        desc: 'Monokrom gelap mutakhir dengan kontras tinggi untuk suasana bar modern.'
      }
    ];

    themes.forEach((t, idx) => {
      const tx = 0.8 + (idx * 2.15);
      addCard(slide, tx, 1.85, 2.05, 1.9, C_SURFACE, C_BORDER);

      // Color Swatch Bar
      slide.addShape(pres.ShapeType.roundRect, {
        x: tx + 0.15, y: 2.0, w: 1.75, h: 0.35,
        fill: { color: t.colorHex },
        rectRadius: 0.06
      });
      slide.addText(t.name, {
        x: tx + 0.15, y: 2.45, w: 1.75, h: 0.25,
        fontSize: 10.5, bold: true, color: C_PRIMARY, fontFace: 'Georgia'
      });
      slide.addText(t.sub, {
        x: tx + 0.15, y: 2.7, w: 1.75, h: 0.2,
        fontSize: 7.5, bold: true, color: C_SECONDARY, fontFace: 'Calibri'
      });
      slide.addText(t.desc, {
        x: tx + 0.15, y: 2.92, w: 1.75, h: 0.75,
        fontSize: 8, color: C_TEXT_MUTED, lineSpacing: 11, fontFace: 'Calibri'
      });
    });

    // Bottom Accessibility Row: Dark Mode & Font Scaling
    addCard(slide, 0.8, 3.9, 4.15, 1.2, C_SURFACE, C_BORDER);
    slide.addText('DARK MODE & LIGHT MODE ADAPTIVE', {
      x: 1.0, y: 4.0, w: 3.7, h: 0.2,
      fontSize: 8.5, bold: true, color: C_SECONDARY, fontFace: 'Calibri'
    });
    slide.addText('Mode Gelap Nyaman untuk Shift Malam', {
      x: 1.0, y: 4.22, w: 3.7, h: 0.25,
      fontSize: 10.5, bold: true, color: C_PRIMARY, fontFace: 'Georgia'
    });
    slide.addText('Mendukung sakelar instan (Light, Dark, System) yang mereduksi ketegangan mata kasir pada pencahayaan redup.', {
      x: 1.0, y: 4.48, w: 3.7, h: 0.5,
      fontSize: 8, color: C_TEXT_MUTED, fontFace: 'Calibri'
    });

    addCard(slide, 5.05, 3.9, 4.15, 1.2, C_SURFACE, C_BORDER);
    slide.addText('DYNAMIC TEXT SCALER (0.85x - 1.18x)', {
      x: 5.25, y: 4.0, w: 3.7, h: 0.2,
      fontSize: 8.5, bold: true, color: C_SECONDARY, fontFace: 'Calibri'
    });
    slide.addText('Aksesibilitas Skala Teks Kasir', {
      x: 5.25, y: 4.22, w: 3.7, h: 0.25,
      fontSize: 10.5, bold: true, color: C_PRIMARY, fontFace: 'Georgia'
    });
    slide.addText('Fleksibilitas ukuran font untuk tablet kasir jarak jauh: Ringkas (0.85x), Standar (1.0x), hingga Ramah Lansia (1.18x).', {
      x: 5.25, y: 4.48, w: 3.7, h: 0.5,
      fontSize: 8, color: C_TEXT_MUTED, fontFace: 'Calibri'
    });
  }

  // ==========================================
  // SLIDE 10: SQLITE DATABASE SCHEMA & DATA MODEL
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'Database & Persistence', 'Skema SQLite (ppkd.db v5) & Model Relasi Data', 'Penyimpanan lokal yang terenkapsulasi dengan Singleton DataBaseHelper.');

    // Left Column: Table users
    addCard(slide, 0.8, 1.85, 4.1, 3.2, C_SURFACE, C_BORDER);
    slide.addShape(pres.ShapeType.roundRect, {
      x: 1.0, y: 2.0, w: 1.8, h: 0.28,
      fill: { color: C_PRIMARY }, rectRadius: 0.06
    });
    slide.addText('TABEL: users', {
      x: 1.0, y: 2.0, w: 1.8, h: 0.28,
      fontSize: 8.5, bold: true, color: 'FFFFFF', align: 'center', fontFace: 'Calibri'
    });
    slide.addText('Data Akun Kasir & Profil', {
      x: 1.0, y: 2.35, w: 3.7, h: 0.25,
      fontSize: 11, bold: true, color: C_PRIMARY, fontFace: 'Georgia'
    });

    const userCols = [
      { col: 'id', type: 'INTEGER PK AUTOINCREMENT', note: 'Kunci primer identifikasi pengguna' },
      { col: 'email', type: 'TEXT UNIQUE', note: 'Username / Email kasir (mis. KASIR01)' },
      { col: 'password', type: 'TEXT', note: 'Kata sandi akun terenkripsi' },
      { col: 'nomor_hp', type: 'TEXT', note: 'Kontak kasir (login via HP didukung)' },
      { col: 'nama', type: 'TEXT', note: 'Nama lengkap kasir / manager' },
      { col: 'asalKota', type: 'TEXT', note: 'Lokasi cabang cabang toko (mis. Jakarta)' }
    ];

    userCols.forEach((c, idx) => {
      const cy = 2.65 + (idx * 0.38);
      slide.addText(`• ${c.col} (${c.type}): ${c.note}`, {
        x: 1.0, y: cy, w: 3.7, h: 0.35,
        fontSize: 8, color: C_TEXT_MAIN, fontFace: 'Calibri'
      });
    });

    // Right Column: DatabaseHelper Logic & Default Seed
    addCard(slide, 5.1, 1.85, 4.1, 3.2, C_CARD_BG, C_BORDER);
    slide.addShape(pres.ShapeType.roundRect, {
      x: 5.3, y: 2.0, w: 2.2, h: 0.28,
      fill: { color: C_SECONDARY }, rectRadius: 0.06
    });
    slide.addText('SINGLETON HELPER LOGIC', {
      x: 5.3, y: 2.0, w: 2.2, h: 0.28,
      fontSize: 8.5, bold: true, color: 'FFFFFF', align: 'center', fontFace: 'Calibri'
    });
    slide.addText('Fitur Keamanan & Migrasi', {
      x: 5.3, y: 2.35, w: 3.7, h: 0.25,
      fontSize: 11, bold: true, color: C_PRIMARY, fontFace: 'Georgia'
    });

    const dbFeatures = [
      { title: 'Auto-Seed Default Kasir', desc: 'Saat instalasi pertama, otomatis membuat akun bawaan "KASIR01" (Pass: 123) untuk kemudahan demo & onboarding.' },
      { title: 'Multi-Field Authentication', desc: 'Query login fleksibel: mendukung autentikasi via Email ATAU Nomor Handphone dengan satu kolom input.' },
      { title: 'Schema Auto-Migration (v5)', desc: 'Menjamin kompatibilitas data lama dengan ALTER TABLE otomatis saat naik ke versi database 5.' },
      { title: 'Model Enkapsulasi Aman', desc: 'Metode toMap() dan fromMap() pada UserModelSQL mencegah injection dan inkonsistensi tipe data.' }
    ];

    dbFeatures.forEach((df, idx) => {
      const dfy = 2.65 + (idx * 0.58);
      slide.addText(df.title, {
        x: 5.3, y: dfy, w: 3.7, h: 0.2,
        fontSize: 8.5, bold: true, color: C_PRIMARY, fontFace: 'Georgia'
      });
      slide.addText(df.desc, {
        x: 5.3, y: dfy + 0.18, w: 3.7, h: 0.38,
        fontSize: 7.8, color: C_TEXT_MUTED, lineSpacing: 10.5, fontFace: 'Calibri'
      });
    });
  }

  // ==========================================
  // SLIDE 11: HOW THE APPLICATION WORKS (USER JOURNEY)
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'Cara Kerja Aplikasi', 'Alur Pengoperasian Sistem (End-to-End User Flow)', 'Langkah sistematis dari login kasir hingga penyelesaian transaksi pelanggan.');

    const steps = [
      { num: '1', title: 'Splash & Setup', desc: 'Video player animasi, inisialisasi DB lokal & tema.' },
      { num: '2', title: 'Login / Register', desc: 'Verifikasi akun kasir via SQLite & simpan session.' },
      { num: '3', title: 'Pilih Toko & Shift', desc: 'Pilih lokasi cabang (Jakarta/Bandung) & shift dinas.' },
      { num: '4', title: 'Pilih Menu & Cart', desc: 'Katalog Food, Drink, Snack + quantity modifier.' },
      { num: '5', title: 'Checkout & Pajak', desc: 'Kalkulasi PPN 10%, kupon promo, & uang kembalian.' },
      { num: '6', title: 'Bayar & Struk', desc: 'QRIS countdown / Tunai + Cetak/Bagikan Invoice.' }
    ];

    steps.forEach((s, idx) => {
      const sx = 0.8 + ((idx % 3) * 2.85);
      const sy = 1.85 + (Math.floor(idx / 3) * 1.6);
      addCard(slide, sx, sy, 2.7, 1.45, C_SURFACE, C_BORDER);

      // Step Number Bubble
      slide.addShape(pres.ShapeType.ellipse, {
        x: sx + 0.15, y: sy + 0.15, w: 0.38, h: 0.38,
        fill: { color: C_PRIMARY }
      });
      slide.addText(s.num, {
        x: sx + 0.15, y: sy + 0.15, w: 0.38, h: 0.38,
        fontSize: 10, bold: true, color: 'FFFFFF', align: 'center', fontFace: 'Calibri'
      });

      slide.addText(s.title, {
        x: sx + 0.62, y: sy + 0.15, w: 1.95, h: 0.35,
        fontSize: 10.5, bold: true, color: C_PRIMARY, fontFace: 'Georgia'
      });
      slide.addText(s.desc, {
        x: sx + 0.15, y: sy + 0.58, w: 2.4, h: 0.75,
        fontSize: 8.5, color: C_TEXT_MUTED, lineSpacing: 12, fontFace: 'Calibri'
      });
    });
  }

  // ==========================================
  // SLIDE 12: CRUD FLOW 1 - MENU MANAGEMENT
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'Alur CRUD 1', 'CRUD Manajemen Menu & Katalog Produk', 'Operasi Create, Read, Update, Delete produk F&B secara visual dan instan.');

    const crudMenu = [
      {
        op: 'CREATE',
        title: 'Tambah Menu Baru',
        color: C_GREEN,
        desc: 'Form tambah menu dengan input Nama, Harga, Kategori (Food/Drink/Snack), Deskripsi, serta unggah foto makanan via ImagePicker (kamera/galeri).'
      },
      {
        op: 'READ',
        title: 'Katalog & Pencarian',
        color: '0D47A1',
        desc: 'Tampilan grid produk interaktif berdasar tab kategori dengan fitur pencarian real-time (instant search filter) dan badge ketersediaan stok.'
      },
      {
        op: 'UPDATE',
        title: 'Edit Detail & Harga',
        color: 'E65100',
        desc: 'Modal edit cepat untuk mengubah harga jual, deskripsi resep, mengganti foto makanan, dan mengatur status keaktifan menu tanpa refresh.'
      },
      {
        op: 'DELETE',
        title: 'Hapus Menu Aman',
        color: 'C62828',
        desc: 'Fitur penghapusan item dengan dialog konfirmasi keselamatan (safe delete dialog) untuk mencegah ketidaksengajaan kasir saat jam sibuk.'
      }
    ];

    crudMenu.forEach((cm, idx) => {
      const cx = 0.8 + ((idx % 2) * 4.3);
      const cy = 1.85 + (Math.floor(idx / 2) * 1.6);
      addCard(slide, cx, cy, 4.1, 1.45, C_SURFACE, C_BORDER);

      // Badge Operation
      slide.addShape(pres.ShapeType.roundRect, {
        x: cx + 0.15, y: cy + 0.15, w: 1.2, h: 0.28,
        fill: { color: cm.color }, rectRadius: 0.06
      });
      slide.addText(cm.op, {
        x: cx + 0.15, y: cy + 0.15, w: 1.2, h: 0.28,
        fontSize: 8.5, bold: true, color: 'FFFFFF', align: 'center', fontFace: 'Calibri'
      });

      slide.addText(cm.title, {
        x: cx + 1.45, y: cy + 0.15, w: 2.5, h: 0.28,
        fontSize: 11, bold: true, color: C_PRIMARY, fontFace: 'Georgia'
      });
      slide.addText(cm.desc, {
        x: cx + 0.15, y: cy + 0.52, w: 3.8, h: 0.82,
        fontSize: 8.5, color: C_TEXT_MUTED, lineSpacing: 12, fontFace: 'Calibri'
      });
    });
  }

  // ==========================================
  // SLIDE 13: CRUD FLOW 2 - USER & CASHIER AUTH
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'Alur CRUD 2', 'CRUD Manajemen Akun Kasir & Pengguna', 'Pengelolaan data kredensial dan hak akses kasir pada database SQLite.');

    const crudUser = [
      {
        op: 'CREATE',
        title: 'Registrasi Kasir / User Baru',
        desc: 'Form pendaftaran dengan validasi lengkap: ID Kasir/Email unik, Nomor Handphone, Asal Kota, Nama Lengkap, & Konfirmasi Password.'
      },
      {
        op: 'READ',
        title: 'Autentikasi & Daftar Admin',
        desc: 'Validasi login ganda (email atau nomor HP), pengecekan password di SQLite, serta panel DataUserScreen untuk melihat seluruh akun terdaftar.'
      },
      {
        op: 'UPDATE',
        title: 'Edit Profil & Ganti Password',
        desc: 'Layar EditPersonalInfoScreen & ChangePasswordScreen untuk memperbarui nama, nomor kontak, kota cabang, dan pembaruan password aman.'
      },
      {
        op: 'DELETE',
        title: 'Hapus Akses Kasir',
        desc: 'Fungsi deleteUser(id) pada DataBaseHelper untuk menghapus akun kasir yang sudah tidak aktif dari basis data lokal secara permanen.'
      }
    ];

    crudUser.forEach((cu, idx) => {
      const cx = 0.8 + (idx * 2.15);
      addCard(slide, cx, 1.85, 2.05, 3.2, C_SURFACE, C_BORDER);

      slide.addShape(pres.ShapeType.roundRect, {
        x: cx + 0.15, y: 2.0, w: 1.75, h: 0.28,
        fill: { color: C_SECONDARY }, rectRadius: 0.06
      });
      slide.addText(cu.op, {
        x: cx + 0.15, y: 2.0, w: 1.75, h: 0.28,
        fontSize: 8.5, bold: true, color: 'FFFFFF', align: 'center', fontFace: 'Calibri'
      });

      slide.addText(cu.title, {
        x: cx + 0.15, y: 2.38, w: 1.75, h: 0.45,
        fontSize: 10, bold: true, color: C_PRIMARY, fontFace: 'Georgia'
      });
      slide.addText(cu.desc, {
        x: cx + 0.15, y: 2.9, w: 1.75, h: 2.0,
        fontSize: 8.2, color: C_TEXT_MUTED, lineSpacing: 12, fontFace: 'Calibri'
      });
    });
  }

  // ==========================================
  // SLIDE 14: CRUD FLOW 3 - STAFF & SHIFT MANAGEMENT
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'Alur CRUD 3', 'CRUD Manajemen Shift & Kalender Staf', 'Penjadwalan dinas kerja karyawan, alokasi jam, dan rekapitulasi kehadiran harian.');

    const shiftCards = [
      {
        tag: 'KALENDER BULANAN',
        title: 'Interactive Shift Calendar',
        desc: 'Kalender visual berbasis bulan/tahun dengan indikator tanggal dinas aktif, filter hari, dan pemilih tanggal showDatePicker bawaan Flutter.'
      },
      {
        tag: 'PENUGASAN SHIFT',
        title: 'Alokasi Shift Pagi & Sore',
        desc: 'Pembagian jam kerja transparan: Shift Pagi (07:00 - 15:00) dan Shift Sore (15:00 - 23:00) dengan daftar nama staf bertugas di setiap shift.'
      },
      {
        tag: 'MANAJEMEN PRESENSI',
        title: 'Status Kehadiran Karyawan',
        desc: 'Pencatatan status real-time untuk setiap staf: Hadir (badge hijau), Izin (kuning), Sakit (oranye), atau Libur (abu-abu).'
      },
      {
        tag: 'TAMBAH & HAPUS STAF',
        title: 'AddStaffScreen & Role',
        desc: 'Form tambah staf baru dengan jabatan (Head Barista, Cashier, Pastry Chef), nomor telepon darurat, dan opsi hapus penugasan staf.'
      }
    ];

    shiftCards.forEach((sc, idx) => {
      const sx = 0.8 + ((idx % 2) * 4.3);
      const sy = 1.85 + (Math.floor(idx / 2) * 1.6);
      addCard(slide, sx, sy, 4.1, 1.45, C_SURFACE, C_BORDER);

      slide.addText(sc.tag, {
        x: sx + 0.15, y: sy + 0.15, w: 3.8, h: 0.2,
        fontSize: 8, bold: true, color: C_SECONDARY, fontFace: 'Calibri'
      });
      slide.addText(sc.title, {
        x: sx + 0.15, y: sy + 0.35, w: 3.8, h: 0.28,
        fontSize: 11, bold: true, color: C_PRIMARY, fontFace: 'Georgia'
      });
      slide.addText(sc.desc, {
        x: sx + 0.15, y: sy + 0.65, w: 3.8, h: 0.72,
        fontSize: 8.5, color: C_TEXT_MUTED, lineSpacing: 12, fontFace: 'Calibri'
      });
    });
  }

  // ==========================================
  // SLIDE 15: CHECKOUT & QRIS TRANSACTION FLOW
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'Alur Transaksi', 'Alur Keranjang, Checkout & Pembayaran QRIS', 'Kalkulasi finansial presisi, dukungan multi-pembayaran, dan struk digital.');

    // 3 Workflow Steps
    const flowSteps = [
      {
        title: '1. Penyusunan Pesanan & Cart',
        points: [
          'Tambah item makanan & minuman ke keranjang belanja.',
          'Penyesuaian jumlah (quantity +/-) & catatan khusus per item.',
          'Input nama pelanggan (customer name) untuk pemanggilan pesanan.'
        ]
      },
      {
        title: '2. Kalkulasi Finansial Otomatis',
        points: [
          'Subtotal pesanan dihitung otomatis secara instan.',
          'Kalkulasi Pajak Pertambahan Nilai (PPN 10%) otomatis.',
          'Penerapan voucher diskon/promo jika ada.',
          'Kalkulator uang kembalian instan untuk pembayaran tunai.'
        ]
      },
      {
        title: '3. Multi-Channel Payment & Struk',
        points: [
          'QRIS Dinamis: Barcode khusus dengan hitung mundur (timer).',
          'E-Wallet & Card: GoPay, OVO, ShopeePay, Debit/Kredit.',
          'Payment Success: Animasi kembang api Lottie & Faktur (#INV).',
          'Opsi cetak struk thermal atau bagikan nota transaksi digital.'
        ]
      }
    ];

    flowSteps.forEach((fs, idx) => {
      const fx = 0.8 + (idx * 2.85);
      addCard(slide, fx, 1.85, 2.7, 3.2, C_SURFACE, C_BORDER);

      slide.addText(fs.title, {
        x: fx + 0.15, y: 2.0, w: 2.4, h: 0.35,
        fontSize: 10.5, bold: true, color: C_PRIMARY, fontFace: 'Georgia'
      });

      fs.points.forEach((pt, pIdx) => {
        slide.addText(`•  ${pt}`, {
          x: fx + 0.15, y: 2.45 + (pIdx * 0.7), w: 2.4, h: 0.65,
          fontSize: 8.5, color: C_TEXT_MAIN, lineSpacing: 12, fontFace: 'Calibri'
        });
      });
    });
  }

  // ==========================================
  // SLIDE 16: UI PREVIEW SHOWCASE 1 (ONBOARDING & DASHBOARD)
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'UI Preview 1', 'Tangkapan Antarmuka: Onboarding & Dashboard POS', 'Tampilan visual modern yang memadukan estetika premium dan kecepatan operasional.');

    // 3 Mockup Cards with Images
    const previews1 = [
      {
        title: 'Splash & Video Intro',
        sub: 'Animasi Video MP4 + Lottie Loader',
        img: cartoonLogo || logoBGA,
        notes: 'Transisi mulus dengan progress status memuat konfigurasi sistem.'
      },
      {
        title: 'Store Showcase & Shift',
        sub: 'Onboarding Pemilihan Toko & Dinas',
        img: imgJakarta || foodCroissant,
        notes: 'Pilih cabang kota (Jakarta/Bandung/Yogya) dan shift aktif kasir.'
      },
      {
        title: 'Home POS Dashboard',
        sub: 'Banner Kasir Aktif & Ringkasan Bento',
        img: foodSourdough || drinkLatte,
        notes: 'Sinkronisasi profil kasir live di bawah nama Kingdom Cafe / Cafe.'
      }
    ];

    previews1.forEach((p, idx) => {
      const px = 0.8 + (idx * 2.85);
      addCard(slide, px, 1.85, 2.7, 3.2, C_SURFACE, C_BORDER);

      slide.addText(p.title, {
        x: px + 0.15, y: 1.95, w: 2.4, h: 0.25,
        fontSize: 11, bold: true, color: C_PRIMARY, fontFace: 'Georgia'
      });
      slide.addText(p.sub, {
        x: px + 0.15, y: 2.2, w: 2.4, h: 0.2,
        fontSize: 8, color: C_SECONDARY, bold: true, fontFace: 'Calibri'
      });

      if (p.img) {
        slide.addImage({
          path: p.img,
          x: px + 0.25, y: 2.45, w: 2.2, h: 1.6
        });
      }

      slide.addText(p.notes, {
        x: px + 0.15, y: 4.15, w: 2.4, h: 0.8,
        fontSize: 8, color: C_TEXT_MUTED, lineSpacing: 11, fontFace: 'Calibri'
      });
    });
  }

  // ==========================================
  // SLIDE 17: UI PREVIEW SHOWCASE 2 (MENU, CHECKOUT & SETTINGS)
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_LIGHT_BG };
    addHeader(slide, 'UI Preview 2', 'Tangkapan Antarmuka: Menu, Shift & Pengaturan', 'Kelengkapan modul operasional kasir dari manajemen menu hingga penyesuaian tema.');

    const previews2 = [
      {
        title: 'Menu Editor Screen',
        sub: 'CRUD Makanan, Minuman, Snack',
        img: foodTart || dessertCheesecake,
        notes: 'Pembaruan foto produk via kamera/galeri, harga, dan resep.'
      },
      {
        title: 'Cart & QRIS Payment',
        sub: 'Kalkulasi PPN & QRIS Countdown',
        img: drinkMatcha || snackCookie,
        notes: 'Dialog pembayaran QRIS instan, rincian pajak, dan invoice digital.'
      },
      {
        title: 'Staff Shift & Settings',
        sub: 'Kalender Dinas & 4 Tema Warna',
        img: imgBandung || imgYogya,
        notes: 'Kalender presensi bulanan serta pilihan 4 palet tema dan skala teks.'
      }
    ];

    previews2.forEach((p, idx) => {
      const px = 0.8 + (idx * 2.85);
      addCard(slide, px, 1.85, 2.7, 3.2, C_SURFACE, C_BORDER);

      slide.addText(p.title, {
        x: px + 0.15, y: 1.95, w: 2.4, h: 0.25,
        fontSize: 11, bold: true, color: C_PRIMARY, fontFace: 'Georgia'
      });
      slide.addText(p.sub, {
        x: px + 0.15, y: 2.2, w: 2.4, h: 0.2,
        fontSize: 8, color: C_SECONDARY, bold: true, fontFace: 'Calibri'
      });

      if (p.img) {
        slide.addImage({
          path: p.img,
          x: px + 0.25, y: 2.45, w: 2.2, h: 1.6
        });
      }

      slide.addText(p.notes, {
        x: px + 0.15, y: 4.15, w: 2.4, h: 0.8,
        fontSize: 8, color: C_TEXT_MUTED, lineSpacing: 11, fontFace: 'Calibri'
      });
    });
  }

  // ==========================================
  // SLIDE 18: CONCLUSION & FUTURE ROADMAP (Dark Luxury)
  // ==========================================
  {
    const slide = pres.addSlide();
    slide.background = { color: C_DARK_BG };

    // Background Accents
    slide.addShape(pres.ShapeType.ellipse, {
      x: 8.0, y: -1.0, w: 4.5, h: 4.5,
      fill: { color: '442A22', transparency: 60 },
      line: { color: '442A22', width: 0 }
    });

    slide.addShape(pres.ShapeType.roundRect, {
      x: 0.8, y: 0.5, w: 2.4, h: 0.32,
      fill: { color: C_SECONDARY },
      rectRadius: 0.15
    });
    slide.addText('KESIMPULAN & ROADMAP', {
      x: 0.8, y: 0.5, w: 2.4, h: 0.32,
      fontSize: 9, bold: true, color: 'FFFFFF', align: 'center', fontFace: 'Calibri'
    });

    slide.addText('Dampak Bisnis & Masa Depan BGA Co.', {
      x: 0.8, y: 0.9, w: 8.4, h: 0.5,
      fontSize: 22, bold: true, color: 'FFFFFF', fontFace: 'Georgia'
    });

    // Left Box: Business Impact
    addCard(slide, 0.8, 1.6, 4.1, 3.4, '3D2015', '5D3E33');
    slide.addText('DAMPAK OPERASIONAL BISNIS', {
      x: 1.0, y: 1.8, w: 3.7, h: 0.25,
      fontSize: 9.5, bold: true, color: C_ACCENT, fontFace: 'Calibri'
    });
    slide.addText('Hasil & Efisiensi Terukur', {
      x: 1.0, y: 2.05, w: 3.7, h: 0.3,
      fontSize: 13, bold: true, color: 'FFFFFF', fontFace: 'Georgia'
    });

    const impacts = [
      'Efisiensi Pesanan +85%: Pemesanan dan perhitungan kasir jauh lebih cepat tanpa antrean panjang.',
      'Akurasi Kas 100%: Menghilangkan selisih hitung manual berkat kalkulasi PPN & kembalian otomatis.',
      'Transparansi Karyawan: Jadwal shift dan kehadiran staf tercatat rapi di kalender.',
      'Citra Bisnis Modern: Struk digital dan barcode QRIS meningkatkan kepercayaan pelanggan cafe.'
    ];
    impacts.forEach((imp, idx) => {
      slide.addText(`✔  ${imp}`, {
        x: 1.0, y: 2.45 + (idx * 0.58), w: 3.7, h: 0.52,
        fontSize: 8.8, color: 'E6DACB', lineSpacing: 12, fontFace: 'Calibri'
      });
    });

    // Right Box: Future Roadmap
    addCard(slide, 5.1, 1.6, 4.1, 3.4, '3D2015', '5D3E33');
    slide.addText('ROADMAP PENGEMBANGAN MENDATANG', {
      x: 5.3, y: 1.8, w: 3.7, h: 0.25,
      fontSize: 9.5, bold: true, color: C_ACCENT, fontFace: 'Calibri'
    });
    slide.addText('Rencana Inovasi V2.0', {
      x: 5.3, y: 2.05, w: 3.7, h: 0.3,
      fontSize: 13, bold: true, color: 'FFFFFF', fontFace: 'Georgia'
    });

    const roadmaps = [
      'Direct Bluetooth Thermal Printer: Cetak struk otomatis langsung ke printer kasir 58mm/80mm.',
      'Cloud Multi-Branch Sync: Sinkronisasi data real-time antar cabang Jakarta, Bandung, dan Yogya.',
      'Raw Material Inventory: Pengurangan otomatis stok biji kopi, susu, dan bahan baku per porsi.',
      'Financial Profit & Loss Analytics: Grafik tren laba kotor, item terlaris, dan jam sibuk toko.'
    ];
    roadmaps.forEach((rm, idx) => {
      slide.addText(`🚀  ${rm}`, {
        x: 5.3, y: 2.45 + (idx * 0.58), w: 3.7, h: 0.52,
        fontSize: 8.8, color: 'E6DACB', lineSpacing: 12, fontFace: 'Calibri'
      });
    });

    // Footer Closing Tagline
    slide.addText('BGA Co. Cashier System  •  "Empowering Small Businesses to Grow and Succeed"', {
      x: 0.8, y: 5.15, w: 8.4, h: 0.3,
      fontSize: 9, italic: true, color: C_ACCENT, align: 'center', fontFace: 'Calibri'
    });
  }

  // Save the presentation
  const outputPath = path.join(__dirname, 'BGA_Co_Cashier_Presentation.pptx');
  await pres.writeFile({ fileName: outputPath });
  console.log(`Presentation generated successfully at: ${outputPath}`);
}

createPresentation().catch(err => {
  console.error('Error generating presentation:', err);
  process.exit(1);
});
