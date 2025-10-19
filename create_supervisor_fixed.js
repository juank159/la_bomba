// Script to create a supervisor user with correct password
const bcrypt = require('bcrypt');
const { Client } = require('pg');

async function createSupervisor() {
  const client = new Client({
    host: 'localhost',
    port: 5432,
    user: 'postgres',
    password: 'password',
    database: 'pedidos_db',
  });

  try {
    await client.connect();
    console.log('📦 Connected to database');

    // Hash the password with salt rounds 10 (same as NestJS default)
    const hashedPassword = await bcrypt.hash('supervisor123', 10);
    console.log('🔒 Password hashed successfully');

    // Insert supervisor user
    const query = `
      INSERT INTO users (id, username, email, password, role, "isActive", "createdAt", "updatedAt")
      VALUES (
        gen_random_uuid(),
        'supervisor',
        'supervisor@ejemplo.com',
        $1,
        'supervisor',
        true,
        NOW(),
        NOW()
      )
      ON CONFLICT (email) DO UPDATE SET
        username = EXCLUDED.username,
        password = EXCLUDED.password,
        role = EXCLUDED.role,
        "updatedAt" = NOW()
      RETURNING id, username, email, role;
    `;

    const result = await client.query(query, [hashedPassword]);
    console.log('✅ Supervisor user created/updated:', result.rows[0]);

    // Verify the password can be compared
    const user = result.rows[0];
    const passwordMatch = await bcrypt.compare('supervisor123', hashedPassword);
    console.log('🔐 Password verification test:', passwordMatch ? '✅ PASS' : '❌ FAIL');

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
  }
}

createSupervisor();