// Generate password hash locally
const bcrypt = require('bcrypt');

async function generateHash() {
  try {
    const password = 'supervisor123';
    const hash = await bcrypt.hash(password, 10);
    console.log('Password:', password);
    console.log('Hash:', hash);
    
    // Test the hash
    const isValid = await bcrypt.compare(password, hash);
    console.log('Verification:', isValid ? 'VALID' : 'INVALID');
  } catch (error) {
    console.error('Error:', error.message);
  }
}

generateHash();