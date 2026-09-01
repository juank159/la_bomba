import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

/// Categoría del catálogo de verduras (ej. "Frutas", "Verduras", "Tubérculos").
/// Administrable por el admin/verdulero, independiente de los productos:
/// se puede crear/editar sin tocar el catálogo de productos.
@Entity('vegetable_categories')
export class VegetableCategory {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  name: string;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
