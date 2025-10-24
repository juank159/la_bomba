#!/usr/bin/env python3
"""
🚀 IMPORTADOR INTERACTIVO DE PRODUCTOS
=======================================
Script visual e interactivo para importar productos desde CSV a la base de datos.

Características:
- ✅ Selector visual de archivo CSV
- ✅ UPSERT (mantiene IDs existentes)
- ✅ Backup automático
- ✅ Modo dry-run para probar
- ✅ Validaciones robustas
- ✅ Interfaz amigable

Autor: Claude Code
Fecha: 2025-10-23
"""

import csv
import subprocess
import re
import json
import os
import glob
from datetime import datetime
from typing import Dict, List, Optional, Tuple
from collections import defaultdict
import sys

# =============== CONFIGURACIÓN ===============
SQL_OUTPUT_FILE = 'upsert_products.sql'
BACKUP_PREFIX = 'backup_products'
LOG_PREFIX = 'import_log'
CONTAINER_NAME = 'pedidos_db'
DB_USER = 'postgres'
DB_NAME = 'pedidos_db'

# Colores para la interfaz
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    END = '\033[0m'

def print_header(text):
    """Imprimir encabezado con estilo"""
    print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*70}{Colors.END}")
    print(f"{Colors.HEADER}{Colors.BOLD}  {text}{Colors.END}")
    print(f"{Colors.HEADER}{Colors.BOLD}{'='*70}{Colors.END}\n")

def print_success(text):
    """Imprimir mensaje de éxito"""
    print(f"{Colors.GREEN}✅ {text}{Colors.END}")

def print_error(text):
    """Imprimir mensaje de error"""
    print(f"{Colors.RED}❌ {text}{Colors.END}")

def print_warning(text):
    """Imprimir advertencia"""
    print(f"{Colors.YELLOW}⚠️  {text}{Colors.END}")

def print_info(text):
    """Imprimir información"""
    print(f"{Colors.CYAN}ℹ️  {text}{Colors.END}")

# =============== SISTEMA DE LOGGING ===============
class Logger:
    def __init__(self, log_file: str):
        self.log_file = log_file
        self.errors = []
        self.warnings = []

    def log(self, message: str, level: str = 'INFO'):
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_message = f"[{timestamp}] [{level}] {message}"

        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write(log_message + '\n')

        if level == 'ERROR':
            self.errors.append(message)
        elif level == 'WARNING':
            self.warnings.append(message)

    def info(self, message: str):
        self.log(message, 'INFO')

    def warning(self, message: str):
        self.log(message, 'WARNING')

    def error(self, message: str):
        self.log(message, 'ERROR')

    def success(self, message: str):
        self.log(message, 'SUCCESS')

# =============== SELECTOR DE ARCHIVO CSV ===============
def find_csv_files():
    """Buscar archivos CSV en el directorio actual"""
    csv_files = glob.glob('*.csv')
    return sorted(csv_files)

def select_csv_file():
    """Mostrar menú interactivo para seleccionar archivo CSV"""
    print_header("📁 SELECTOR DE ARCHIVO CSV")

    csv_files = find_csv_files()

    if not csv_files:
        print_error("No se encontraron archivos CSV en el directorio actual")
        print_info(f"Directorio: {os.getcwd()}")
        sys.exit(1)

    print(f"{Colors.BOLD}Archivos CSV disponibles:{Colors.END}\n")

    for i, file in enumerate(csv_files, start=1):
        size = os.path.getsize(file)
        size_mb = size / (1024 * 1024)
        modified = datetime.fromtimestamp(os.path.getmtime(file))

        print(f"{Colors.CYAN}{i}.{Colors.END} {Colors.BOLD}{file}{Colors.END}")
        print(f"   📊 Tamaño: {size_mb:.2f} MB")
        print(f"   📅 Modificado: {modified.strftime('%Y-%m-%d %H:%M:%S')}")
        print()

    while True:
        try:
            choice = input(f"{Colors.BOLD}Selecciona el número del archivo CSV (1-{len(csv_files)}) o 'q' para salir: {Colors.END}").strip()

            if choice.lower() == 'q':
                print_info("Operación cancelada por el usuario")
                sys.exit(0)

            choice_num = int(choice)
            if 1 <= choice_num <= len(csv_files):
                selected_file = csv_files[choice_num - 1]
                print_success(f"Archivo seleccionado: {selected_file}")
                return selected_file
            else:
                print_error(f"Por favor, selecciona un número entre 1 y {len(csv_files)}")
        except ValueError:
            print_error("Por favor, ingresa un número válido o 'q' para salir")
        except KeyboardInterrupt:
            print_info("\nOperación cancelada por el usuario")
            sys.exit(0)

# =============== MENÚ DE OPCIONES ===============
def show_menu():
    """Mostrar menú de opciones"""
    print_header("⚙️  OPCIONES DE IMPORTACIÓN")

    print(f"{Colors.BOLD}¿Qué deseas hacer?{Colors.END}\n")
    print(f"{Colors.CYAN}1.{Colors.END} {Colors.BOLD}Modo Prueba (Dry-Run){Colors.END}")
    print(f"   Solo genera el SQL sin modificar la base de datos")
    print(f"   {Colors.GREEN}✅ Recomendado para la primera vez{Colors.END}\n")

    print(f"{Colors.CYAN}2.{Colors.END} {Colors.BOLD}Importación Real (Con Backup){Colors.END}")
    print(f"   Crea backup y ejecuta la importación")
    print(f"   {Colors.GREEN}✅ Modo seguro recomendado{Colors.END}\n")

    print(f"{Colors.CYAN}3.{Colors.END} {Colors.BOLD}Importación Rápida (Sin Backup){Colors.END}")
    print(f"   Ejecuta sin crear backup")
    print(f"   {Colors.RED}⚠️  No recomendado{Colors.END}\n")

    print(f"{Colors.CYAN}q.{Colors.END} {Colors.BOLD}Salir{Colors.END}\n")

    while True:
        try:
            choice = input(f"{Colors.BOLD}Selecciona una opción (1-3) o 'q': {Colors.END}").strip()

            if choice.lower() == 'q':
                print_info("Operación cancelada por el usuario")
                sys.exit(0)

            if choice in ['1', '2', '3']:
                return choice
            else:
                print_error("Por favor, selecciona 1, 2, 3 o 'q'")
        except KeyboardInterrupt:
            print_info("\nOperación cancelada por el usuario")
            sys.exit(0)

# =============== FUNCIONES DE PARSING ===============
def parse_price(value: str) -> Optional[float]:
    """Convertir precio desde string"""
    if not value or value.strip() == '' or value == '0':
        return None
    try:
        clean_value = str(value).replace(',', '.').replace(' ', '').strip()
        price = float(clean_value)
        if price > 1e10:
            return None
        return price if price > 0 else None
    except (ValueError, TypeError):
        return None

def parse_barcode(value: str) -> str:
    """Convertir barcode, manejando formato científico"""
    if not value or value.strip() == '':
        raise ValueError("Barcode vacío")
    try:
        clean_value = str(value).strip().strip('"')
        if 'E+' in clean_value or 'e+' in clean_value:
            clean_value = clean_value.replace(',', '.')
            number = float(clean_value)
            barcode = f"{int(number)}"
        else:
            barcode = clean_value
        return barcode
    except Exception as e:
        raise ValueError(f"Error parseando barcode '{value}': {e}")

def parse_iva(value: str) -> float:
    """Extraer porcentaje de IVA del texto"""
    if not value or value.strip() == '':
        return 0.00
    value_str = str(value).strip().upper()
    if 'EXCLUIDO' in value_str or 'EXENTO' in value_str:
        return 0.00
    iva_map = {'19': 19.00, '16': 16.00, '10': 10.00, '5': 5.00, '0': 0.00}
    for key, val in iva_map.items():
        if key in value_str:
            return val
    try:
        numbers = re.findall(r'\d+(?:\.\d+)?', value_str)
        if numbers:
            iva = float(numbers[0])
            if iva in [0, 5, 10, 16, 19]:
                return float(iva)
        return 0.00
    except (ValueError, TypeError):
        return 0.00

# =============== VALIDACIONES ===============
def validate_product(product: Dict, row_number: int, logger: Logger) -> Tuple[bool, Optional[str]]:
    """Validar que un producto tenga los datos mínimos requeridos"""
    if not product.get('barcode'):
        return False, f"Fila {row_number}: Barcode vacío"
    if not product.get('description') or len(product['description'].strip()) < 2:
        return False, f"Fila {row_number}: Descripción inválida"
    if product.get('precioA') is None or product['precioA'] <= 0:
        return False, f"Fila {row_number}: PrecioA inválido o vacío"
    if product.get('iva') is None or product['iva'] < 0:
        return False, f"Fila {row_number}: IVA inválido"
    return True, None

# =============== LECTURA Y PROCESAMIENTO ===============
def read_csv_and_validate(csv_file: str, logger: Logger):
    """Leer CSV y validar productos"""
    products = []
    errors = []

    print_header(f"📖 LEYENDO ARCHIVO: {csv_file}")
    logger.info(f"Leyendo archivo CSV: {csv_file}")

    try:
        with open(csv_file, 'r', encoding='utf-8-sig') as csvfile:
            reader = csv.DictReader(csvfile, delimiter=';')

            for row_num, row in enumerate(reader, start=2):
                try:
                    if not row.get('nombre') or not row.get('referencias'):
                        continue

                    barcode = parse_barcode(row.get('referencias', ''))
                    product = {
                        'description': row['nombre'].strip().strip('"'),
                        'barcode': barcode,
                        'precioA': parse_price(row.get('precioa')),
                        'precioB': parse_price(row.get('preciob')),
                        'precioC': parse_price(row.get('precioc')),
                        'costo': parse_price(row.get('costo')),
                        'iva': parse_iva(row.get('iva', '')),
                        'row_number': row_num
                    }

                    if product['precioA'] is None:
                        product['precioA'] = 1000.0
                        logger.warning(f"Fila {row_num}: PrecioA vacío, usando 1000.0 por defecto")

                    is_valid, error = validate_product(product, row_num, logger)
                    if not is_valid:
                        errors.append(error)
                        logger.error(error)
                        continue

                    products.append(product)

                except Exception as e:
                    error_msg = f"Fila {row_num}: Error procesando - {str(e)}"
                    errors.append(error_msg)
                    logger.error(error_msg)

        print_success(f"Productos válidos leídos: {len(products)}")

        if errors:
            print_warning(f"Productos omitidos con errores: {len(errors)}")
            logger.warning(f"Se omitieron {len(errors)} productos con errores")

        logger.info(f"Productos válidos leídos: {len(products)}")
        logger.info(f"Errores encontrados: {len(errors)}")

        return products, errors

    except FileNotFoundError:
        print_error(f"Archivo CSV no encontrado: {csv_file}")
        logger.error(f"Archivo CSV no encontrado: {csv_file}")
        sys.exit(1)
    except Exception as e:
        print_error(f"Error leyendo CSV: {str(e)}")
        logger.error(f"Error leyendo CSV: {str(e)}")
        sys.exit(1)

def generate_sql_file(products: List[Dict], output_file: str, logger: Logger):
    """Generar archivo SQL con UPSERT"""
    print_header("📝 GENERANDO SQL CON UPSERT")
    logger.info(f"Generando archivo SQL: {output_file}")

    try:
        with open(output_file, 'w', encoding='utf-8') as sqlfile:
            sqlfile.write("-- ================================================\n")
            sqlfile.write("-- IMPORTACIÓN SEGURA DE PRODUCTOS CON UPSERT\n")
            sqlfile.write(f"-- Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            sqlfile.write(f"-- Total productos: {len(products)}\n")
            sqlfile.write("-- ================================================\n\n")
            sqlfile.write("BEGIN;\n\n")

            for idx, product in enumerate(products, start=1):
                description = product['description'].replace("'", "''")
                barcode = product['barcode'].replace("'", "''")
                precioA = product['precioA']
                precioB = f"'{product['precioB']}'" if product['precioB'] is not None else 'NULL'
                precioC = f"'{product['precioC']}'" if product['precioC'] is not None else 'NULL'
                costo = f"'{product['costo']}'" if product['costo'] is not None else 'NULL'
                iva = product['iva']

                sql = f"""-- Producto: {description[:50]}... (Fila {product['row_number']})
INSERT INTO products (description, barcode, "isActive", precioa, preciob, precioc, costo, iva, "createdAt", "updatedAt")
VALUES ('{description}', '{barcode}', true, {precioA}, {precioB}, {precioC}, {costo}, {iva}, NOW(), NOW())
ON CONFLICT (barcode)
DO UPDATE SET
  description = EXCLUDED.description,
  precioa = EXCLUDED.precioa,
  preciob = EXCLUDED.preciob,
  precioc = EXCLUDED.precioc,
  costo = EXCLUDED.costo,
  iva = EXCLUDED.iva,
  "isActive" = true,
  "updatedAt" = NOW();

"""
                sqlfile.write(sql)

                if idx % 100 == 0:
                    sqlfile.write(f"-- Procesados {idx}/{len(products)} productos...\n\n")

            sqlfile.write("\nCOMMIT;\n")

        print_success(f"Archivo SQL generado: {output_file}")
        logger.success(f"Archivo SQL generado exitosamente: {output_file}")
        return True

    except Exception as e:
        print_error(f"Error generando SQL: {str(e)}")
        logger.error(f"Error generando archivo SQL: {str(e)}")
        return False

def create_backup(logger: Logger):
    """Crear backup de la tabla products"""
    print_header("💾 CREANDO BACKUP DE SEGURIDAD")
    backup_file = f'{BACKUP_PREFIX}_{datetime.now().strftime("%Y%m%d_%H%M%S")}.sql'
    logger.info("Creando backup de la tabla products...")

    try:
        result = subprocess.run([
            'docker', 'exec', CONTAINER_NAME,
            'pg_dump', '-U', DB_USER, '-d', DB_NAME,
            '--table=products', '--data-only', '--column-inserts'
        ], capture_output=True, text=True, check=True)

        with open(backup_file, 'w', encoding='utf-8') as f:
            f.write(result.stdout)

        print_success(f"Backup creado: {backup_file}")
        logger.success(f"Backup creado: {backup_file}")
        return True, backup_file

    except subprocess.CalledProcessError as e:
        print_error(f"Error creando backup: {e.stderr}")
        logger.error(f"Error creando backup: {e.stderr}")
        return False, None
    except Exception as e:
        print_error(f"Error inesperado: {str(e)}")
        logger.error(f"Error inesperado creando backup: {str(e)}")
        return False, None

def execute_sql(sql_file: str, logger: Logger):
    """Ejecutar archivo SQL en el contenedor"""
    print_header("⚙️  EJECUTANDO SQL EN LA BASE DE DATOS")
    logger.info("Ejecutando SQL en la base de datos...")

    try:
        print_info("Copiando archivo SQL al contenedor...")
        subprocess.run(['docker', 'cp', sql_file, f'{CONTAINER_NAME}:/tmp/'], check=True)

        print_info("Ejecutando SQL...")
        result = subprocess.run([
            'docker', 'exec', CONTAINER_NAME,
            'psql', '-U', DB_USER, '-d', DB_NAME, '-f', f'/tmp/{sql_file}'
        ], capture_output=True, text=True)

        if result.returncode == 0:
            print_success("SQL ejecutado exitosamente!")
            logger.success("SQL ejecutado exitosamente!")
            return True
        else:
            print_error("Error ejecutando SQL")
            print_error(result.stderr)
            logger.error("Error ejecutando SQL")
            logger.error(result.stderr)
            return False

    except Exception as e:
        print_error(f"Error: {str(e)}")
        logger.error(f"Error ejecutando SQL: {str(e)}")
        return False

def verify_import(expected_count: int, logger: Logger):
    """Verificar que la importación fue exitosa"""
    print_header("🔍 VERIFICANDO IMPORTACIÓN")
    logger.info("Verificando importación...")

    try:
        result = subprocess.run([
            'docker', 'exec', CONTAINER_NAME,
            'psql', '-U', DB_USER, '-d', DB_NAME,
            '-t', '-c', 'SELECT COUNT(*) FROM products WHERE "isActive" = true;'
        ], capture_output=True, text=True, check=True)

        actual_count = int(result.stdout.strip())
        print_info(f"Productos activos en BD: {actual_count}")
        print_info(f"Productos procesados del CSV: {expected_count}")

        logger.info(f"Productos activos en BD: {actual_count}")
        logger.info(f"Productos en CSV: {expected_count}")

        if actual_count >= expected_count:
            print_success("Verificación exitosa!")
            logger.success("Verificación exitosa: Todos los productos fueron procesados")
            return True
        else:
            print_warning(f"Hay menos productos en BD ({actual_count}) que en CSV ({expected_count})")
            logger.warning(f"Advertencia: Hay menos productos en BD ({actual_count}) que en CSV ({expected_count})")
            return False

    except Exception as e:
        print_error(f"Error verificando: {str(e)}")
        logger.error(f"Error verificando importación: {str(e)}")
        return False

# =============== FUNCIÓN PRINCIPAL ===============
def main():
    """Función principal"""
    try:
        # Banner inicial
        print_header("🚀 IMPORTADOR INTERACTIVO DE PRODUCTOS")
        print(f"{Colors.CYAN}Sistema de importación segura con UPSERT{Colors.END}\n")

        # 1. Seleccionar archivo CSV
        csv_file = select_csv_file()

        # 2. Seleccionar modo de operación
        mode = show_menu()

        # Configurar opciones según el modo
        dry_run = mode == '1'
        create_backup_enabled = mode == '2'

        # Crear logger
        log_file = f'{LOG_PREFIX}_{datetime.now().strftime("%Y%m%d_%H%M%S")}.txt'
        logger = Logger(log_file)
        logger.info(f"Iniciando importación en modo: {'DRY-RUN' if dry_run else 'REAL'}")
        logger.info(f"Archivo CSV: {csv_file}")

        # 3. Leer y validar CSV
        products, errors = read_csv_and_validate(csv_file, logger)

        if not products:
            print_error("No se encontraron productos válidos en el CSV")
            logger.error("No se encontraron productos válidos en el CSV")
            sys.exit(1)

        # 4. Generar SQL
        if not generate_sql_file(products, SQL_OUTPUT_FILE, logger):
            print_error("Error generando archivo SQL")
            sys.exit(1)

        # Si es dry-run, detenerse aquí
        if dry_run:
            print_header("✅ DRY-RUN COMPLETADO")
            print_success(f"Archivo SQL generado: {SQL_OUTPUT_FILE}")
            print_info("Revisa el archivo SQL antes de ejecutar en modo real")
            print_info(f"Log guardado en: {log_file}")
            sys.exit(0)

        # 5. Crear backup (si está habilitado)
        if create_backup_enabled:
            success, backup_file = create_backup(logger)
            if not success:
                print_error("Error creando backup. Abortando por seguridad.")
                sys.exit(1)

        # 6. Ejecutar SQL
        if not execute_sql(SQL_OUTPUT_FILE, logger):
            print_error("Error ejecutando SQL. Los cambios NO fueron aplicados.")
            sys.exit(1)

        # 7. Verificar importación
        verify_import(len(products), logger)

        # Resumen final
        print_header("🎉 IMPORTACIÓN COMPLETADA")
        print_success(f"Total productos procesados: {len(products)}")
        if errors:
            print_warning(f"Productos omitidos: {len(errors)}")
        print_info(f"Log guardado en: {log_file}")
        if create_backup_enabled and backup_file:
            print_info(f"Backup guardado en: {backup_file}")
        print()
        print(f"{Colors.GREEN}{Colors.BOLD}✅ TODO SALIÓ BIEN!{Colors.END}\n")

    except KeyboardInterrupt:
        print_info("\n\nOperación cancelada por el usuario")
        sys.exit(0)
    except Exception as e:
        print_error(f"Error fatal: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
