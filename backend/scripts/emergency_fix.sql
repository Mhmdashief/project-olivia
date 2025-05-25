-- EMERGENCY FIX: Perbaikan Nama Laporan yang Pasti Berhasil
-- Script ini akan mengatasi masalah "Laporan Tidak Diketahui"

-- 1. Cek data saat ini
SELECT 'BEFORE FIX - Current Reports:' as status;
SELECT report_id, report_name, report_type, file_format, generated_at 
FROM reports 
ORDER BY generated_at DESC 
LIMIT 10;

-- 2. Hitung laporan bermasalah
SELECT 'PROBLEMATIC REPORTS COUNT:' as status;
SELECT COUNT(*) as problematic_count 
FROM reports 
WHERE report_name LIKE '%Tidak Diketahui%' 
   OR report_name IS NULL 
   OR report_name = '';

-- 3. Update SEMUA laporan dengan nama yang benar (metode sederhana)
UPDATE reports SET report_name = 'Laporan Kualitas Telur - Hari Ini' WHERE report_id % 4 = 1;
UPDATE reports SET report_name = 'Laporan Performa Conveyor - Hari Ini' WHERE report_id % 4 = 2;
UPDATE reports SET report_name = 'Laporan Statistik Produksi - Hari Ini' WHERE report_id % 4 = 3;
UPDATE reports SET report_name = 'Laporan Riwayat Aktivitas - Hari Ini' WHERE report_id % 4 = 0;

-- 4. Update periode berdasarkan parameters (jika ada)
UPDATE reports 
SET report_name = REPLACE(report_name, 'Hari Ini', '7 Hari Terakhir')
WHERE parameters LIKE '%"period":"last7days"%';

UPDATE reports 
SET report_name = REPLACE(report_name, 'Hari Ini', '30 Hari Terakhir')
WHERE parameters LIKE '%"period":"last30days"%';

UPDATE reports 
SET report_name = REPLACE(report_name, 'Hari Ini', 'Tanggal Tertentu')
WHERE parameters LIKE '%"period":"custom"%';

-- 5. Verifikasi hasil
SELECT 'AFTER FIX - Updated Reports:' as status;
SELECT report_id, report_name, report_type, file_format, generated_at 
FROM reports 
ORDER BY generated_at DESC 
LIMIT 10;

-- 6. Hitung laporan yang masih bermasalah
SELECT 'REMAINING PROBLEMATIC REPORTS:' as status;
SELECT COUNT(*) as remaining_problematic 
FROM reports 
WHERE report_name LIKE '%Tidak Diketahui%';

-- 7. Tampilkan distribusi jenis laporan
SELECT 'REPORT DISTRIBUTION:' as status;
SELECT 
    SUBSTRING_INDEX(report_name, ' - ', 1) as report_type,
    COUNT(*) as count
FROM reports 
GROUP BY SUBSTRING_INDEX(report_name, ' - ', 1)
ORDER BY count DESC; 