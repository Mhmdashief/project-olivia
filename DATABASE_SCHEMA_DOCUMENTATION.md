# Smarternak Database Schema Documentation

## Overview
Skema database yang disederhanakan untuk mendukung semua fitur website Smarternak dengan klasifikasi telur yang sederhana. Database ini dirancang untuk:

- ✅ **User Management** (Manajemen Akun)
- ✅ **Authentication & Sessions** (Login/Logout)
- ✅ **Production Tracking** (Pelacakan Produksi)
- ✅ **Simple Quality Classification** (Klasifikasi Kualitas Sederhana: Bagus/Jelek)
- ✅ **Reporting System** (Sistem Laporan)
- ✅ **Dashboard Analytics** (Analitik Dashboard)
- ✅ **Notifications** (Notifikasi)
- ✅ **System Settings** (Pengaturan Sistem)
- ✅ **Audit Logging** (Log Aktivitas)

## Database Tables

### 1. **users** - Manajemen Pengguna
```sql
- user_id (PK): ID unik pengguna
- name: Nama lengkap
- email: Email (unique)
- password_hash: Password terenkripsi
- phone: Nomor telepon
- role: 'superadmin' atau 'admin'
- bio: Biografi singkat
- avatar_url: URL foto profil
- email_verified_at: Waktu verifikasi email
- is_active: Status aktif/nonaktif
- created_by: ID pembuat akun
- created_at, updated_at: Timestamp
```

### 2. **user_sessions** - Sesi Pengguna
```sql
- session_id (PK): ID sesi
- user_id (FK): Referensi ke users
- session_token: Token sesi (unique)
- device_info: Informasi perangkat
- ip_address: Alamat IP
- user_agent: Browser info
- expires_at: Waktu kadaluarsa
- last_activity: Aktivitas terakhir
- is_active: Status sesi
```

### 3. **production_batches** - Batch Produksi
```sql
- batch_id (PK): ID batch
- batch_code: Kode batch (unique)
- batch_name: Nama batch
- description: Deskripsi
- start_date, end_date: Tanggal mulai/selesai
- expected_quantity: Target jumlah
- actual_quantity: Jumlah aktual
- status: 'planned', 'active', 'completed', 'cancelled'
- created_by (FK): Pembuat batch
```

### 4. **egg_scans** - Data Scan Telur (Disederhanakan)
```sql
- scan_id (PK): ID scan
- egg_code: Kode telur (unique)
- batch_id (FK): Referensi ke batch
- quality: 'good' atau 'bad' (HANYA 2 PILIHAN)
- defect_types: JSON array cacat yang ditemukan
- quality_notes: Catatan kualitas manual
- image_url: URL gambar telur
- scanned_at: Waktu scan
- scanned_by (FK): Petugas yang melakukan scan
```

**Catatan**: Tabel ini telah disederhanakan dengan menghilangkan:
- ❌ Deteksi berat (weight)
- ❌ Deteksi dimensi (length, width, height)
- ❌ Skor kualitas numerik (quality_score)
- ❌ Standar kualitas bertingkat (Grade A, B, C)
- ❌ Kategori "uncertain"

### 5. **notifications** - Notifikasi
```sql
- notification_id (PK): ID notifikasi
- user_id (FK): Penerima notifikasi
- title: Judul notifikasi
- message: Isi pesan
- type: 'info', 'warning', 'error', 'success'
- status: 'unread', 'read', 'archived'
- metadata: Data tambahan (JSON)
- read_at: Waktu dibaca
```

### 6. **reports** - Laporan
```sql
- report_id (PK): ID laporan
- user_id (FK): Pembuat laporan
- report_name: Nama laporan
- report_type: Jenis laporan
- parameters: Parameter laporan (JSON)
- file_path: Path file laporan
- file_format: 'pdf', 'excel', 'csv'
- file_size: Ukuran file
- expires_at: Waktu kadaluarsa
- download_count: Jumlah download
```

### 7. **system_settings** - Pengaturan Sistem
```sql
- setting_id (PK): ID pengaturan
- setting_key: Kunci pengaturan (unique)
- setting_value: Nilai pengaturan
- description: Deskripsi
- data_type: Tipe data
- is_public: Apakah publik
- updated_by (FK): Yang mengupdate
```

### 8. **audit_logs** - Log Audit
```sql
- audit_id (PK): ID log
- user_id (FK): Pengguna yang melakukan aksi
- action: Jenis aksi
- table_name: Nama tabel yang diubah
- record_id: ID record yang diubah
- old_values, new_values: Nilai lama/baru (JSON)
- ip_address: Alamat IP
- user_agent: Browser info
```

### 9. **dashboard_stats** - Statistik Dashboard
```sql
- stat_id (PK): ID statistik
- stat_key: Kunci statistik (unique)
- stat_value: Nilai statistik (JSON)
- description: Deskripsi
- last_updated: Terakhir diupdate
```

## Database Views

### 1. **egg_quality_summary** - Ringkasan Kualitas Harian
Menampilkan statistik kualitas telur per hari:
- Total telur yang discan
- Jumlah telur bagus (good)
- Jumlah telur jelek (bad)
- Persentase telur bagus

### 2. **batch_statistics** - Statistik Batch
Menampilkan statistik per batch produksi:
- Informasi batch
- Jumlah telur yang discan
- Distribusi kualitas (bagus/jelek)
- Persentase telur bagus

### 3. **user_activity_summary** - Ringkasan Aktivitas User
Menampilkan aktivitas pengguna:
- Total sesi login
- Login terakhir
- Jumlah telur yang discan
- Jumlah laporan yang dibuat

## Default Data

### Users
- **SuperAdmin**: superadmin@smarternak.com (password: superadmin123)
- **Admin**: admin@smarternak.com (password: admin123)

### System Settings
- App name, version
- File upload limits
- Session timeout
- Notification settings

### Dashboard Stats
- Total eggs scanned: 0
- Quality distribution: {"good": 0, "bad": 0}
- Daily production stats
- Active batches count

## Foreign Key Relationships

```
users (1) ←→ (N) user_sessions
users (1) ←→ (N) production_batches
users (1) ←→ (N) egg_scans
users (1) ←→ (N) notifications
users (1) ←→ (N) reports
users (1) ←→ (N) audit_logs
users (1) ←→ (N) system_settings

production_batches (1) ←→ (N) egg_scans
```

## Simplified Quality Classification

### Kualitas Telur (2 Kategori Saja):
1. **"good"** - Telur Bagus
   - Telur berkualitas baik
   - Layak untuk konsumsi/penjualan
   - Tidak ada cacat signifikan

2. **"bad"** - Telur Jelek
   - Telur berkualitas buruk
   - Tidak layak untuk konsumsi/penjualan
   - Ada cacat atau kerusakan

### Deteksi Cacat:
- Menggunakan field `defect_types` (JSON) untuk menyimpan jenis cacat
- Contoh: `["cracked", "dirty", "deformed"]`
- Bisa ditambahkan catatan manual di `quality_notes`

## Usage Examples

### Menambah Data Scan Telur
```sql
INSERT INTO egg_scans (egg_code, batch_id, quality, defect_types, quality_notes, scanned_by) 
VALUES ('EGG001', 1, 'good', NULL, 'Telur berkualitas baik', 1);

INSERT INTO egg_scans (egg_code, batch_id, quality, defect_types, quality_notes, scanned_by) 
VALUES ('EGG002', 1, 'bad', '["cracked", "dirty"]', 'Telur retak dan kotor', 1);
```

### Query Dashboard Statistics
```sql
-- Statistik harian
SELECT * FROM egg_quality_summary WHERE scan_date >= CURDATE() - INTERVAL 7 DAY;

-- Persentase kualitas per batch
SELECT batch_code, good_percentage FROM batch_statistics WHERE status = 'active';
```

### Update System Settings
```sql
UPDATE system_settings SET setting_value = 'Smarternak v2.0' WHERE setting_key = 'app_name';
```

## Advantages of Simplified Schema

### ✅ Keuntungan:
1. **Lebih Sederhana** - Hanya 2 kategori kualitas
2. **Lebih Cepat** - Tidak perlu kalkulasi kompleks
3. **Lebih Mudah** - User interface lebih simpel
4. **Lebih Fokus** - Fokus pada klasifikasi utama
5. **Lebih Fleksibel** - Cacat bisa dicatat di JSON

### 🎯 Cocok Untuk:
- Sistem klasifikasi sederhana
- Proses sortir otomatis
- Dashboard yang mudah dipahami
- Laporan yang simpel dan jelas

## Migration Notes

Untuk migrasi dari skema kompleks ke sederhana:
1. Backup database existing
2. Run script `database_schema_simple.sql`
3. Migrate data existing:
   - Konversi quality_score ke good/bad
   - Hapus data dimensi dan berat
   - Simpan informasi penting ke quality_notes
4. Update aplikasi untuk UI yang lebih sederhana
5. Test semua fitur website

## Performance Optimization

- Index pada quality field untuk query cepat
- JSON field untuk fleksibilitas cacat
- View untuk statistik yang sering diakses
- Prepared statements untuk keamanan
- Connection pooling untuk performa 