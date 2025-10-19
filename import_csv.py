#!/usr/bin/env python3
import csv
import subprocess
import uuid
import re
from datetime import datetime

def parse_price(value):
    """Convertir precio desde string"""
    if not value or value.strip() == '' or value == '0':
        return None
    try:
        clean_value = str(value).replace(',', '').replace(' ', '').strip()
        price = float(clean_value)
        return price if price > 0 else None
    except (ValueError, TypeError):
        return None

def parse_iva(value):
    """Extraer porcentaje de IVA del texto"""
    if not value or value.strip() == '':
        return 0.00  # Por defecto 0% si no hay valor

    # Convertir a string y limpiar
    value_str = str(value).strip().upper()

    # Si dice "EXCLUIDO" o "EXENTO" -> 0%
    if 'EXCLUIDO' in value_str or 'EXENTO' in value_str:
        return 0.00

    # Buscar porcentajes específicos
    if '19' in value_str:
        return 19.00
    elif '16' in value_str:
        return 16.00
    elif '10' in value_str:
        return 10.00
    elif '5' in value_str:
        return 5.00
    elif '0' in value_str:
        return 0.00

    # Si no se encuentra ningún patrón conocido, intentar extraer números
    try:
        numbers = re.findall(r'\d+(?:\.\d+)?', value_str)
        if numbers:
            iva = float(numbers[0])
            # Validar que sea un porcentaje de IVA válido
            if iva in [0, 5, 10, 16, 19]:
                return float(iva)
            # Si el número está fuera del rango, retornar 0
            return 0.00
        return 0.00
    except (ValueError, TypeError):
        return 0.00

def create_insert_sql(product):
    """Crear comando SQL INSERT"""
    precioA = product.get('precioA') or 1000.0  # Precio mínimo por defecto
    precioB = product.get('precioB')
    precioC = product.get('precioC') 
    costo = product.get('costo')
    iva = product.get('iva', 19.0)
    
    # Escapar comillas en los valores
    description = product['description'].replace("'", "''")
    barcode = product['barcode'].replace("'", "''")
    
    sql = f"""
INSERT INTO products (id, description, barcode, "isActive", "createdAt", "updatedAt", precioa, preciob, precioc, costo, iva)
VALUES ('{product['id']}', '{description}', '{barcode}', true, now(), now(), {precioA}, {precioB or 'NULL'}, {precioC or 'NULL'}, {costo or 'NULL'}, {iva});
"""
    return sql

def read_csv_and_generate_sql():
    """Leer CSV y generar comandos SQL"""
    products = []
    
    with open('articulos_la bomba.csv', 'r', encoding='utf-8-sig') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        
        for row in reader:
            if row.get('nombre') and row.get('referencias'):
                product = {
                    'id': str(uuid.uuid4()),
                    'description': row['nombre'].strip().strip('"'),
                    'barcode': row['referencias'].strip().strip('"'),
                    'precioA': parse_price(row.get('precioa')),
                    'precioB': parse_price(row.get('preciob')),
                    'precioC': parse_price(row.get('precioc')),
                    'costo': parse_price(row.get('costo')),
                    'iva': parse_iva(row.get('iva'))
                }
                
                if product['precioA'] is None:
                    product['precioA'] = 1000.0
                
                products.append(product)
    
    print(f"Procesando {len(products)} productos...")
    
    # Crear archivo SQL
    with open('insert_products.sql', 'w', encoding='utf-8') as sqlfile:
        for product in products:
            sqlfile.write(create_insert_sql(product))
    
    print("Archivo SQL creado: insert_products.sql")
    return len(products)

def execute_sql():
    """Ejecutar el archivo SQL en el contenedor"""
    try:
        # Copiar archivo SQL al contenedor
        subprocess.run(['docker', 'cp', 'insert_products.sql', 'pedidos_db:/tmp/'], check=True)
        
        # Ejecutar SQL en el contenedor
        result = subprocess.run([
            'docker', 'exec', 'pedidos_db', 
            'psql', '-U', 'postgres', '-d', 'pedidos_db', '-f', '/tmp/insert_products.sql'
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Productos importados exitosamente!")
            print(result.stdout)
        else:
            print("❌ Error ejecutando SQL:")
            print(result.stderr)
            
    except subprocess.CalledProcessError as e:
        print(f"❌ Error: {e}")

def main():
    print("=== Importador de Productos desde CSV ===")
    
    # Leer CSV y generar SQL
    count = read_csv_and_generate_sql()
    
    # Ejecutar SQL
    print(f"Importando {count} productos...")
    execute_sql()
    
    print("¡Importación completada!")

if __name__ == "__main__":
    main()