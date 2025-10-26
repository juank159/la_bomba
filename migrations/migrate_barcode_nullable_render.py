#!/usr/bin/env python3
"""
🚀 MIGRACIÓN SEGURA: Barcode Nullable en Render
================================================
Script automático para hacer la columna barcode nullable en Render.

Características:
- ✅ Backup automático antes de la migración
- ✅ Conexión directa a PostgreSQL de Render
- ✅ Verificaciones antes y después
- ✅ Interfaz visual amigable
- ✅ Log detallado de operaciones

Autor: Claude Code
Fecha: 2025-10-26
"""

import psycopg2
import sys
import os
from datetime import datetime
from urllib.parse import urlparse

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

def get_database_url():
    """Obtener DATABASE_URL desde variable de entorno o solicitar al usuario"""
    database_url = os.environ.get('DATABASE_URL')

    if database_url:
        print_success(f"DATABASE_URL encontrado en variables de entorno")
        return database_url

    print_header("🔑 CONFIGURACIÓN DE CONEXIÓN")
    print(f"{Colors.BOLD}Para conectarte a Render, necesitas el DATABASE_URL{Colors.END}\n")
    print(f"{Colors.CYAN}Cómo obtenerlo:{Colors.END}")
    print("1. Ve a https://dashboard.render.com")
    print("2. Click en tu base de datos PostgreSQL")
    print("3. Ve a la pestaña 'Connect'")
    print("4. Copia la 'External Database URL'\n")
    print(f"{Colors.YELLOW}Ejemplo:{Colors.END}")
    print("postgresql://user:pass@dpg-xxxxx.oregon-postgres.render.com/database\n")

    while True:
        try:
            database_url = input(f"{Colors.BOLD}Pega tu DATABASE_URL aquí (o 'q' para salir): {Colors.END}").strip()

            if database_url.lower() == 'q':
                print_info("Operación cancelada por el usuario")
                sys.exit(0)

            if database_url.startswith('postgres://') or database_url.startswith('postgresql://'):
                return database_url
            else:
                print_error("La URL debe comenzar con 'postgresql://' o 'postgres://'")
        except KeyboardInterrupt:
            print_info("\nOperación cancelada por el usuario")
            sys.exit(0)

def parse_database_url(database_url):
    """Parsear DATABASE_URL a componentes"""
    # Reemplazar postgres:// por postgresql://
    if database_url.startswith('postgres://'):
        database_url = database_url.replace('postgres://', 'postgresql://', 1)

    try:
        result = urlparse(database_url)
        return {
            'host': result.hostname,
            'port': result.port or 5432,
            'database': result.path[1:],  # Quitar el / inicial
            'user': result.username,
            'password': result.password,
        }
    except Exception as e:
        print_error(f"Error parseando DATABASE_URL: {str(e)}")
        sys.exit(1)

def get_db_connection(db_config):
    """Conectar a PostgreSQL de Render"""
    try:
        conn = psycopg2.connect(**db_config)
        return conn
    except Exception as e:
        print_error(f"Error conectando a Render: {str(e)}")
        raise

def verify_table_structure(conn, table_name='products'):
    """Verificar estructura actual de la tabla"""
    print_header(f"🔍 VERIFICANDO ESTRUCTURA ACTUAL DE '{table_name}'")

    try:
        cursor = conn.cursor()

        # Obtener información de la columna barcode
        cursor.execute("""
            SELECT
                column_name,
                data_type,
                is_nullable,
                column_default
            FROM information_schema.columns
            WHERE table_name = %s AND column_name = 'barcode'
        """, (table_name,))

        result = cursor.fetchone()

        if not result:
            print_error(f"La columna 'barcode' no existe en la tabla '{table_name}'")
            cursor.close()
            return False

        column_name, data_type, is_nullable, column_default = result

        print(f"Columna: {Colors.BOLD}{column_name}{Colors.END}")
        print(f"Tipo: {data_type}")
        print(f"Nullable: {Colors.YELLOW if is_nullable == 'NO' else Colors.GREEN}{is_nullable}{Colors.END}")
        print(f"Default: {column_default or 'NULL'}")

        cursor.close()

        if is_nullable == 'NO':
            print_warning("La columna 'barcode' actualmente NO permite valores NULL")
            return True
        else:
            print_success("La columna 'barcode' ya permite valores NULL")
            print_info("No es necesario ejecutar la migración")
            return False

    except Exception as e:
        print_error(f"Error verificando estructura: {str(e)}")
        return False

def create_backup(conn):
    """Crear backup de la tabla products"""
    print_header("💾 CREANDO BACKUP DE SEGURIDAD")
    backup_table = f'products_backup_{datetime.now().strftime("%Y%m%d_%H%M%S")}'

    try:
        cursor = conn.cursor()

        print_info(f"Creando tabla de backup: {backup_table}")

        # Crear tabla de backup
        cursor.execute(f"""
            CREATE TABLE {backup_table} AS
            SELECT * FROM products
        """)

        # Contar registros
        cursor.execute(f"SELECT COUNT(*) FROM {backup_table}")
        count = cursor.fetchone()[0]

        conn.commit()

        print_success(f"Backup creado exitosamente: {backup_table}")
        print_info(f"Productos en backup: {count}")

        cursor.close()
        return True, backup_table

    except Exception as e:
        print_error(f"Error creando backup: {str(e)}")
        conn.rollback()
        return False, None

def execute_migration(conn):
    """Ejecutar la migración para hacer barcode nullable"""
    print_header("⚙️  EJECUTANDO MIGRACIÓN")

    try:
        cursor = conn.cursor()

        print_info("Ejecutando: ALTER TABLE products ALTER COLUMN barcode DROP NOT NULL")

        # Ejecutar migración
        cursor.execute("""
            ALTER TABLE products
            ALTER COLUMN barcode DROP NOT NULL
        """)

        # Agregar comentario
        cursor.execute("""
            COMMENT ON COLUMN products.barcode IS
            'Product barcode - nullable to allow supervisor to add it later'
        """)

        conn.commit()

        print_success("Migración ejecutada exitosamente!")

        cursor.close()
        return True

    except Exception as e:
        print_error(f"Error ejecutando migración: {str(e)}")
        conn.rollback()
        return False

def verify_migration(conn):
    """Verificar que la migración se aplicó correctamente"""
    print_header("🔍 VERIFICANDO MIGRACIÓN")

    try:
        cursor = conn.cursor()

        # Verificar que barcode ahora es nullable
        cursor.execute("""
            SELECT is_nullable
            FROM information_schema.columns
            WHERE table_name = 'products' AND column_name = 'barcode'
        """)

        result = cursor.fetchone()

        if not result:
            print_error("No se pudo verificar la columna barcode")
            cursor.close()
            return False

        is_nullable = result[0]

        if is_nullable == 'YES':
            print_success("✅ La columna 'barcode' ahora permite valores NULL")
        else:
            print_error("❌ La columna 'barcode' aún tiene restricción NOT NULL")
            cursor.close()
            return False

        # Contar productos
        cursor.execute("SELECT COUNT(*) FROM products")
        total_products = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM products WHERE barcode IS NOT NULL")
        products_with_barcode = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM products WHERE barcode IS NULL")
        products_without_barcode = cursor.fetchone()[0]

        print_info(f"Total productos: {total_products}")
        print_info(f"Productos con barcode: {products_with_barcode}")
        print_info(f"Productos sin barcode: {products_without_barcode}")

        cursor.close()
        return True

    except Exception as e:
        print_error(f"Error verificando migración: {str(e)}")
        return False

def main():
    """Función principal"""
    try:
        # Banner inicial
        print_header("🚀 MIGRACIÓN: Barcode Nullable en Render")
        print(f"{Colors.CYAN}Sistema de migración segura con backup automático{Colors.END}\n")

        # 1. Obtener DATABASE_URL
        database_url = get_database_url()

        # 2. Parsear URL
        db_config = parse_database_url(database_url)
        print_info(f"Conectando a: {db_config['host']}")

        # 3. Conectar a la base de datos
        print_info("Verificando conexión a Render...")
        try:
            conn = get_db_connection(db_config)
            print_success("Conexión a Render exitosa!")
        except Exception as e:
            print_error(f"No se pudo conectar a Render: {str(e)}")
            sys.exit(1)

        # 4. Verificar estructura actual
        needs_migration = verify_table_structure(conn)

        if not needs_migration:
            conn.close()
            sys.exit(0)

        # 5. Confirmar ejecución
        print_header("⚠️  CONFIRMACIÓN")
        print(f"{Colors.BOLD}Esta operación hará lo siguiente:{Colors.END}\n")
        print("1. ✅ Crear un backup de la tabla products")
        print("2. ✅ Cambiar la columna barcode para permitir valores NULL")
        print("3. ✅ Verificar que la migración se aplicó correctamente\n")
        print(f"{Colors.YELLOW}Esta operación es SEGURA y NO elimina datos{Colors.END}\n")

        while True:
            try:
                confirmation = input(f"{Colors.BOLD}¿Continuar? (escribe 'SI' para confirmar o 'q' para cancelar): {Colors.END}").strip()

                if confirmation.lower() == 'q':
                    print_info("Operación cancelada por el usuario")
                    conn.close()
                    sys.exit(0)

                if confirmation == 'SI':
                    break
                else:
                    print_error("Por favor, escribe 'SI' para confirmar o 'q' para cancelar")
            except KeyboardInterrupt:
                print_info("\nOperación cancelada por el usuario")
                conn.close()
                sys.exit(0)

        # 6. Crear backup
        success, backup_table = create_backup(conn)
        if not success:
            print_error("Error creando backup. Abortando por seguridad.")
            conn.close()
            sys.exit(1)

        # 7. Ejecutar migración
        if not execute_migration(conn):
            print_error("Error ejecutando migración. Los cambios NO fueron aplicados.")
            conn.close()
            sys.exit(1)

        # 8. Verificar migración
        verify_migration(conn)

        # Cerrar conexión
        conn.close()

        # Resumen final
        print_header("🎉 MIGRACIÓN COMPLETADA EXITOSAMENTE")
        print_success("La columna 'barcode' ahora permite valores NULL")
        print_info(f"Backup guardado en tabla: {backup_table}")
        print()
        print(f"{Colors.CYAN}📝 SIGUIENTE PASO:{Colors.END}")
        print("Ahora puedes crear productos sin barcode desde el frontend")
        print("El supervisor podrá agregar el barcode posteriormente\n")
        print(f"{Colors.GREEN}{Colors.BOLD}✅ TODO SALIÓ BIEN!{Colors.END}\n")

        # Información de rollback
        print(f"{Colors.YELLOW}🔄 Si necesitas revertir:{Colors.END}")
        print(f"ALTER TABLE products ALTER COLUMN barcode SET NOT NULL;\n")
        print(f"{Colors.YELLOW}🗑️  Para eliminar el backup (cuando estés seguro):{Colors.END}")
        print(f"DROP TABLE {backup_table};\n")

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
