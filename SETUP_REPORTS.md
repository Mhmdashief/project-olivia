# 🔧 Setup Laporan - Mengatasi Error "API endpoint not found"

## 🔍 Analisis Masalah

Error "API endpoint not found" muncul karena backend belum memiliki endpoint untuk fitur laporan. Frontend mencoba mengakses `/api/reports/generate` dan `/api/reports/history`, tetapi backend tidak memiliki route tersebut.

## 📊 Perbedaan Struktur Tabel Reports

### ✅ **Tabel yang Sudah Ada di Database Anda (Lebih Lengkap):**
```sql
reports (
    report_id,
    user_id,
    report_name,        -- ✅ Nama laporan yang deskriptif
    report_type,
    parameters,         -- ✅ JSON parameters (period, date, dll)
    file_path,
    file_format,        -- ✅ Format file (pdf, excel, csv)
    file_size,
    generated_at,       -- ✅ Waktu generate
    expires_at,         -- ✅ Tanggal kadaluarsa
    download_count      -- ✅ Tracking download
)
```

### 🆚 **Tabel yang Awalnya Saya Buat (Lebih Sederhana):**
```sql
reports (
    report_id,
    user_id,
    report_type,
    period,             -- ❌ Terpisah dari parameters
    date,               -- ❌ Terpisah dari parameters
    format,             -- ❌ Nama kolom berbeda
    file_path,
    file_size,
    created_at          -- ❌ Nama kolom berbeda
)
```

## 🎯 **Keuntungan Tabel Existing Anda:**

1. **✅ Lebih Fleksibel** - `parameters` dalam JSON bisa menyimpan data apapun
2. **✅ Tracking Download** - `download_count` untuk analytics
3. **✅ File Expiration** - `expires_at` untuk cleanup otomatis
4. **✅ Nama Deskriptif** - `report_name` lebih user-friendly
5. **✅ Audit Trail** - `generated_at` untuk tracking

## 🛠️ Solusi

Saya telah **mengupdate controller** untuk menggunakan struktur tabel yang sudah ada di database Anda:

### 1. File Backend yang Ditambahkan:
- `backend/routes/reports.js` - Route untuk endpoint reports
- `backend/controllers/reportController.js` - **Updated** untuk tabel existing
- `backend/scripts/setup_reports.js` - **Updated** hanya buat direktori

### 2. Dependencies Baru:
- `pdfkit` - Untuk generate PDF
- `exceljs` - Untuk generate Excel

## 🚀 Langkah Setup (Simplified)

### Step 1: Install Dependencies Baru
```bash
cd backend
npm install
```

### Step 2: Setup Direktori (Tidak Perlu Buat Tabel)
```bash
npm run setup-reports
```

### Step 3: Restart Server
```bash
npm run dev
```

## 📋 Apa yang Dilakukan Setup

1. **✅ Menggunakan tabel `reports` yang sudah ada** - Tidak membuat tabel baru
2. **✅ Membuat direktori `uploads/reports`** - Untuk menyimpan file laporan
3. **✅ Menambahkan route `/api/reports`** - Endpoint baru
4. **✅ Install dependencies** - PDF dan Excel generation

## 🔄 Mapping Data ke Tabel Existing

Controller saya akan mapping data seperti ini:

```javascript
// Data yang disimpan ke tabel existing
{
  user_id: userId,
  report_name: "Laporan Kualitas Telur - Hari Ini",     // Deskriptif
  report_type: "kualitas-telur",                        // Sama
  parameters: JSON.stringify({                          // JSON format
    report_type: "kualitas-telur",
    period: "today", 
    date: "2024-01-15",
    format: "pdf"
  }),
  file_path: "kualitas-telur_today_1234567890.pdf",    // Nama file
  file_format: "pdf",                                   // Format
  file_size: 1024000,                                   // Size bytes
  generated_at: NOW(),                                  // Auto timestamp
  expires_at: DATE_ADD(NOW(), INTERVAL 30 DAY),        // 30 hari
  download_count: 0                                     // Start dari 0
}
```

## ✅ Fitur Tambahan dari Tabel Existing

Dengan menggunakan tabel yang sudah ada, Anda mendapat fitur bonus:

- ✅ **Auto Cleanup** - File expired tidak muncul di history
- ✅ **Download Analytics** - Track berapa kali file didownload
- ✅ **Better UX** - Nama laporan yang lebih deskriptif
- ✅ **Flexible Parameters** - Bisa tambah parameter baru tanpa alter table

## 🔍 Troubleshooting

### Error: "Cannot find module 'pdfkit'"
```bash
cd backend
npm install pdfkit exceljs
```

### Error: "ENOENT: no such file or directory 'uploads/reports'"
```bash
mkdir -p backend/uploads/reports
```

### Server tidak restart otomatis
```bash
cd backend
npm run dev
```

## 🎉 Hasil Akhir

Setelah setup selesai:
- ❌ Error "API endpoint not found" akan hilang
- ✅ Tombol download akan berfungsi
- ✅ File laporan akan ter-download
- ✅ Riwayat laporan akan muncul di tabel
- ✅ **Bonus**: Download count tracking
- ✅ **Bonus**: File expiration management

---

**💡 Tips:** Tabel existing Anda sudah sangat bagus dan lebih lengkap dari yang saya buat. Controller telah diupdate untuk memanfaatkan semua fitur yang ada!

## 🎯 Fitur yang Tersedia

Setelah setup, fitur berikut akan berfungsi:

- ✅ **Generate PDF Report** - Laporan dalam format PDF
- ✅ **Generate Excel Report** - Laporan dalam format Excel (.xlsx)
- ✅ **Generate CSV Report** - Laporan dalam format CSV
- ✅ **Report History** - Riwayat laporan yang pernah dibuat
- ✅ **Download Existing Reports** - Download ulang laporan lama

## 🔧 Manual Setup (Jika Diperlukan)

Jika script otomatis tidak berjalan, lakukan manual:

### 1. Buat Tabel Database
```sql
CREATE TABLE IF NOT EXISTS reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    report_type VARCHAR(50) NOT NULL,
    period VARCHAR(20) NOT NULL,
    date DATE NULL,
    format VARCHAR(10) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    file_size BIGINT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    INDEX idx_user_id (user_id),
    INDEX idx_report_type (report_type),
    INDEX idx_created_at (created_at)
);
```

### 2. Buat Direktori
```bash
mkdir -p backend/uploads/reports
```

### 3. Install Dependencies
```bash
cd backend
npm install pdfkit exceljs
```

## ✅ Verifikasi Setup

Setelah setup selesai, coba:

1. **Buka halaman Unduh Laporan** di frontend
2. **Pilih periode dan jenis laporan**
3. **Klik tombol download** (PDF/Excel/CSV)
4. **Error "API endpoint not found" seharusnya hilang**

## 📊 Struktur File Baru

```