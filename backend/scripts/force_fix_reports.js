const { executeQuery } = require('../config/database');

async function forceFixReports() {
  try {
    console.log('🔧 Force Fixing All Report Names...');

    // Helper functions
    const getReportTypeDisplayName = (reportType) => {
      const names = {
        'kualitas-telur': 'Laporan Kualitas Telur',
        'performa-conveyor': 'Laporan Performa Conveyor', 
        'statistik-produksi': 'Laporan Statistik Produksi',
        'riwayat-aktivitas': 'Laporan Riwayat Aktivitas'
      };
      return names[reportType] || 'Laporan Tidak Diketahui';
    };

    const formatPeriodForDisplay = (period, date) => {
      const periods = {
        'today': 'Hari Ini',
        'last7days': '7 Hari Terakhir',
        'last30days': '30 Hari Terakhir',
        'custom': date ? `Tanggal ${new Date(date).toLocaleDateString('id-ID')}` : 'Tanggal Tertentu'
      };
      return periods[period] || 'Hari Ini'; // Default to "Hari Ini" if unknown
    };

    // 1. Get all reports
    console.log('\n1️⃣ Getting all reports...');
    const allReportsQuery = 'SELECT report_id, report_type, parameters, report_name, file_format FROM reports';
    const allReportsResult = await executeQuery(allReportsQuery);

    if (!allReportsResult.success) {
      console.error('❌ Failed to fetch reports');
      return;
    }

    const reports = allReportsResult.data;
    console.log(`📊 Found ${reports.length} reports to process`);

    let fixedCount = 0;

    // 2. Process each report
    for (const report of reports) {
      console.log(`\n🔄 Processing Report ID: ${report.report_id}`);
      console.log(`   Current name: "${report.report_name}"`);
      console.log(`   Report type: "${report.report_type}"`);
      console.log(`   Parameters: ${report.parameters}`);

      let period = 'today'; // Default period
      let date = null;

      // Try to parse parameters
      try {
        if (report.parameters) {
          const params = JSON.parse(report.parameters);
          period = params.period || 'today';
          date = params.date || null;
          console.log(`   Parsed period: "${period}", date: "${date}"`);
        } else {
          console.log(`   No parameters found, using defaults`);
        }
      } catch (e) {
        console.log(`   ⚠️  Invalid parameters, using defaults`);
      }

      // Generate correct name
      const reportTypeName = getReportTypeDisplayName(report.report_type);
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
          console.log(`   ✅ Updated successfully`);
        } else {
          console.log(`   ❌ Failed to update: ${updateResult.error}`);
        }
      } else {
        console.log(`   ✅ Already correct`);
      }
    }

    console.log(`\n🎉 Completed! Fixed ${fixedCount} out of ${reports.length} reports`);

    // 3. Show final results
    console.log('\n3️⃣ Final results...');
    const finalQuery = 'SELECT report_id, report_name, report_type, file_format FROM reports ORDER BY generated_at DESC LIMIT 10';
    const finalResult = await executeQuery(finalQuery);

    if (finalResult.success) {
      console.log('📊 Updated reports:');
      finalResult.data.forEach((report, index) => {
        console.log(`   ${index + 1}. "${report.report_name}" (${report.file_format.toUpperCase()})`);
      });
    }

    // 4. Verify no "Tidak Diketahui" remains
    const checkQuery = "SELECT COUNT(*) as count FROM reports WHERE report_name LIKE '%Tidak Diketahui%'";
    const checkResult = await executeQuery(checkQuery);
    
    if (checkResult.success) {
      const remainingCount = checkResult.data[0].count;
      if (remainingCount === 0) {
        console.log('\n✅ SUCCESS: No more "Tidak Diketahui" reports found!');
      } else {
        console.log(`\n⚠️  WARNING: Still ${remainingCount} reports with "Tidak Diketahui"`);
      }
    }

  } catch (error) {
    console.error('❌ Force fix failed:', error);
  }
}

// Run force fix if this file is executed directly
if (require.main === module) {
  forceFixReports().then(() => {
    process.exit(0);
  }).catch((error) => {
    console.error('Force fix error:', error);
    process.exit(1);
  });
}

module.exports = { forceFixReports }; 