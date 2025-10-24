import { plainToInstance } from 'class-transformer';
import { IsEnum, IsNumber, IsString, validateSync, IsOptional, Min, Max } from 'class-validator';

export enum Environment {
  Development = 'development',
  Production = 'production',
  Test = 'test',
}

export class EnvironmentVariables {
  @IsEnum(Environment)
  NODE_ENV: Environment;

  @IsNumber()
  @Min(1)
  @Max(65535)
  PORT: number;

  // Database connection - Use either DATABASE_URL or individual variables
  @IsString()
  @IsOptional()
  DATABASE_URL?: string;

  @IsString()
  @IsOptional()
  DB_HOST?: string;

  @IsNumber()
  @Min(1)
  @Max(65535)
  @IsOptional()
  DB_PORT?: number;

  @IsString()
  @IsOptional()
  DB_USERNAME?: string;

  @IsString()
  @IsOptional()
  DB_PASSWORD?: string;

  @IsString()
  @IsOptional()
  DB_NAME?: string;

  @IsString()
  JWT_SECRET: string;

  @IsString()
  JWT_EXPIRES_IN: string;

  @IsString()
  @IsOptional()
  ALLOWED_ORIGINS?: string;
}

export function validate(config: Record<string, unknown>) {
  const validatedConfig = plainToInstance(EnvironmentVariables, config, {
    enableImplicitConversion: true,
  });

  const errors = validateSync(validatedConfig, {
    skipMissingProperties: false,
  });

  if (errors.length > 0) {
    throw new Error(
      `❌ Environment validation failed:\n${errors.map(err => Object.values(err.constraints || {}).join(', ')).join('\n')}`
    );
  }

  // Validate that either DATABASE_URL or individual DB variables are provided
  const hasDbUrl = !!validatedConfig.DATABASE_URL;
  const hasIndividualVars = !!(
    validatedConfig.DB_HOST &&
    validatedConfig.DB_PORT &&
    validatedConfig.DB_USERNAME &&
    validatedConfig.DB_PASSWORD &&
    validatedConfig.DB_NAME
  );

  if (!hasDbUrl && !hasIndividualVars) {
    throw new Error(
      `❌ Database configuration missing: Provide either DATABASE_URL or all individual DB variables (DB_HOST, DB_PORT, DB_USERNAME, DB_PASSWORD, DB_NAME)`
    );
  }

  return validatedConfig;
}
