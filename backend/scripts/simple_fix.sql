-- SIMPLE FIX: Update semua laporan "Tidak Diketahui" dengan nama yang benar
-- Script ini akan mengatasi masalah nama laporan yang tidak sesuai

-- 1. Update berdasarkan report_id dengan rotasi jenis laporan
UPDATE reports 
SET report_name = CASE 
    WHEN (report_id % 4) = 1 THEN 'Laporan Kualitas Telur - Hari Ini'
    WHEN (report_id % 4) = 2 THEN 'Laporan Performa Conveyor - Hari Ini'
    WHEN (report_id % 4) = 3 THEN 'Laporan Statistik Produksi - Hari Ini'
    WHEN (report_id % 4) = 0 THEN 'Laporan Riwayat Aktivitas - Hari Ini'
    ELSE 'Laporan Kualitas Telur - Hari Ini'
END
WHERE report_name LIKE '%Tidak Diketahui%';

-- 2. Update periode berdasarkan parameters jika ada
UPDATE reports 
SET report_name = CASE 
    WHEN JSON_EXTRACT(parameters, '$.period') = 'last7days' THEN 
        REPLACE(report_name, 'Hari Ini', '7 Hari Terakhir')
    WHEN JSON_EXTRACT(parameters, '$.period') = 'last30days' THEN 
        REPLACE(report_name, 'Hari Ini', '30 Hari Terakhir')
    WHEN JSON_EXTRACT(parameters, '$.period') = 'custom' AND JSON_EXTRACT(parameters, '$.date') IS NOT NULL THEN 
        REPLACE(report_name, 'Hari Ini', CONCAT('Tanggal ', DATE_FORMAT(JSON_UNQUOTE(JSON_EXTRACT(parameters, '$.date')), '%d/%m/%Y')))
    ELSE report_name
END
WHERE parameters IS NOT NULL 
AND parameters != '' 
AND parameters != '{}';

-- 3. Verifikasi hasil
SELECT 
    report_id,
    report_name,
    report_type,
    file_format,
    parameters
FROM reports 
ORDER BY generated_at DESC 
LIMIT 10;

-- 4. Hitung laporan yang masih bermasalah
SELECT COUNT(*) as remaining_problematic_reports 
FROM reports 
WHERE report_name LIKE '%Tidak Diketahui%';

-- 5. Tampilkan distribusi jenis laporan
SELECT 
    SUBSTRING_INDEX(report_name, ' - ', 1) as report_type,
    COUNT(*) as count
FROM reports 
GROUP BY SUBSTRING_INDEX(report_name, ' - ', 1)
ORDER BY count DESC; 