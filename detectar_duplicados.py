#!/usr/bin/env python3
"""Script para detectar y reportar duplicados en el CSV"""
import csv
from collections import defaultdict

CSV_FILE = 'articulos_la bomba.csv'
REPORT_FILE = 'reporte_duplicados.csv'

def main():
    barcode_map = defaultdict(list)

    with open(CSV_FILE, 'r', encoding='utf-8-sig') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')

        for row_num, row in enumerate(reader, start=2):
            if row.get('referencias'):
                barcode = row['referencias'].strip()
                barcode_map[barcode].append({
                    'fila': row_num,
                    'id': row.get('id', ''),
                    'nombre': row.get('nombre', ''),
                    'barcode': barcode,
                    'precioa': row.get('precioa', ''),
                    'preciob': row.get('preciob', '')
                })

    # Filtrar solo duplicados
    duplicates = {k: v for k, v in barcode_map.items() if len(v) > 1}

    # Generar reporte
    with open(REPORT_FILE, 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['Barcode', 'Fila', 'ID', 'Nombre', 'PrecioA', 'PrecioB', 'Problema'])

        for barcode, items in sorted(duplicates.items()):
            for i, item in enumerate(items, start=1):
                problema = f"Duplicado {i}/{len(items)}"
                writer.writerow([
                    item['barcode'],
                    item['fila'],
                    item['id'],
                    item['nombre'][:50],
                    item['precioa'],
                    item['preciob'],
                    problema
                ])
            writer.writerow([])  # Línea vacía entre grupos

    print(f"✅ Reporte generado: {REPORT_FILE}")
    print(f"   Total barcodes duplicados: {len(duplicates)}")
    print(f"   Total filas afectadas: {sum(len(v) for v in duplicates.values())}")

if __name__ == "__main__":
    main()
