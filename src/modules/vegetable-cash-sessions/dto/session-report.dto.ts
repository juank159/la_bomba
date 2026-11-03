import { IsNotEmpty, IsString } from 'class-validator';

/** Contraseña de Adalberto (super admin) para ver el cuadre de caja. */
export class SessionReportDto {
  @IsString()
  @IsNotEmpty()
  password: string;
}
