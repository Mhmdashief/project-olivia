const { executeQuery } = require('../config/database');

async function fixReportNames() {
  try {
    console.log('🔧 Fixing Report Names in Database...');

    // Helper functions (same as in controller)
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

    // Get all reports that need fixing
    console.log('\n1️⃣ Finding reports to fix...');
    const reportsQuery = 'SELECT report_id, report_type, parameters, report_name FROM reports';
    const reportsResult = await executeQuery(reportsQuery);

    if (!reportsResult.success) {
      console.error('❌ Failed to fetch reports');
      return;
    }

    const reports = reportsResult.data;
    console.log(`📊 Found ${reports.length} reports to check`);

    let fixedCount = 0;

    // Process each report
    for (const report of reports) {
      try {
        // Parse parameters to get period and date
        let params = {};
        try {
          params = JSON.parse(report.parameters || '{}');
        } catch (e) {
          console.log(`⚠️  Report ${report.report_id}: Invalid parameters JSON`);
          continue;
        }

        // Generate correct name
        const correctName = `${getReportTypeDisplayName(report.report_type)} - ${formatPeriodForDisplay(params.period, params.date)}`;

        // Check if name needs updating
        if (report.report_name !== correctName) {
          console.log(`🔄 Fixing Report ${report.report_id}:`);
          console.log(`   Old: "${report.report_name}"`);
          console.log(`   New: "${correctName}"`);

          // Update the report name
          const updateQuery = 'UPDATE reports SET report_name = ? WHERE report_id = ?';
          const updateResult = await executeQuery(updateQuery, [correctName, report.report_id]);

          if (updateResult.success) {
            fixedCount++;
            console.log(`   ✅ Updated successfully`);
          } else {
            console.log(`   ❌ Failed to update`);
          }
        } else {
          console.log(`✅ Report ${report.report_id}: Name already correct`);
        }

      } catch (error) {
        console.error(`❌ Error processing report ${report.report_id}:`, error.message);
      }
    }

    console.log(`\n🎉 Completed! Fixed ${fixedCount} out of ${reports.length} reports`);

    // Show updated results
    console.log('\n2️⃣ Showing updated report names...');
    const updatedReports = await executeQuery('SELECT report_id, report_name, report_type, file_format FROM reports ORDER BY generated_at DESC LIMIT 10');
    if (updatedReports.success) {
      updatedReports.data.forEach(report => {
        console.log(`   📄 ${report.report_name} (${report.file_format.toUpperCase()})`);
      });
    }

  } catch (error) {
    console.error('❌ Fix failed:', error);
  }
}

// Run fix if this file is executed directly
if (require.main === module) {
  fixReportNames().then(() => {
    process.exit(0);
  }).catch((error) => {
    console.error('Fix error:', error);
    process.exit(1);
  });
}

module.exports = { fixReportNames }; 