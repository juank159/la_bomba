import { IsEmail, IsNotEmpty, IsString, Length } from 'class-validator';

export class VerifyResetCodeDto {
  @IsEmail({}, { message: 'El email debe ser válido' })
  @IsNotEmpty({ message: 'El email es requerido' })
  email: string;

  @IsString({ message: 'El código debe ser un texto' })
  @IsNotEmpty({ message: 'El código es requerido' })
  @Length(6, 6, { message: 'El código debe tener 6 caracteres' })
  code: string;
}
