import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv # type: ignore
import time

load_dotenv()


class NullCursor:
    def execute(self, *args, **kwargs):
        return None

    def fetchone(self):
        return None

    def fetchall(self):
        return []

    def close(self):
        return None
    
    # Simular atributos usados por el código (por ejemplo lastrowid)
    @property
    def lastrowid(self):
        return None

    @property
    def rowcount(self):
        return 0


class NullConnection:
    """Objeto conexión nulo que evita que la app lance excepciones si no hay DB."""
    def cursor(self, dictionary=False):
        return NullCursor()

    def commit(self):
        return None

    def close(self):
        return None
    
    def is_connected(self):
        return False

    def ping(self, reconnect=False, attempts=1, delay=0):
        return False


def create_connection(retries: int = 3, delay: float = 1.0):
    """Intenta crear una conexión MySQL. Si falla, devuelve un objeto NullConnection.

    - Usa variables de entorno de Railway: MYSQLHOST, MYSQLUSER, MYSQLPASSWORD, MYSQLDATABASE, MYSQLPORT
    - Reintenta 'retries' veces con 'delay' segundos.
    """
    # PRINT 1: Mostrar variables de entorno disponibles
    print("\n" + "="*80)
    print("[PRINT 1] Buscando variables de entorno de Railway...")
    print(f"  MYSQLHOST={os.getenv('MYSQLHOST')}")
    print(f"  MYSQLUSER={os.getenv('MYSQLUSER')}")
    print(f"  MYSQLPASSWORD={'***' if os.getenv('MYSQLPASSWORD') else '(no encontrada)'}")
    print(f"  MYSQLDATABASE={os.getenv('MYSQLDATABASE')}")
    print(f"  MYSQLPORT={os.getenv('MYSQLPORT')}")
    print("="*80 + "\n")
    
    # VARIABLES DE RAILWAY (automáticamente inyectadas)
    host = os.getenv('MYSQLHOST') or os.getenv('DB_HOST', 'localhost')
    user = os.getenv('MYSQLUSER') or os.getenv('DB_USER', 'root')
    password = os.getenv('MYSQLPASSWORD') or os.getenv('MYSQL_ROOT_PASSWORD') or os.getenv('DB_PASSWORD', '')
    database = os.getenv('MYSQLDATABASE') or os.getenv('DB_NAME', 'gestiondeestudiantes')
    port = int(os.getenv('MYSQLPORT') or os.getenv('DB_PORT', '3306'))
    
    # PRINT 2: Mostrar valores finales que se van a usar
    print("[PRINT 2] Valores finales a usar para conectar:")
    print(f"  HOST: {host}")
    print(f"  USER: {user}")
    print(f"  DATABASE: {database}")
    print(f"  PORT: {port}")
    print(f"  PASSWORD: {'*' * len(password) if password else '(vacío)'}\n")
    
    # CONFIGURACIÓN SSL PARA RAILWAY
    ssl_config = {}
    if 'railway' in str(host) or os.getenv('RAILWAY_ENVIRONMENT'):
        print("[PRINT 3] Detectado entorno Railway - Activando SSL...\n")
        ssl_config = {
            'ssl_disabled': False,
            'ssl_verify_identity': False,
            'ssl_ca': None,
        }

    last_error = None
    for attempt in range(1, retries + 1):
        try:
            print(f"[PRINT 4.{attempt}] Intento {attempt}/{retries} de conexión...")
            connection = mysql.connector.connect(
                host=host,
                user=user,
                password=password,
                database=database,
                port=port,
                connection_timeout=5,
                **ssl_config  # Parámetros SSL para Railway
            )
            if connection.is_connected():
                print(f"[PRINT 5] ✓ ÉXITO: Conectado a MySQL en {host}:{port} (usuario={user}).\n")
                return connection
        except Error as e:
            last_error = e
            print(f"[PRINT 6.{attempt}] ✗ Error MySQL (intento {attempt}/{retries}): {e}\n")
            # Si es error de SSL, intentar sin SSL
            if "SSL" in str(e):
                print(f"[PRINT 7] Detectado error SSL - Intentando conexión sin SSL...\n")
                try:
                    connection = mysql.connector.connect(
                        host=host,
                        user=user,
                        password=password,
                        database=database,
                        port=port,
                        connection_timeout=5,
                        ssl_disabled=True
                    )
                    if connection.is_connected():
                        print(f"[PRINT 8] ✓ ÉXITO: Conectado SIN SSL a {host}:{port}\n")
                        return connection
                except Error as e2:
                    last_error = e2
                    print(f"[PRINT 9] ✗ Error sin SSL: {e2}\n")
            time.sleep(delay)
        except Exception as e:
            last_error = e
            print(f"[PRINT 10] ✗ Error general: {e}\n")
            time.sleep(delay)

    # Si llegamos aquí es porque no se pudo conectar
    print("="*80)
    print("[PRINT 11] ✗ FALLO: No fue posible conectar a MySQL.")
    print("Usando conexión nula (la aplicación funcionará en modo degradado).")
    print("\nVariables de conexión usadas:")
    print(f"  HOST: {host}")
    print(f"  USER: {user}")
    print(f"  DATABASE: {database}")
    print(f"  PORT: {port}")
    print(f"  PASSWORD: {'*' * len(password) if password else '(vacío)'}")
    print(f"\nÚltimo error: {last_error}")
    print("="*80 + "\n")
    return NullConnection()