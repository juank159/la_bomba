#!/usr/bin/env python3
"""
🚀 SCRIPT INTERACTIVO PARA CREAR USUARIOS
==========================================
Script para crear usuarios con rol seleccionable en Supabase
"""

import psycopg2
import bcrypt
import sys
import re

# Configuración de Supabase
SUPABASE_CONFIG = {
    'host': 'aws-1-us-east-1.pooler.supabase.com',
    'port': 6543,
    'database': 'postgres',
    'user': 'postgres.yeeziftpvdmiuljncbva',
    'password': 'Bauduty0159',
}

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

def validate_email(email: str) -> bool:
    """Validar formato de email"""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def hash_password(password: str) -> str:
    """Hashear contraseña con bcrypt (salt rounds = 10)"""
    salt = bcrypt.gensalt(rounds=10)
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def get_user_input():
    """Obtener datos del usuario de forma interactiva"""
    print_header("📝 CREAR NUEVO USUARIO")

    # Email
    while True:
        email = input(f"{Colors.BOLD}Ingresa el email: {Colors.END}").strip()
        if not email:
            print_error("El email no puede estar vacío")
            continue
        if not validate_email(email):
            print_error("Email inválido. Por favor usa un formato válido (ejemplo@dominio.com)")
            continue
        break

    # Username (opcional, se genera del email si no se proporciona)
    username = input(f"{Colors.BOLD}Ingresa el nombre de usuario (Enter para generar automáticamente): {Colors.END}").strip()
    if not username:
        username = email.split('@')[0]
        print_info(f"Username generado automáticamente: {username}")

    # Contraseña
    while True:
        password = input(f"{Colors.BOLD}Ingresa la contraseña (mínimo 6 caracteres): {Colors.END}").strip()
        if len(password) < 6:
            print_error("La contraseña debe tener al menos 6 caracteres")
            continue

        confirm_password = input(f"{Colors.BOLD}Confirma la contraseña: {Colors.END}").strip()
        if password != confirm_password:
            print_error("Las contraseñas no coinciden")
            continue
        break

    # Rol
    print(f"\n{Colors.BOLD}Selecciona el rol:{Colors.END}\n")
    print(f"{Colors.CYAN}1.{Colors.END} {Colors.BOLD}ADMIN{Colors.END} - Administrador (acceso total)")
    print(f"{Colors.CYAN}2.{Colors.END} {Colors.BOLD}SUPERVISOR{Colors.END} - Supervisor (puede revisar y aprobar)")
    print(f"{Colors.CYAN}3.{Colors.END} {Colors.BOLD}EMPLOYEE{Colors.END} - Empleado (acceso limitado)")
    print()

    while True:
        role_choice = input(f"{Colors.BOLD}Selecciona el rol (1-3): {Colors.END}").strip()
        if role_choice == '1':
            role = 'admin'
            break
        elif role_choice == '2':
            role = 'supervisor'
            break
        elif role_choice == '3':
            role = 'employee'
            break
        else:
            print_error("Por favor, selecciona 1, 2 o 3")

    return {
        'username': username,
        'email': email,
        'password': password,
        'role': role
    }

def create_user(user_data):
    """Crear usuario en Supabase"""
    try:
        print_info("Conectando a Supabase...")
        conn = psycopg2.connect(**SUPABASE_CONFIG)
        cursor = conn.cursor()

        print_success("Conectado exitosamente!")

        # Verificar si el usuario ya existe
        cursor.execute(
            "SELECT id, username FROM users WHERE email = %s OR username = %s",
            (user_data['email'], user_data['username'])
        )
        existing = cursor.fetchone()

        if existing:
            print_warning(f"El usuario ya existe con email o username similar")

            update = input(f"{Colors.BOLD}¿Deseas actualizar el usuario existente? (s/n): {Colors.END}").strip().lower()

            if update != 's':
                print_info("Operación cancelada")
                cursor.close()
                conn.close()
                return False

            # Actualizar usuario existente
            hashed_password = hash_password(user_data['password'])
            cursor.execute("""
                UPDATE users
                SET username = %s,
                    email = %s,
                    password = %s,
                    role = %s,
                    "isActive" = true,
                    "updatedAt" = NOW()
                WHERE email = %s OR username = %s
            """, (
                user_data['username'],
                user_data['email'],
                hashed_password,
                user_data['role'],
                user_data['email'],
                user_data['username']
            ))

            print_success("Usuario actualizado exitosamente!")
        else:
            # Crear nuevo usuario
            hashed_password = hash_password(user_data['password'])
            cursor.execute("""
                INSERT INTO users (username, email, password, role, "isActive", "createdAt", "updatedAt")
                VALUES (%s, %s, %s, %s, true, NOW(), NOW())
            """, (
                user_data['username'],
                user_data['email'],
                hashed_password,
                user_data['role']
            ))

            print_success("Usuario creado exitosamente!")

        # Commit
        conn.commit()

        # Mostrar información del usuario creado
        print_header("✅ USUARIO CREADO/ACTUALIZADO")
        print(f"   👤 Usuario: {Colors.BOLD}{user_data['username']}{Colors.END}")
        print(f"   📧 Email: {Colors.BOLD}{user_data['email']}{Colors.END}")
        print(f"   🔑 Contraseña: {Colors.BOLD}{user_data['password']}{Colors.END}")
        print(f"   👔 Rol: {Colors.BOLD}{user_data['role'].upper()}{Colors.END}")
        print()

        cursor.close()
        conn.close()
        return True

    except Exception as e:
        print_error(f"Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

def list_users():
    """Listar todos los usuarios"""
    try:
        conn = psycopg2.connect(**SUPABASE_CONFIG)
        cursor = conn.cursor()

        cursor.execute("""
            SELECT username, email, role, "isActive", "createdAt"
            FROM users
            ORDER BY "createdAt" DESC
        """)

        users = cursor.fetchall()

        if not users:
            print_info("No hay usuarios en la base de datos")
            return

        print_header("👥 USUARIOS REGISTRADOS")

        for username, email, role, is_active, created_at in users:
            status = f"{Colors.GREEN}✅ Activo{Colors.END}" if is_active else f"{Colors.RED}❌ Inactivo{Colors.END}"
            role_emoji = "👑" if role == "admin" else ("👔" if role == "supervisor" else "👤")
            print(f"{role_emoji} {Colors.BOLD}{username}{Colors.END} ({email})")
            print(f"   Rol: {role.upper()} | Estado: {status}")
            print(f"   Creado: {created_at.strftime('%Y-%m-%d %H:%M:%S')}")
            print()

        cursor.close()
        conn.close()

    except Exception as e:
        print_error(f"Error listando usuarios: {str(e)}")

def main():
    """Función principal"""
    try:
        print_header("🚀 GESTOR DE USUARIOS - SUPABASE")
        print(f"{Colors.CYAN}Sistema de gestión de usuarios para La Bomba{Colors.END}\n")

        # Verificar conexión
        print_info("Verificando conexión a Supabase...")
        try:
            conn = psycopg2.connect(**SUPABASE_CONFIG)
            conn.close()
            print_success("Conexión exitosa!")
        except Exception as e:
            print_error(f"No se pudo conectar a Supabase: {str(e)}")
            sys.exit(1)

        while True:
            print(f"\n{Colors.BOLD}¿Qué deseas hacer?{Colors.END}\n")
            print(f"{Colors.CYAN}1.{Colors.END} Crear nuevo usuario")
            print(f"{Colors.CYAN}2.{Colors.END} Listar usuarios existentes")
            print(f"{Colors.CYAN}3.{Colors.END} Salir")
            print()

            choice = input(f"{Colors.BOLD}Selecciona una opción (1-3): {Colors.END}").strip()

            if choice == '1':
                user_data = get_user_input()
                if create_user(user_data):
                    another = input(f"\n{Colors.BOLD}¿Deseas crear otro usuario? (s/n): {Colors.END}").strip().lower()
                    if another != 's':
                        break
            elif choice == '2':
                list_users()
            elif choice == '3':
                print_info("¡Hasta luego!")
                break
            else:
                print_error("Opción inválida")

    except KeyboardInterrupt:
        print_info("\n\nOperación cancelada por el usuario")
        sys.exit(0)
    except Exception as e:
        print_error(f"Error: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
