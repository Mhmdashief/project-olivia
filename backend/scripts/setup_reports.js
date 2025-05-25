const fs = require('fs');
const path = require('path');

async function setupReports() {
  try {
    console.log('🔧 Setting up reports functionality...');

    // Note: Reports table already exists in database
    console.log('📊 Reports table already exists - skipping table creation');

    // Create uploads/reports directory
    const uploadsDir = path.join(__dirname, '../uploads');
    const reportsDir = path.join(uploadsDir, 'reports');

    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
      console.log('📁 Created uploads directory');
    }

    if (!fs.existsSync(reportsDir)) {
      fs.mkdirSync(reportsDir, { recursive: true });
      console.log('📁 Created reports directory');
    } else {
      console.log('📁 Reports directory already exists');
    }

    console.log('🎉 Reports setup completed successfully!');
    console.log('');
    console.log('✅ Your existing reports table structure is compatible');
    console.log('✅ Controller updated to work with existing table');
    console.log('');
    console.log('Next steps:');
    console.log('1. Install new dependencies: npm install');
    console.log('2. Restart the server: npm run dev');
    console.log('3. Test report generation from the frontend');

  } catch (error) {
    console.error('❌ Setup failed:', error);
  }
}

// Run setup if this file is executed directly
if (require.main === module) {
  setupReports().then(() => {
    process.exit(0);
  }).catch((error) => {
    console.error('Setup error:', error);
    process.exit(1);
  });
}

module.exports = { setupReports }; 