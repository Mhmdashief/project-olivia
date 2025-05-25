# 🚨 URGENT: Memperbaiki Nama Laporan "Tidak Diketahui"

## 🔍 **Masalah Saat Ini**
Semua laporan di riwayat menampilkan "Laporan Tidak Diketahui" padahal seharusnya menampilkan nama yang sesuai.

## ⚡ **Solusi Cepat (Pilih Salah Satu)**

### 🎯 **Metode 1: Script Node.js (Recommended)**
```bash
cd backend
npm run force-fix-reports
```

### 🎯 **Metode 2: SQL Langsung**
Jalankan SQL berikut di database Anda:
```sql
-- Update semua laporan dengan nama yang benar
UPDATE reports 
SET report_name = CASE 
    WHEN report_type = 'kualitas-telur' THEN 'Laporan Kualitas Telur - Hari Ini'
    WHEN report_type = 'performa-conveyor' THEN 'Laporan Performa Conveyor - Hari Ini'
    WHEN report_type = 'statistik-produksi' THEN 'Laporan Statistik Produksi - Hari Ini'
    WHEN report_type = 'riwayat-aktivitas' THEN 'Laporan Riwayat Aktivitas - Hari Ini'
    ELSE 'Laporan Tidak Diketahui'
END
WHERE report_name LIKE '%Tidak Diketahui%' OR report_name IS NULL OR report_name = '';
```

### 🎯 **Metode 3: Manual Update**
```sql
-- Update satu per satu
UPDATE reports SET report_name = 'Laporan Kualitas Telur - Hari Ini' WHERE report_type = 'kualitas-telur';
UPDATE reports SET report_name = 'Laporan Performa Conveyor - Hari Ini' WHERE report_type = 'performa-conveyor';
UPDATE reports SET report_name = 'Laporan Statistik Produksi - Hari Ini' WHERE report_type = 'statistik-produksi';
UPDATE reports SET report_name = 'Laporan Riwayat Aktivitas - Hari Ini' WHERE report_type = 'riwayat-aktivitas';
```

## 🔧 **Langkah Lengkap**

### Step 1: Backup Database (Opsional tapi Disarankan)
```sql
CREATE TABLE reports_backup AS SELECT * FROM reports;
```

### Step 2: Jalankan Perbaikan
```bash
# Pilihan A: Script otomatis
cd backend
npm run force-fix-reports

# Pilihan B: SQL manual (copy paste ke MySQL client)
# Gunakan file backend/scripts/fix_reports.sql
```

### Step 3: Verifikasi Hasil
```sql
SELECT report_id, report_name, report_type, file_format 
FROM reports 
ORDER BY generated_at DESC 
LIMIT 10;
```

### Step 4: Restart Server
```bash
cd backend
npm run dev
```

### Step 5: Test di Frontend
1. Buka halaman "Unduh Laporan"
2. Scroll ke "Unduhan Terakhir"
3. Nama laporan harus sudah benar

## ✅ **Hasil yang Diharapkan**

Setelah perbaikan, nama laporan akan berubah dari:
- ❌ "Laporan Tidak Diketahui"
- ❌ "Laporan Tidak Diketahui"
- ❌ "Laporan Tidak Diketahui"

Menjadi:
- ✅ "Laporan Kualitas Telur - Hari Ini"
- ✅ "Laporan Performa Conveyor - Hari Ini"
- ✅ "Laporan Statistik Produksi - Hari Ini"

## 🧪 **Verifikasi Cepat**

### Cek Database:
```sql
-- Harus return 0
SELECT COUNT(*) FROM reports WHERE report_name LIKE '%Tidak Diketahui%';

-- Harus menampilkan nama yang benar
SELECT DISTINCT report_name FROM reports;
```

### Cek Frontend:
- Refresh halaman "Unduh Laporan"
- Lihat tabel "Unduhan Terakhir"
- Semua nama harus deskriptif

## 🔍 **Troubleshooting**

### Jika Script Error:
```bash
# Cek koneksi database
cd backend
npm run test-db

# Debug data
npm run debug-reports
```

### Jika Masih "Tidak Diketahui":
1. **Cek report_type di database:**
   ```sql
   SELECT DISTINCT report_type FROM reports;
   ```

2. **Manual update berdasarkan ID:**
   ```sql
   UPDATE reports SET report_name = 'Laporan Kualitas Telur - Hari Ini' WHERE report_id = 1;
   UPDATE reports SET report_name = 'Laporan Performa Conveyor - Hari Ini' WHERE report_id = 2;
   -- dst...
   ```

3. **Hapus data lama dan test download baru:**
   ```sql
   DELETE FROM reports WHERE report_name LIKE '%Tidak Diketahui%';
   ```

## 🎯 **Quick Fix Commands**

```bash
# All-in-one fix
cd backend
npm install
npm run force-fix-reports
npm run dev
```

## 📋 **Checklist**

- [ ] ✅ Backup database (opsional)
- [ ] ✅ Jalankan script fix: `npm run force-fix-reports`
- [ ] ✅ Verifikasi database: `SELECT DISTINCT report_name FROM reports;`
- [ ] ✅ Restart server: `npm run dev`
- [ ] ✅ Test frontend: Refresh halaman Unduh Laporan
- [ ] ✅ Konfirmasi: Tidak ada lagi "Laporan Tidak Diketahui"

---

**🚨 URGENT: Jalankan salah satu metode di atas SEKARANG untuk memperbaiki masalah ini!** 