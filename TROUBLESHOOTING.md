# Troubleshooting Guide - Smarternak

## Masalah yang Telah Diperbaiki

### 1. Error Import API di eggService.js

**Masalah**: `import api from './api'` gagal karena api.js mengexport `apiClient` sebagai named export, bukan default export.

**Solusi**: 
```javascript
// Sebelum (Error)
import api from './api';

// Sesudah (Fixed)
import { apiClient } from './api';
```

**File yang diperbaiki**: `src/services/eggService.js`

### 2. Inkonsistensi Nama Database

**Masalah**: Database menggunakan nama `db_smarternak` tetapi konfigurasi default masih menggunakan `smarternak_db`.

**Solusi**: 
- Diperbaiki di `backend/config/database.js`
- Diperbaiki di `backend/README.md`
- Semua referensi sekarang menggunakan `db_smarternak`

**File yang diperbaiki**:
- `backend/config/database.js`
- `backend/README.md`

### 3. Konfigurasi Environment Frontend

**Masalah**: Frontend tidak memiliki file .env untuk konfigurasi API URL.

**Solusi**: Dibuat file `.env` di root project:
```env
VITE_API_BASE_URL=http://localhost:5000/api
```

### 4. Struktur Database Tidak Sesuai

**Masalah**: Backend controller mengharapkan kolom yang tidak ada di database:
- `batch_id` (sudah dihapus)
- `scanned_by` (sudah dihapus)
- `defect_types` (tidak ada)
- `quality_notes` (tidak ada)
- `image_url` (diganti dengan `image`)

**Error**: `Unknown column 'es.defect_types' in 'field list'`

**Solusi**: 
- Diperbaiki `backend/controllers/eggController.js` untuk menggunakan struktur tabel yang sebenarnya
- Diperbaiki `backend/scripts/add_sample_eggs.sql` untuk struktur yang benar
- Diperbaiki `src/pages/DataKualitasTelur.jsx` untuk menghapus kolom "Batch"

**Struktur Tabel Saat Ini**:
```sql
egg_scans:
- scan_id (bigint, AUTO_INCREMENT)
- egg_code (varchar(50))
- quality (enum('good', 'bad'))
- image (text, nullable)
- scanned_at (timestamp)
- created_at (timestamp)
```

**File yang diperbaiki**:
- `backend/controllers/eggController.js`
- `backend/scripts/add_sample_eggs.sql`
- `src/pages/DataKualitasTelur.jsx`

## Cara Menguji Setup

### 1. Test Koneksi Database
```bash
cd backend
npm run test-db
```

### 2. Jalankan Backend
```bash
cd backend
npm start
```

### 3. Jalankan Frontend
```bash
npm run dev
```

### 4. Tambahkan Sample Data
```bash
mysql -u root -p db_smarternak < backend/scripts/add_sample_eggs.sql
```

## Checklist Troubleshooting

### Database Issues
- [ ] Database `db_smarternak` sudah dibuat
- [ ] Schema sudah diimport: `mysql -u root -p db_smarternak < database_schema_simple.sql`
- [ ] Sample data sudah ditambahkan: `mysql -u root -p db_smarternak < backend/scripts/add_sample_eggs.sql`
- [ ] Kredensial database di `backend/.env` sudah benar
- [ ] Struktur tabel `egg_scans` sesuai dengan yang diharapkan

### API Issues
- [ ] Backend berjalan di port 5000
- [ ] Frontend .env file sudah ada dengan `VITE_API_BASE_URL=http://localhost:5000/api`
- [ ] CORS sudah dikonfigurasi untuk `http://localhost:5173`

### Authentication Issues
- [ ] User sudah login dengan kredensial yang benar
- [ ] JWT token tersimpan di localStorage
- [ ] Token belum expired

## Error Messages Umum

### "Failed to fetch"
- Pastikan backend berjalan di port 5000
- Periksa CORS configuration
- Periksa network/firewall

### "Database connection failed"
- Periksa MySQL service berjalan
- Periksa kredensial di backend/.env
- Pastikan database `db_smarternak` sudah dibuat

### "Unknown column 'xxx' in 'field list'"
- Periksa struktur tabel di database sesuai dengan yang diharapkan
- Jalankan ulang database schema jika perlu
- Pastikan backend controller menggunakan kolom yang benar

### "Token expired" atau "Invalid token"
- Login ulang untuk mendapatkan token baru
- Periksa JWT_SECRET di backend/.env

### "Table doesn't exist"
- Import database schema: `mysql -u root -p db_smarternak < database_schema_simple.sql`

## Kontak Support

Jika masih mengalami masalah, periksa:
1. Console browser untuk error JavaScript
2. Network tab untuk error API calls
3. Backend logs untuk error server
4. MySQL logs untuk error database 