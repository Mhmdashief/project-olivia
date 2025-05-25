-- Fix Report Names in Database
-- This script will update all report names to proper format

-- Update reports based on report_type
UPDATE reports 
SET report_name = CASE 
    WHEN report_type = 'kualitas-telur' THEN 'Laporan Kualitas Telur - Hari Ini'
    WHEN report_type = 'performa-conveyor' THEN 'Laporan Performa Conveyor - Hari Ini'
    WHEN report_type = 'statistik-produksi' THEN 'Laporan Statistik Produksi - Hari Ini'
    WHEN report_type = 'riwayat-aktivitas' THEN 'Laporan Riwayat Aktivitas - Hari Ini'
    ELSE 'Laporan Tidak Diketahui'
END
WHERE report_name LIKE '%Tidak Diketahui%' OR report_name IS NULL OR report_name = '';

-- Update with more specific periods based on parameters if available
UPDATE reports 
SET report_name = CASE 
    WHEN report_type = 'kualitas-telur' AND JSON_EXTRACT(parameters, '$.period') = 'today' THEN 'Laporan Kualitas Telur - Hari Ini'
    WHEN report_type = 'kualitas-telur' AND JSON_EXTRACT(parameters, '$.period') = 'last7days' THEN 'Laporan Kualitas Telur - 7 Hari Terakhir'
    WHEN report_type = 'kualitas-telur' AND JSON_EXTRACT(parameters, '$.period') = 'last30days' THEN 'Laporan Kualitas Telur - 30 Hari Terakhir'
    WHEN report_type = 'kualitas-telur' AND JSON_EXTRACT(parameters, '$.period') = 'custom' THEN 'Laporan Kualitas Telur - Tanggal Tertentu'
    
    WHEN report_type = 'performa-conveyor' AND JSON_EXTRACT(parameters, '$.period') = 'today' THEN 'Laporan Performa Conveyor - Hari Ini'
    WHEN report_type = 'performa-conveyor' AND JSON_EXTRACT(parameters, '$.period') = 'last7days' THEN 'Laporan Performa Conveyor - 7 Hari Terakhir'
    WHEN report_type = 'performa-conveyor' AND JSON_EXTRACT(parameters, '$.period') = 'last30days' THEN 'Laporan Performa Conveyor - 30 Hari Terakhir'
    WHEN report_type = 'performa-conveyor' AND JSON_EXTRACT(parameters, '$.period') = 'custom' THEN 'Laporan Performa Conveyor - Tanggal Tertentu'
    
    WHEN report_type = 'statistik-produksi' AND JSON_EXTRACT(parameters, '$.period') = 'today' THEN 'Laporan Statistik Produksi - Hari Ini'
    WHEN report_type = 'statistik-produksi' AND JSON_EXTRACT(parameters, '$.period') = 'last7days' THEN 'Laporan Statistik Produksi - 7 Hari Terakhir'
    WHEN report_type = 'statistik-produksi' AND JSON_EXTRACT(parameters, '$.period') = 'last30days' THEN 'Laporan Statistik Produksi - 30 Hari Terakhir'
    WHEN report_type = 'statistik-produksi' AND JSON_EXTRACT(parameters, '$.period') = 'custom' THEN 'Laporan Statistik Produksi - Tanggal Tertentu'
    
    WHEN report_type = 'riwayat-aktivitas' AND JSON_EXTRACT(parameters, '$.period') = 'today' THEN 'Laporan Riwayat Aktivitas - Hari Ini'
    WHEN report_type = 'riwayat-aktivitas' AND JSON_EXTRACT(parameters, '$.period') = 'last7days' THEN 'Laporan Riwayat Aktivitas - 7 Hari Terakhir'
    WHEN report_type = 'riwayat-aktivitas' AND JSON_EXTRACT(parameters, '$.period') = 'last30days' THEN 'Laporan Riwayat Aktivitas - 30 Hari Terakhir'
    WHEN report_type = 'riwayat-aktivitas' AND JSON_EXTRACT(parameters, '$.period') = 'custom' THEN 'Laporan Riwayat Aktivitas - Tanggal Tertentu'
    
    ELSE report_name
END
WHERE parameters IS NOT NULL AND parameters != '';

-- Show results
SELECT 
    report_id,
    report_name,
    report_type,
    file_format,
    generated_at
FROM reports 
ORDER BY generated_at DESC 
LIMIT 10; 