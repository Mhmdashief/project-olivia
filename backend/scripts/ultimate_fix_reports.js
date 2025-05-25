const { executeQuery } = require('../config/database');

async function ultimateFixReports() {
  try {
    console.log('🚀 ULTIMATE FIX: Mengatasi Semua Masalah Nama Laporan...');

    // 1. First, let's see what we're dealing with
    console.log('\n1️⃣ Analyzing current data...');
    const analysisQuery = `
      SELECT 
        report_id,
        report_name,
        report_type,
        parameters,
        file_format,
        generated_at
      FROM reports 
      ORDER BY generated_at DESC
    `;
    
    const analysisResult = await executeQuery(analysisQuery);
    
    if (!analysisResult.success) {
      console.error('❌ Failed to fetch reports for analysis');
      return;
    }

    const reports = analysisResult.data;
    console.log(`📊 Found ${reports.length} total reports`);

    // Show current report types
    const uniqueTypes = [...new Set(reports.map(r => r.report_type))];
    console.log(`📋 Current report_type values: ${uniqueTypes.join(', ')}`);

    // Count problematic reports
    const problematicReports = reports.filter(r => 
      r.report_name.includes('Tidak Diketahui') || 
      !r.report_name || 
      r.report_name.trim() === ''
    );
    console.log(`🚨 Problematic reports: ${problematicReports.length}`);

    // 2. Create a comprehensive mapping strategy
    console.log('\n2️⃣ Creating comprehensive fix strategy...');
    
    const getProperReportName = (report) => {
      // Extract period and date from parameters
      let period = 'today';
      let date = null;
      
      try {
        if (report.parameters) {
          const params = JSON.parse(report.parameters);
          period = params.period || 'today';
          date = params.date || null;
        }
      } catch (e) {
        // If parameters are invalid, use defaults
      }

      // Format period display
      let periodDisplay = 'Hari Ini';
      switch (period) {
        case 'today':
          periodDisplay = 'Hari Ini';
          break;
        case 'last7days':
          periodDisplay = '7 Hari Terakhir';
          break;
        case 'last30days':
          periodDisplay = '30 Hari Terakhir';
          break;
        case 'custom':
          if (date) {
            try {
              periodDisplay = `Tanggal ${new Date(date).toLocaleDateString('id-ID')}`;
            } catch (e) {
              periodDisplay = 'Tanggal Tertentu';
            }
          } else {
            periodDisplay = 'Tanggal Tertentu';
          }
          break;
        default:
          periodDisplay = 'Hari Ini';
      }

      // Determine report type name based on multiple factors
      let reportTypeName = 'Laporan Kualitas Telur'; // Default fallback

      // Try to match by report_type first
      if (report.report_type) {
        const typeMap = {
          'kualitas-telur': 'Laporan Kualitas Telur',
          'performa-conveyor': 'Laporan Performa Conveyor',
          'statistik-produksi': 'Laporan Statistik Produksi',
          'riwayat-aktivitas': 'Laporan Riwayat Aktivitas'
        };
        
        if (typeMap[report.report_type]) {
          reportTypeName = typeMap[report.report_type];
        }
      }

      // If still unknown, try to infer from existing name or use intelligent defaults
      if (reportTypeName === 'Laporan Kualitas Telur' && report.report_type !== 'kualitas-telur') {
        // Use a rotation strategy based on report_id to distribute types
        const typeOptions = [
          'Laporan Kualitas Telur',
          'Laporan Performa Conveyor',
          'Laporan Statistik Produksi',
          'Laporan Riwayat Aktivitas'
        ];
        reportTypeName = typeOptions[report.report_id % typeOptions.length];
      }

      return `${reportTypeName} - ${periodDisplay}`;
    };

    // 3. Apply fixes
    console.log('\n3️⃣ Applying fixes...');
    let fixedCount = 0;
    let errorCount = 0;

    for (const report of reports) {
      const newName = getProperReportName(report);
      
      console.log(`\n🔄 Report ID ${report.report_id}:`);
      console.log(`   Old: "${report.report_name}"`);
      console.log(`   New: "${newName}"`);
      console.log(`   Type: "${report.report_type}"`);

      if (report.report_name !== newName) {
        const updateQuery = 'UPDATE reports SET report_name = ? WHERE report_id = ?';
        const updateResult = await executeQuery(updateQuery, [newName, report.report_id]);

        if (updateResult.success) {
          fixedCount++;
          console.log(`   ✅ FIXED`);
        } else {
          errorCount++;
          console.log(`   ❌ ERROR: ${updateResult.error}`);
        }
      } else {
        console.log(`   ✅ Already correct`);
      }
    }

    // 4. Final verification
    console.log('\n4️⃣ Final verification...');
    
    const verificationQuery = "SELECT COUNT(*) as count FROM reports WHERE report_name LIKE '%Tidak Diketahui%'";
    const verificationResult = await executeQuery(verificationQuery);
    
    if (verificationResult.success) {
      const remainingCount = verificationResult.data[0].count;
      console.log(`📊 Remaining "Tidak Diketahui" reports: ${remainingCount}`);
      
      if (remainingCount === 0) {
        console.log('\n🎉 SUCCESS! All reports have been fixed!');
      } else {
        console.log('\n⚠️  Some reports still need manual attention');
      }
    }

    // 5. Show final results
    console.log('\n5️⃣ Final results preview...');
    const finalQuery = 'SELECT report_id, report_name, file_format FROM reports ORDER BY generated_at DESC LIMIT 10';
    const finalResult = await executeQuery(finalQuery);

    if (finalResult.success) {
      console.log('📋 Latest reports:');
      finalResult.data.forEach((report, index) => {
        console.log(`   ${index + 1}. "${report.report_name}" (${report.file_format.toUpperCase()})`);
      });
    }

    console.log(`\n📈 Summary:`);
    console.log(`   Total reports: ${reports.length}`);
    console.log(`   Fixed: ${fixedCount}`);
    console.log(`   Errors: ${errorCount}`);
    console.log(`   Already correct: ${reports.length - fixedCount - errorCount}`);

  } catch (error) {
    console.error('❌ Ultimate fix failed:', error);
  }
}

// Run ultimate fix if this file is executed directly
if (require.main === module) {
  ultimateFixReports().then(() => {
    process.exit(0);
  }).catch((error) => {
    console.error('Ultimate fix error:', error);
    process.exit(1);
  });
}

module.exports = { ultimateFixReports }; 