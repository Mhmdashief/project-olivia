const { executeQuery } = require('../config/database');

async function debugReports() {
  try {
    console.log('🔍 Debugging Reports Data...');

    // 1. Check actual data in reports table
    console.log('\n1️⃣ Checking actual reports data...');
    const reportsQuery = `
      SELECT 
        report_id, 
        report_name, 
        report_type, 
        parameters, 
        file_format,
        generated_at
      FROM reports 
      ORDER BY generated_at DESC 
      LIMIT 10
    `;
    
    const result = await executeQuery(reportsQuery);
    
    if (result.success && result.data.length > 0) {
      console.log('📊 Current reports in database:');
      result.data.forEach((report, index) => {
        console.log(`\n${index + 1}. Report ID: ${report.report_id}`);
        console.log(`   Name: "${report.report_name}"`);
        console.log(`   Type: "${report.report_type}"`);
        console.log(`   Format: "${report.file_format}"`);
        console.log(`   Parameters: ${report.parameters}`);
        console.log(`   Generated: ${report.generated_at}`);
        
        // Parse parameters
        try {
          const params = JSON.parse(report.parameters || '{}');
          console.log(`   Parsed Params:`, params);
        } catch (e) {
          console.log(`   ⚠️  Invalid JSON parameters`);
        }
      });
    } else {
      console.log('📭 No reports found in database');
    }

    // 2. Test the mapping functions with actual data
    console.log('\n2️⃣ Testing mapping functions...');
    
    const getReportTypeDisplayName = (reportType) => {
      console.log(`   🔍 Input report_type: "${reportType}" (type: ${typeof reportType})`);
      
      const names = {
        'kualitas-telur': 'Laporan Kualitas Telur',
        'performa-conveyor': 'Laporan Performa Conveyor', 
        'statistik-produksi': 'Laporan Statistik Produksi',
        'riwayat-aktivitas': 'Laporan Riwayat Aktivitas'
      };
      
      const result = names[reportType] || `Laporan Tidak Diketahui (${reportType})`;
      console.log(`   🔍 Mapped to: "${result}"`);
      return result;
    };

    const formatPeriodForDisplay = (period, date) => {
      console.log(`   🔍 Input period: "${period}", date: "${date}"`);
      
      const periods = {
        'today': 'Hari Ini',
        'last7days': '7 Hari Terakhir',
        'last30days': '30 Hari Terakhir',
        'custom': date ? `Tanggal ${new Date(date).toLocaleDateString('id-ID')}` : 'Tanggal Tertentu'
      };
      
      const result = periods[period] || `Periode Tidak Diketahui (${period})`;
      console.log(`   🔍 Mapped to: "${result}"`);
      return result;
    };

    // Test with actual data from database
    if (result.success && result.data.length > 0) {
      console.log('\n3️⃣ Testing with actual database data...');
      
      result.data.slice(0, 3).forEach((report, index) => {
        console.log(`\n--- Testing Report ${index + 1} ---`);
        console.log(`Current name: "${report.report_name}"`);
        console.log(`Report type: "${report.report_type}"`);
        
        try {
          const params = JSON.parse(report.parameters || '{}');
          console.log(`Parameters:`, params);
          
          const mappedType = getReportTypeDisplayName(report.report_type);
          const mappedPeriod = formatPeriodForDisplay(params.period, params.date);
          const correctName = `${mappedType} - ${mappedPeriod}`;
          
          console.log(`Should be: "${correctName}"`);
          console.log(`Needs update: ${report.report_name !== correctName ? 'YES' : 'NO'}`);
          
        } catch (e) {
          console.log(`❌ Error parsing parameters: ${e.message}`);
        }
      });
    }

    // 4. Check for specific issues
    console.log('\n4️⃣ Checking for specific issues...');
    
    // Check for reports with "Tidak Diketahui"
    const problematicQuery = "SELECT COUNT(*) as count FROM reports WHERE report_name LIKE '%Tidak Diketahui%'";
    const problematicResult = await executeQuery(problematicQuery);
    
    if (problematicResult.success) {
      console.log(`📊 Reports with "Tidak Diketahui": ${problematicResult.data[0].count}`);
    }

    // Check for empty or null parameters
    const emptyParamsQuery = "SELECT COUNT(*) as count FROM reports WHERE parameters IS NULL OR parameters = '' OR parameters = '{}'";
    const emptyParamsResult = await executeQuery(emptyParamsQuery);
    
    if (emptyParamsResult.success) {
      console.log(`📊 Reports with empty parameters: ${emptyParamsResult.data[0].count}`);
    }

    console.log('\n🎉 Debug completed!');

  } catch (error) {
    console.error('❌ Debug failed:', error);
  }
}

// Run debug if this file is executed directly
if (require.main === module) {
  debugReports().then(() => {
    process.exit(0);
  }).catch((error) => {
    console.error('Debug error:', error);
    process.exit(1);
  });
}

module.exports = { debugReports }; 