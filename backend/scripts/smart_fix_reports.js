const { executeQuery } = require('../config/database');

async function smartFixReports() {
  try {
    console.log('🧠 SMART FIX: Memperbaiki Nama Laporan Berdasarkan Parameter...');

    // Helper functions (same as in reportController.js)
    const getReportTypeDisplayName = (reportType) => {
      const names = {
        'kualitas-telur': 'Laporan Kualitas Telur',
        'performa-conveyor': 'Laporan Performa Conveyor', 
        'statistik-produksi': 'Laporan Statistik Produksi',
        'riwayat-aktivitas': 'Laporan Riwayat Aktivitas'
      };
      return names[reportType] || `Laporan Tidak Diketahui (${reportType})`;
    };

    const formatPeriodForDisplay = (period, date) => {
      const periods = {
        'today': 'Hari Ini',
        'last7days': '7 Hari Terakhir',
        'last30days': '30 Hari Terakhir',
        'custom': date ? `Tanggal ${new Date(date).toLocaleDateString('id-ID')}` : 'Tanggal Tertentu'
      };
      return periods[period] || `Periode Tidak Diketahui (${period})`;
    };

    // 1. Get all reports with their parameters
    console.log('\n1️⃣ Menganalisis semua laporan...');
    const allReportsQuery = `
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
    
    const result = await executeQuery(allReportsQuery);
    
    if (!result.success) {
      console.error('❌ Failed to fetch reports');
      return;
    }

    const reports = result.data;
    console.log(`📊 Found ${reports.length} reports to analyze`);

    let fixedCount = 0;
    let errorCount = 0;
    let alreadyCorrectCount = 0;

    // 2. Process each report
    for (const report of reports) {
      console.log(`\n🔄 Processing Report ID ${report.report_id}:`);
      console.log(`   Current name: "${report.report_name}"`);
      console.log(`   Report type: "${report.report_type}"`);
      console.log(`   Parameters: ${report.parameters}`);

      // Parse parameters
      let period = 'today';
      let date = null;
      let reportType = report.report_type;

      try {
        if (report.parameters) {
          const params = JSON.parse(report.parameters);
          period = params.period || 'today';
          date = params.date || null;
          reportType = params.report_type || report.report_type;
          console.log(`   Parsed - Period: "${period}", Date: "${date}", Type: "${reportType}"`);
        } else {
          console.log(`   No parameters found, using defaults`);
        }
      } catch (e) {
        console.log(`   ⚠️  Invalid parameters, using defaults`);
      }

      // Generate correct name using the same logic as backend
      const reportTypeName = getReportTypeDisplayName(reportType);
      const periodName = formatPeriodForDisplay(period, date);
      const correctName = `${reportTypeName} - ${periodName}`;

      console.log(`   Should be: "${correctName}"`);

      // Update if different
      if (report.report_name !== correctName) {
        console.log(`   🔄 Updating...`);
        
        const updateQuery = 'UPDATE reports SET report_name = ? WHERE report_id = ?';
        const updateResult = await executeQuery(updateQuery, [correctName, report.report_id]);

        if (updateResult.success) {
          fixedCount++;
          console.log(`   ✅ FIXED`);
        } else {
          errorCount++;
          console.log(`   ❌ ERROR: ${updateResult.error}`);
        }
      } else {
        alreadyCorrectCount++;
        console.log(`   ✅ Already correct`);
      }
    }

    // 3. Final verification
    console.log('\n3️⃣ Final verification...');
    
    const verificationQuery = "SELECT COUNT(*) as count FROM reports WHERE report_name LIKE '%Tidak Diketahui%'";
    const verificationResult = await executeQuery(verificationQuery);
    
    if (verificationResult.success) {
      const remainingCount = verificationResult.data[0].count;
      console.log(`📊 Remaining "Tidak Diketahui" reports: ${remainingCount}`);
      
      if (remainingCount === 0) {
        console.log('\n🎉 SUCCESS! All reports have been fixed!');
      } else {
        console.log('\n⚠️  Some reports still need attention');
      }
    }

    // 4. Show sample of fixed reports
    console.log('\n4️⃣ Sample of fixed reports:');
    const sampleQuery = 'SELECT report_id, report_name, file_format, parameters FROM reports ORDER BY generated_at DESC LIMIT 8';
    const sampleResult = await executeQuery(sampleQuery);

    if (sampleResult.success) {
      console.log('📋 Latest reports:');
      sampleResult.data.forEach((report, index) => {
        console.log(`   ${index + 1}. "${report.report_name}" (${report.file_format.toUpperCase()})`);
        
        // Show parameters for verification
        try {
          const params = JSON.parse(report.parameters || '{}');
          console.log(`      Parameters: period="${params.period}", date="${params.date}"`);
        } catch (e) {
          console.log(`      Parameters: Invalid JSON`);
        }
      });
    }

    // 5. Show distribution
    console.log('\n5️⃣ Report distribution:');
    const distributionQuery = `
      SELECT 
        SUBSTRING_INDEX(report_name, ' - ', 1) as report_type,
        COUNT(*) as count
      FROM reports 
      GROUP BY SUBSTRING_INDEX(report_name, ' - ', 1)
      ORDER BY count DESC
    `;
    const distributionResult = await executeQuery(distributionQuery);
    
    if (distributionResult.success) {
      console.table(distributionResult.data);
    }

    console.log(`\n📈 Summary:`);
    console.log(`   Total reports: ${reports.length}`);
    console.log(`   Fixed: ${fixedCount}`);
    console.log(`   Already correct: ${alreadyCorrectCount}`);
    console.log(`   Errors: ${errorCount}`);

  } catch (error) {
    console.error('❌ Smart fix failed:', error);
  }
}

// Run smart fix if this file is executed directly
if (require.main === module) {
  smartFixReports().then(() => {
    process.exit(0);
  }).catch((error) => {
    console.error('Smart fix error:', error);
    process.exit(1);
  });
}

module.exports = { smartFixReports }; 