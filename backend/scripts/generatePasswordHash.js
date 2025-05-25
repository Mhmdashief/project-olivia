const bcrypt = require('bcryptjs');
require('dotenv').config();

const generatePasswordHash = async (password) => {
  const saltRounds = parseInt(process.env.BCRYPT_ROUNDS) || 12;
  const hash = await bcrypt.hash(password, saltRounds);
  return hash;
};

const generateDefaultPasswords = async () => {
  console.log('Generating password hashes for default users...\n');
  
  try {
    // SuperAdmin password
    const superadminHash = await generatePasswordHash('superadmin123');
    console.log('SuperAdmin (superadmin123):');
    console.log(superadminHash);
    console.log('');
    
    // Admin password
    const adminHash = await generatePasswordHash('admin123');
    console.log('Admin (admin123):');
    console.log(adminHash);
    console.log('');
    
    // Generate SQL statements
    console.log('SQL UPDATE statements:');
    console.log('');
    console.log(`UPDATE users SET password_hash = '${superadminHash}' WHERE email = 'superadmin@smarternak.com';`);
    console.log(`UPDATE users SET password_hash = '${adminHash}' WHERE email = 'admin@smarternak.com';`);
    console.log('');
    
    // Generate INSERT statements for new database
    console.log('SQL INSERT statements for new database:');
    console.log('');
    console.log(`-- Default superadmin user (password: superadmin123)`);
    console.log(`INSERT INTO users (name, email, password_hash, role, is_active) VALUES`);
    console.log(`('Super Administrator', 'superadmin@smarternak.com', '${superadminHash}', 'superadmin', TRUE);`);
    console.log('');
    console.log(`-- Default admin user (password: admin123)`);
    console.log(`INSERT INTO users (name, email, password_hash, role, is_active, created_by) VALUES`);
    console.log(`('Administrator', 'admin@smarternak.com', '${adminHash}', 'admin', TRUE, 1);`);
    
  } catch (error) {
    console.error('Error generating password hashes:', error);
  }
};

// Test password verification
const testPasswordVerification = async () => {
  console.log('\n=== Testing Password Verification ===\n');
  
  try {
    const testPassword = 'superadmin123';
    const hash = await generatePasswordHash(testPassword);
    
    console.log('Test password:', testPassword);
    console.log('Generated hash:', hash);
    
    const isValid = await bcrypt.compare(testPassword, hash);
    console.log('Verification result:', isValid ? 'SUCCESS' : 'FAILED');
    
    // Test with wrong password
    const wrongPassword = 'wrongpassword';
    const isWrong = await bcrypt.compare(wrongPassword, hash);
    console.log('Wrong password test:', isWrong ? 'FAILED (should be false)' : 'SUCCESS (correctly rejected)');
    
  } catch (error) {
    console.error('Error testing password verification:', error);
  }
};

// Run the script
const main = async () => {
  await generateDefaultPasswords();
  await testPasswordVerification();
};

main(); 