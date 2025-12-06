"""
Configuración centralizada del proyecto Campus
"""

import os
from datetime import timedelta

# Configuración de la aplicación Flask
class Config:
    """Configuración base."""
    SECRET_KEY = os.getenv('SECRET_KEY', 'clave_secreta_gestion_estudiantil_2023')
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'
    PERMANENT_SESSION_LIFETIME = timedelta(hours=24)
    
    # Configuración de base de datos - USAR VARIABLES DE RAILWAY
    DB_HOST = os.getenv('MYSQLHOST', 'localhost')
    DB_USER = os.getenv('MYSQLUSER', 'root')
    DB_PASSWORD = os.getenv('MYSQLPASSWORD', os.getenv('MYSQL_ROOT_PASSWORD', ''))
    DB_NAME = os.getenv('MYSQLDATABASE', 'GestionDeEstudiantes')
    DB_PORT = int(os.getenv('MYSQLPORT', '3306'))
    
    # Email - USAR VARIABLES DE ENTORNO
    EMAIL_HOST = os.getenv('EMAIL_HOST', 'smtp.gmail.com')
    EMAIL_PORT = int(os.getenv('EMAIL_PORT', '587'))
    EMAIL_HOST_USER = os.getenv('EMAIL_HOST_USER', 'kevin.esteban.cuero@correounivalle.edu.co')
    EMAIL_HOST_PASSWORD = os.getenv('EMAIL_HOST_PASSWORD', '1234')
    
    # Rutas
    TEMPLATE_FOLDER = 'Views'
    STATIC_FOLDER = 'Static'
    
    # Configuraciones de sesión
    MAX_SESSION_TIME = 3600  # 1 hora en segundos
    
    # Configuración para Railway/Producción
    PREFERRED_URL_SCHEME = 'https' if os.getenv('RAILWAY_ENVIRONMENT') else 'http'
    SERVER_NAME = os.getenv('RAILWAY_STATIC_URL', None)


class DevelopmentConfig(Config):
    """Configuración para desarrollo."""
    DEBUG = True
    TESTING = False
    # En desarrollo usar HTTP
    PREFERRED_URL_SCHEME = 'http'


class ProductionConfig(Config):
    """Configuración para producción."""
    DEBUG = os.getenv('FLASK_DEBUG', '0') == '1'
    TESTING = False
    # Forzar HTTPS en producción
    PREFERRED_URL_SCHEME = 'https'
    SESSION_COOKIE_SECURE = True


class TestingConfig(Config):
    """Configuración para testing."""
    DEBUG = True
    TESTING = True
    DB_NAME = os.getenv('MYSQLDATABASE_TEST', 'GestionDeEstudiantes_test')


# Seleccionar configuración según el entorno
config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}

def get_config(env=None):
    """Obtiene la configuración según el entorno."""
    if env is None:
        env = os.getenv('FLASK_ENV', 'development')
    return config.get(env, config['default'])