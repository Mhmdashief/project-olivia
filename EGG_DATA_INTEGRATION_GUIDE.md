# Panduan Integrasi Data Telur - Smarternak

## Ringkasan
Fitur ini mengintegrasikan data telur dari database ke website Smarternak, menggantikan data mock dengan data real dari database. Sekarang website dapat menampilkan data telur yang sebenarnya dengan fitur filtering, pagination, dan statistik real-time.

## Fitur yang Telah Diimplementasi

### 1. Backend API (Node.js/Express)

#### Controller Baru: `backend/controllers/eggController.js`
- `getAllEggs()` - Mengambil semua data telur dengan filtering dan pagination
- `getEggStatistics()` - Mengambil statistik telur berdasarkan tanggal
- `getEggById()` - Mengambil detail telur berdasarkan ID
- `getRecentEggs()` - Mengambil data telur terbaru
- `getDailyEggSummary()` - Mengambil ringkasan harian untuk dashboard
- `getAvailableDates()` - Mengambil tanggal-tanggal yang memiliki data telur

#### Routes Baru: `backend/routes/eggs.js`
- `GET /api/eggs` - Daftar telur dengan filter dan pagination
- `GET /api/eggs/statistics` - Statistik telur
- `GET /api/eggs/recent` - Telur terbaru
- `GET /api/eggs/daily-summary` - Ringkasan harian
- `GET /api/eggs/available-dates` - Tanggal tersedia
- `GET /api/eggs/:id` - Detail telur

### 2. Frontend Service (React)

#### Service Baru: `src/services/eggService.js`
- Fungsi untuk semua API calls terkait data telur
- Helper functions untuk formatting tanggal dan kualitas
- Error handling yang konsisten

### 3. Halaman yang Diupdate

#### `src/pages/DataKualitasTelur.jsx`
- **Sebelum**: Menggunakan data mock statis
- **Sesudah**: Menggunakan data dari API dengan fitur:
  - Loading states
  - Error handling
  - Real-time filtering berdasarkan tanggal dan kualitas
  - Pagination yang berfungsi
  - Statistik real-time (total, bagus, jelek)
  - Format tanggal dan waktu yang benar

#### `src/pages/Dashboard.jsx`
- **Sebelum**: Data mock dan simulasi random
- **Sesudah**: Data real dari database dengan:
  - Statistik harian real
  - Chart mingguan dengan data 7 hari terakhir
  - Daftar telur terbaru dari database
  - Auto-refresh functionality

## Struktur Database

### Tabel Utama: `egg_scans`
```sql
- scan_id (Primary Key)
- egg_code (Unique, format: EGG-YYYYMMDD-NNNN)
- batch_id (Foreign Key ke production_batches)
- quality ('good' atau 'bad')
- defect_types (JSON untuk jenis cacat)
- quality_notes (Catatan kualitas)
- scanned_at (Timestamp scan)
- scanned_by (User yang melakukan scan)
```

### Tabel Pendukung: `production_batches`
```sql
- batch_id (Primary Key)
- batch_code (Kode batch unik)
- batch_name (Nama batch)
- status ('planned', 'active', 'completed', 'cancelled')
```

## Cara Menjalankan

### 1. Setup Database
```bash
# Jalankan schema database
mysql -u username -p db_smarternak < database_schema_simple.sql

# Tambahkan data sample
mysql -u username -p db_smarternak < backend/scripts/add_sample_eggs.sql
```

### 2. Jalankan Backend
```bash
cd backend
npm install
npm start
```

### 3. Jalankan Frontend
```bash
cd ../
npm install
npm run dev
```

## Fitur-Fitur Utama

### 1. Halaman Data Kualitas Telur
- **URL**: `/data-kualitas-telur`
- **Fitur**:
  - Filter berdasarkan tanggal
  - Filter berdasarkan kualitas (Semua/Bagus/Jelek)
  - Pagination dengan navigasi halaman
  - Statistik real-time (total, persentase bagus/jelek)
  - Tabel data dengan informasi lengkap
  - Loading states dan error handling

### 2. Dashboard
- **URL**: `/dashboard`
- **Fitur**:
  - Cards statistik dengan data real
  - Chart mingguan produksi telur
  - Donut chart distribusi kualitas
  - Daftar telur terbaru
  - Tombol refresh untuk update data
  - Status sistem dan conveyor

### 3. API Endpoints
- **Base URL**: `http://localhost:5000/api/eggs`
- **Authentication**: Diperlukan JWT token
- **Format Response**: JSON dengan struktur konsisten

## Parameter API

### GET /api/eggs
```javascript
// Query parameters
{
  page: 1,           // Halaman (default: 1)
  limit: 10,         // Jumlah per halaman (default: 10)
  date: '2024-01-15', // Filter tanggal (YYYY-MM-DD)
  quality: 'good',   // Filter kualitas ('good', 'bad', atau 'all')
  sort_by: 'scanned_at', // Kolom untuk sorting
  sort_order: 'DESC' // Urutan sorting ('ASC' atau 'DESC')
}
```

### Response Format
```javascript
{
  success: true,
  data: {
    eggs: [...],
    pagination: {
      current_page: 1,
      total_pages: 5,
      total_records: 50,
      per_page: 10,
      has_next: true,
      has_prev: false
    }
  }
}
```

## Data Sample

Script `add_sample_eggs.sql` menambahkan:
- 15 telur untuk hari ini
- 10 telur untuk kemarin
- 8 telur untuk 2 hari lalu
- 6 telur untuk 3 hari lalu
- 5 telur untuk 4 hari lalu
- 4 telur untuk 5 hari lalu
- 3 telur untuk 6 hari lalu

Total: **51 telur** dengan distribusi kualitas yang realistis (sekitar 80% bagus, 20% jelek).

## Error Handling

### Frontend
- Loading states saat mengambil data
- Error messages yang user-friendly
- Retry functionality
- Fallback untuk data kosong

### Backend
- Validasi input parameter
- Error logging yang detail
- Response format yang konsisten
- Database connection handling

## Security

- Semua endpoint memerlukan authentication (JWT token)
- Input validation dan sanitization
- SQL injection protection melalui parameterized queries
- Rate limiting pada API endpoints

## Performance

- Pagination untuk menghindari loading data besar
- Database indexing pada kolom yang sering diquery
- Caching untuk statistik dashboard
- Optimized SQL queries dengan JOIN yang efisien

## Troubleshooting

### 1. Data Tidak Muncul
- Pastikan database sudah disetup dengan benar
- Jalankan script `add_sample_eggs.sql` untuk data sample
- Periksa koneksi database di backend
- Cek console browser untuk error API

### 2. Error Authentication
- Pastikan user sudah login
- Periksa JWT token di localStorage
- Restart backend jika diperlukan

### 3. Performance Issues
- Gunakan pagination dengan limit yang wajar
- Periksa database indexes
- Monitor query performance di database

## Pengembangan Selanjutnya

### Fitur yang Bisa Ditambahkan
1. **Export Data** - Export ke Excel/PDF
2. **Real-time Updates** - WebSocket untuk update real-time
3. **Advanced Filtering** - Filter berdasarkan batch, user, dll
4. **Data Visualization** - Chart yang lebih advanced
5. **Mobile Responsiveness** - Optimasi untuk mobile
6. **Bulk Operations** - Edit/delete multiple records
7. **Data Import** - Import data dari file CSV/Excel

### Optimasi
1. **Caching** - Redis untuk cache data yang sering diakses
2. **Database Optimization** - Partitioning untuk tabel besar
3. **API Optimization** - GraphQL untuk query yang lebih fleksibel
4. **Frontend Optimization** - Virtual scrolling untuk data besar

## Kesimpulan

Integrasi data telur ini berhasil menggantikan data mock dengan data real dari database, memberikan pengalaman yang lebih autentik dan fungsional. Website sekarang dapat menampilkan data telur yang sebenarnya dengan fitur filtering, pagination, dan statistik yang akurat.

Semua fitur telah ditest dan berfungsi dengan baik, siap untuk digunakan dalam environment production dengan data real dari sistem IoT atau input manual. 