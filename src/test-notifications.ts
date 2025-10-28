/**
 * 🧪 Script de Testing - Crear crédito vencido para probar notificaciones
 *
 * Este script:
 * 1. Busca un crédito PENDING existente
 * 2. Actualiza su created_at a hace 2 minutos
 * 3. Ejecuta la verificación de notificaciones
 * 4. Muestra las notificaciones creadas
 *
 * Uso:
 * ts-node src/test-notifications.ts
 */

import { createConnection } from 'typeorm';
import { Credit, CreditStatus } from './modules/credits/entities/credit.entity';
import { Notification } from './modules/notifications/entities/notification.entity';
import { User, UserRole } from './modules/users/entities/user.entity';
import { Client } from './modules/clients/entities/client.entity';

async function testNotifications() {
  console.log('🧪 [Test] Iniciando test de notificaciones...\n');

  // Conectar a la base de datos
  const connection = await createConnection({
    type: 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    username: process.env.DB_USERNAME || 'postgres',
    password: process.env.DB_PASSWORD || 'password',
    database: process.env.DB_NAME || 'pedidos_db',
    entities: [__dirname + '/**/*.entity{.ts,.js}'],
    synchronize: false,
    logging: false,
  });

  try {
    const creditRepo = connection.getRepository(Credit);
    const notificationRepo = connection.getRepository(Notification);
    const userRepo = connection.getRepository(User);

    // Paso 1: Buscar un crédito PENDING
    const credits = await creditRepo.find({
      where: { status: CreditStatus.PENDING },
      relations: ['client'],
      take: 1,
    });

    if (credits.length === 0) {
      console.log('❌ No se encontraron créditos PENDING. Por favor crea un crédito primero desde la app.');
      return;
    }

    const credit = credits[0];
    console.log(`✅ Crédito encontrado: ${credit.id}`);
    console.log(`   Cliente: ${credit.client.nombre}`);
    console.log(`   Monto: $${credit.totalAmount}`);
    console.log(`   Fecha original: ${credit.createdAt}\n`);

    // Paso 2: Actualizar created_at a hace 2 minutos
    const twoMinutesAgo = new Date();
    twoMinutesAgo.setMinutes(twoMinutesAgo.getMinutes() - 2);

    await creditRepo.update(credit.id, {
      createdAt: twoMinutesAgo,
    });

    console.log(`⏰ Fecha actualizada a: ${twoMinutesAgo}`);
    console.log('   (Hace 2 minutos para que el cron lo detecte)\n');

    // Paso 3: Verificar administradores
    const admins = await userRepo.find({
      where: { role: UserRole.ADMIN },
    });

    console.log(`👥 Administradores encontrados: ${admins.length}`);
    admins.forEach(admin => {
      console.log(`   - ${admin.username} (${admin.email})`);
    });
    console.log('');

    // Paso 4: Contar notificaciones existentes
    const existingNotifs = await notificationRepo.count({
      where: { creditId: credit.id },
    });

    console.log(`📊 Notificaciones existentes para este crédito: ${existingNotifs}\n`);

    console.log('✅ Test completado!');
    console.log('\n📱 Ahora debes:');
    console.log('   1. Esperar 1 minuto para que el cron job se ejecute');
    console.log('   2. Abrir la app Flutter y hacer login como admin');
    console.log(`      Email: admin@ejemplo.com`);
    console.log(`      Password: admin123`);
    console.log('   3. Navegar a la página de Créditos');
    console.log('   4. Revisar la campana de notificaciones 🔔\n');

    console.log('💡 Tip: Revisa los logs del backend para ver:');
    console.log('   🧪 [TEST] Verificación de prueba cada minuto...');
    console.log('   📢 [Credits] Creando notificaciones para crédito vencido...\n');

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await connection.close();
  }
}

testNotifications();
