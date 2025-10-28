import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { CreditsService } from './credits.service';

/**
 * Servicio para tareas programadas relacionadas con créditos
 */
@Injectable()
export class CreditsSchedulerService {
  private readonly logger = new Logger(CreditsSchedulerService.name);

  constructor(private readonly creditsService: CreditsService) {}

  /**
   * Verifica créditos vencidos (sin pagos en 30+ días) cada día a las 9:00 AM
   * Expresión Cron: '0 9 * * *' = segundo 0, minuto 0, hora 9, todos los días
   */
  @Cron('0 9 * * *', {
    name: 'check-overdue-credits',
    timeZone: 'America/Bogota', // GMT-5
  })
  async handleCheckOverdueCredits() {
    this.logger.log('🔔 Iniciando verificación programada de créditos vencidos (30+ días)...');

    try {
      await this.creditsService.checkOverdueCredits(30); // 30 días por defecto
      this.logger.log('✅ Verificación de créditos vencidos completada exitosamente');
    } catch (error) {
      this.logger.error('❌ Error en la verificación programada de créditos vencidos:', error);
    }
  }

  /**
   * 🧪 TAREA DE PRUEBA - Se ejecuta cada minuto para testing
   *
   * ⚠️ IMPORTANTE: Descomentar solo para testing, comentar en producción
   *
   * Esta tarea verifica créditos sin pagos en 1+ minuto
   */
  // @Cron(CronExpression.EVERY_MINUTE, {
  //   name: 'test-check-overdue-credits',
  // })
  // async handleTestCheck() {
  //   this.logger.log('🧪 [TEST] Verificación de prueba cada minuto (1+ minuto sin pagos)...');
  //   try {
  //     await this.creditsService.checkOverdueCredits(0.0007); // 1 minuto = 1/(24*60) días
  //     this.logger.log('✅ [TEST] Verificación de prueba completada');
  //   } catch (error) {
  //     this.logger.error('❌ [TEST] Error en verificación de prueba:', error);
  //   }
  // }
}
