
import psycopg2
import sys
import os
from dotenv import load_dotenv

# Cargar variables de entorno desde .env
load_dotenv(os.path.join(os.path.dirname(__file__), '../../.env'))

DB_HOST = os.getenv("POSTGRESQL_ADDON_HOST")
DB_NAME = os.getenv("POSTGRESQL_ADDON_DB")
DB_USER = os.getenv("POSTGRESQL_ADDON_USER")
DB_PASS = os.getenv("POSTGRESQL_ADDON_PASSWORD")
DB_PORT = os.getenv("POSTGRESQL_ADDON_PORT")

connection = None

try:
    # --- Intentar establecer la conexión ---
    print("Intentando conectar a la base de datos en Clever Cloud...")
    connection = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        sslmode='require'
    )
    cursor = connection.cursor()
    print("Conexión establecida. Verificando la versión de PostgreSQL...")
    cursor.execute("SELECT version();")
    db_version = cursor.fetchone()
    print("\n----------------------------------------------------")
    print("✅ ¡ÉXITO! La conexión se ha establecido correctamente.")
    print(f"La versión de la base de datos es: {db_version[0].split()[0]}")
    print("----------------------------------------------------\n")
    cursor.close()

except psycopg2.Error as e:
    print("\n----------------------------------------------------")
    print("❌ ¡FALLO! No se pudo conectar a la base de datos.")
    print("Error de PostgreSQL: (detalles ocultos por seguridad)")
    print("----------------------------------------------------\n")
    sys.exit(1)

finally:
    if connection is not None:
        connection.close()
        print("La conexión ha sido cerrada.")