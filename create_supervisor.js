// Script to create a supervisor user for testing
const bcrypt = require('bcrypt');
const { Client } = require('pg');

async function createSupervisor() {
  const client = new Client({
    host: 'localhost',
    port: 5432,
    username: 'postgres',
    password: 'password',
    database: 'pedidos_db',
  });

  try {
    await client.connect();
    console.log('📦 Connected to database');

    // Hash the password
    const hashedPassword = await bcrypt.hash('supervisor123', 10);

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
      ON CONFLICT (username) DO UPDATE SET
        email = EXCLUDED.email,
        password = EXCLUDED.password,
        role = EXCLUDED.role,
        "updatedAt" = NOW()
      RETURNING id, username, email, role;
    `;

    const result = await client.query(query, [hashedPassword]);
    console.log('✅ Supervisor user created/updated:', result.rows[0]);

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
  }
}

createSupervisor();