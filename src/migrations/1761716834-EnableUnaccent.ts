import { MigrationInterface, QueryRunner } from "typeorm";

export class EnableUnaccent$(date +%s) implements MigrationInterface {
    public async up(queryRunner: QueryRunner): Promise<void> {
        // Habilitar la extensión unaccent para búsquedas insensibles a acentos
        await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS unaccent`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Deshabilitar la extensión (opcional, puede afectar otras funcionalidades)
        await queryRunner.query(`DROP EXTENSION IF EXISTS unaccent`);
    }
}
