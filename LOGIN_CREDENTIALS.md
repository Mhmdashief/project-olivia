# 🔐 Login Credentials - Smarternak System

## Default User Accounts

Berikut adalah akun default yang tersedia untuk testing sistem Smarternak:

### 🔴 Super Administrator
- **Email:** `superadmin@smarternak.com`
- **Password:** `superadmin123`
- **Akses:** 
  - Semua fitur sistem
  - Manajemen akun (tambah, edit, hapus user)
  - Dapat membuat akun dengan role superadmin dan admin
  - Akses ke semua halaman

### 🔵 Administrator  
- **Email:** `admin@smarternak.com`
- **Password:** `admin123`
- **Akses:**
  - Semua fitur kecuali manajemen akun
  - Tidak dapat mengelola user lain
  - Akses ke dashboard, data telur, pantau conveyor, laporan, pengaturan

## Hierarki Role

```
SuperAdmin (Level 2) → Can manage all users and access all features
    ↓
Admin (Level 1) → Access all features except user management
```

## Fitur Berdasarkan Role

| Fitur | Admin | SuperAdmin |
|-------|-------|------------|
| Dashboard | ✅ | ✅ |
| Data Kualitas Telur | ✅ | ✅ |
| Pantau Conveyor | ✅ | ✅ |
| Unduh Laporan | ✅ | ✅ |
| Pengaturan Profil | ✅ | ✅ |
| **Manajemen Akun** | ❌ | ✅ |

## Perbedaan SuperAdmin vs Admin

### SuperAdmin dapat:
- ✅ Membuat akun baru dengan role SuperAdmin dan Admin
- ✅ Mengedit semua akun yang ada
- ✅ Menghapus akun pengguna lain
- ✅ Mengaktifkan/menonaktifkan akun
- ✅ Melihat statistik pengguna
- ✅ Akses ke halaman "Manajemen Akun"

### Admin tidak dapat:
- ❌ Mengakses halaman "Manajemen Akun"
- ❌ Membuat, mengedit, atau menghapus akun pengguna
- ❌ Mengelola role dan permission

## Quick Login (Demo Mode)

Pada halaman login, tersedia tombol quick login untuk memudahkan testing:

1. **Login sebagai Super Admin** (Purple button)
2. **Login sebagai Admin** (Blue button)

## Testing Scenarios

### Scenario 1: SuperAdmin Access
1. Login dengan `superadmin@smarternak.com`
2. Verifikasi menu "Manajemen Akun" muncul di sidebar
3. Test create, edit, delete user accounts
4. Test role assignment (SuperAdmin dan Admin)

### Scenario 2: Admin Restrictions
1. Login dengan `admin@smarternak.com`
2. Verifikasi menu "Manajemen Akun" TIDAK muncul
3. Coba akses `/manajemen-akun` secara langsung → harus ditolak
4. Verifikasi akses ke semua fitur lainnya (Dashboard, Data Telur, Pantau Conveyor, Laporan, Pengaturan)

## Security Features

- ✅ Password hashing (bcrypt simulation)
- ✅ JWT token authentication (mock)
- ✅ Role-based access control (RBAC)
- ✅ Protected routes
- ✅ Session persistence
- ✅ Automatic logout on token expiry
- ✅ Input validation
- ✅ XSS protection

## Development Notes

- Sistem menggunakan mock authentication untuk demo
- Token disimpan di localStorage
- Session timeout: 1 jam (configurable)
- Password minimal 6 karakter
- Email validation required
- Hanya 2 role: SuperAdmin dan Admin

## Production Deployment

Untuk production, ganti dengan:
- Real API endpoints
- Secure password hashing
- JWT secret key
- HTTPS enforcement
- Rate limiting
- Session management
- Database integration

---

**⚠️ PENTING:** Credentials ini hanya untuk development/testing. Ganti dengan credentials yang aman untuk production! 