import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  description: string;

  @Column({ unique: true })
  barcode: string;

  @Column({ default: true })
  isActive: boolean;

  // Precios - precioA es obligatorio, precioB y precioC opcionales
  @Column('decimal', { precision: 10, scale: 2, name: 'precioa' })
  precioA: number;

  @Column('decimal', { precision: 10, scale: 2, nullable: true, name: 'preciob' })
  precioB: number;

  @Column('decimal', { precision: 10, scale: 2, nullable: true, name: 'precioc' })
  precioC: number;

  // Costo - opcional
  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  costo: number;

  // IVA - porcentaje (por defecto 19%)
  @Column('decimal', { precision: 5, scale: 2, default: 19.00 })
  iva: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}