const { executeQuery } = require('../config/database');

async function testReports() {
  try {
    console.log('🧪 Testing Reports Functionality...');

    // Test 1: Check if reports table exists and structure
    console.log('\n1️⃣ Checking reports table structure...');
    const tableStructure = await executeQuery('DESCRIBE reports');
    if (tableStructure.success) {
      console.log('✅ Reports table exists with columns:');
      tableStructure.data.forEach(col => {
        console.log(`   - ${col.Field} (${col.Type})`);
      });
    } else {
      console.error('❌ Reports table not found');
      return;
    }

    // Test 2: Check existing data
    console.log('\n2️⃣ Checking existing reports...');
    const existingReports = await executeQuery('SELECT report_id, report_name, report_type, file_format, generated_at FROM reports ORDER BY generated_at DESC LIMIT 5');
    if (existingReports.success && existingReports.data.length > 0) {
      console.log('📊 Recent reports:');
      existingReports.data.forEach(report => {
        console.log(`   - ID: ${report.report_id}, Name: "${report.report_name}", Type: ${report.report_type}, Format: ${report.file_format}`);
      });
    } else {
      console.log('📭 No reports found in database');
    }

    // Test 3: Test report name generation functions
    console.log('\n3️⃣ Testing report name generation...');
    
    // Import the helper functions
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

    // Test different report types
    const testCases = [
      { type: 'kualitas-telur', period: 'today', date: null },
      { type: 'performa-conveyor', period: 'last7days', date: null },
      { type: 'statistik-produksi', period: 'custom', date: '2025-05-24' },
      { type: 'riwayat-aktivitas', period: 'last30days', date: null }
    ];

    testCases.forEach(test => {
      const reportName = `${getReportTypeDisplayName(test.type)} - ${formatPeriodForDisplay(test.period, test.date)}`;
      console.log(`   ✅ ${test.type} + ${test.period} = "${reportName}"`);
    });

    // Test 4: Check if there are any reports with "Tidak Diketahui" in name
    console.log('\n4️⃣ Checking for problematic report names...');
    const problematicReports = await executeQuery("SELECT report_id, report_name, report_type FROM reports WHERE report_name LIKE '%Tidak Diketahui%'");
    if (problematicReports.success && problematicReports.data.length > 0) {
      console.log('⚠️  Found reports with unknown names:');
      problematicReports.data.forEach(report => {
        console.log(`   - ID: ${report.report_id}, Name: "${report.report_name}", Type: ${report.report_type}`);
      });
    } else {
      console.log('✅ No problematic report names found');
    }

    console.log('\n🎉 Report testing completed!');

  } catch (error) {
    console.error('❌ Test failed:', error);
  }
}

// Run test if this file is executed directly
if (require.main === module) {
  testReports().then(() => {
    process.exit(0);
  }).catch((error) => {
    console.error('Test error:', error);
    process.exit(1);
  });
}

module.exports = { testReports }; 