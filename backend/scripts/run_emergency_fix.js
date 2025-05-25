const { executeQuery } = require('../config/database');
const fs = require('fs');
const path = require('path');

async function runEmergencyFix() {
  try {
    console.log('🚨 EMERGENCY FIX: Menjalankan Perbaikan SQL...');

    // Read the SQL file
    const sqlFilePath = path.join(__dirname, 'emergency_fix.sql');
    const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');

    // Split SQL commands by semicolon and filter out empty lines
    const sqlCommands = sqlContent
      .split(';')
      .map(cmd => cmd.trim())
      .filter(cmd => cmd.length > 0 && !cmd.startsWith('--'));

    console.log(`📋 Found ${sqlCommands.length} SQL commands to execute`);

    // Execute each command
    for (let i = 0; i < sqlCommands.length; i++) {
      const command = sqlCommands[i];
      
      if (command.toLowerCase().startsWith('select')) {
        console.log(`\n🔍 Executing query ${i + 1}:`);
        const result = await executeQuery(command);
        
        if (result.success) {
          if (result.data && result.data.length > 0) {
            console.table(result.data);
          } else {
            console.log('   No data returned');
          }
        } else {
          console.error(`   ❌ Error: ${result.error}`);
        }
      } else if (command.toLowerCase().startsWith('update')) {
        console.log(`\n🔄 Executing update ${i + 1}:`);
        const result = await executeQuery(command);
        
        if (result.success) {
          console.log(`   ✅ Updated ${result.affectedRows || 0} rows`);
        } else {
          console.error(`   ❌ Error: ${result.error}`);
        }
      }
    }

    // Final verification
    console.log('\n🎯 FINAL VERIFICATION:');
    const finalCheck = await executeQuery("SELECT COUNT(*) as count FROM reports WHERE report_name LIKE '%Tidak Diketahui%'");
    
    if (finalCheck.success) {
      const remainingCount = finalCheck.data[0].count;
      if (remainingCount === 0) {
        console.log('🎉 SUCCESS! All "Tidak Diketahui" reports have been fixed!');
      } else {
        console.log(`⚠️  WARNING: Still ${remainingCount} reports with "Tidak Diketahui"`);
      }
    }

    // Show sample of fixed reports
    console.log('\n📋 Sample of fixed reports:');
    const sampleResult = await executeQuery("SELECT report_id, report_name, file_format FROM reports ORDER BY generated_at DESC LIMIT 5");
    
    if (sampleResult.success && sampleResult.data.length > 0) {
      console.table(sampleResult.data);
    }

    console.log('\n✅ Emergency fix completed!');

  } catch (error) {
    console.error('❌ Emergency fix failed:', error);
  }
}

// Run emergency fix if this file is executed directly
if (require.main === module) {
  runEmergencyFix().then(() => {
    process.exit(0);
  }).catch((error) => {
    console.error('Emergency fix error:', error);
    process.exit(1);
  });
}

module.exports = { runEmergencyFix }; 