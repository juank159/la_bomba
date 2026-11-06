import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export enum UserRole {
  ADMIN = 'admin',
  SUPERVISOR = 'supervisor',
  DIGITADOR = 'digitador',
  EMPLOYEE = 'employee',
  VERDULERO = 'verdulero',
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  username: string;

  @Column({ unique: true })
  email: string;

  @Column()
  password: string;

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.EMPLOYEE,
  })
  role: UserRole;

  @Column({ default: true })
  isActive: boolean;

  @Column({ type: 'varchar', length: 255, nullable: true })
  fcmToken: string;

  /**
   * Token de notificaciones del NAVEGADOR (app web). Va aparte del del
   * celular para que el admin reciba en los dos: si compartieran columna,
   * abrir la web le quitaría las notificaciones al celular.
   */
  @Column({ type: 'varchar', length: 500, nullable: true })
  webFcmToken: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}