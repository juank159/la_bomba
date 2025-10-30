#!/bin/bash

# Script para configurar Firebase Service Account para Render
# Este script te ayudará a preparar el JSON para la variable de entorno

echo "🔥 Configuración de Firebase para Render"
echo "=========================================="
echo ""

# Verificar si se proporcionó un archivo
if [ -z "$1" ]; then
  echo "❌ Error: Debes proporcionar la ruta al archivo JSON descargado de Firebase"
  echo ""
  echo "Uso:"
  echo "  ./setup-firebase-env.sh /ruta/al/archivo-firebase.json"
  echo ""
  echo "📖 Instrucciones para descargar el archivo:"
  echo "  1. Ve a https://console.firebase.google.com"
  echo "  2. Selecciona tu proyecto"
  echo "  3. Ve a Project Settings (⚙️) → Service Accounts"
  echo "  4. Click en 'Generate New Private Key'"
  echo "  5. Guarda el archivo JSON descargado"
  echo "  6. Ejecuta este script con la ruta del archivo"
  exit 1
fi

# Verificar si el archivo existe
if [ ! -f "$1" ]; then
  echo "❌ Error: El archivo '$1' no existe"
  exit 1
fi

echo "📂 Archivo encontrado: $1"
echo ""

# Verificar si jq está instalado
if ! command -v jq &> /dev/null; then
  echo "⚠️ 'jq' no está instalado. Intentando con método alternativo..."
  echo ""

  # Método sin jq - usando tr para eliminar saltos de línea
  MINIFIED=$(cat "$1" | tr -d '\n' | tr -d ' ')

  echo "✅ JSON minificado (sin jq):"
  echo ""
  echo "$MINIFIED"
  echo ""
  echo "📋 Copia el texto de arriba y:"
  echo "  1. Ve a https://dashboard.render.com"
  echo "  2. Selecciona tu Web Service (backend)"
  echo "  3. Ve a Environment → Add Environment Variable"
  echo "  4. Key: FIREBASE_SERVICE_ACCOUNT"
  echo "  5. Value: (pega el JSON minificado)"
  echo "  6. Save Changes"
  echo ""

  # Guardar en archivo temporal
  echo "$MINIFIED" > firebase-env-value.txt
  echo "💾 También guardado en: firebase-env-value.txt"
  echo ""

  exit 0
fi

# Minificar JSON usando jq
echo "🔧 Minificando JSON..."
MINIFIED=$(jq -c . "$1")

if [ $? -ne 0 ]; then
  echo "❌ Error: El archivo JSON no es válido"
  exit 1
fi

echo "✅ JSON minificado correctamente"
echo ""
echo "=================================================="
echo "📋 COPIA ESTE VALOR PARA RENDER:"
echo "=================================================="
echo ""
echo "$MINIFIED"
echo ""
echo "=================================================="
echo ""
echo "📝 Pasos para configurar en Render:"
echo ""
echo "  1. Ve a https://dashboard.render.com"
echo "  2. Selecciona tu Web Service (backend)"
echo "  3. Ve a la pestaña 'Environment'"
echo "  4. Click en 'Add Environment Variable'"
echo "  5. Configura:"
echo "     - Key: FIREBASE_SERVICE_ACCOUNT"
echo "     - Value: (pega el JSON de arriba)"
echo "  6. Click en 'Save Changes'"
echo "  7. Render reiniciará automáticamente"
echo ""
echo "✅ Después del reinicio, verifica los logs:"
echo "   Deberías ver: '✅ Firebase Admin initialized successfully'"
echo ""

# Guardar en archivo temporal
echo "$MINIFIED" > firebase-env-value.txt
echo "💾 También guardado en: firebase-env-value.txt"
echo "   (puedes copiar desde este archivo si es más fácil)"
echo ""
