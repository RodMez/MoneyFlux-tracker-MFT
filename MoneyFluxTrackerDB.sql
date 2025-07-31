-- Creación de la base de datos si no existe
CREATE DATABASE IF NOT EXISTS MoneyFluxTrackerDB;

-- Usar la base de datos
USE MoneyFluxTrackerDB;

-- -----------------------------------------------------
-- Tabla Usuario
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Usuario (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  rol ENUM('superadmin', 'admin', 'usuario', 'invitado') NOT NULL DEFAULT 'usuario',
  activo BOOLEAN NOT NULL DEFAULT TRUE,
  fecha_ultimo_acceso DATETIME NULL,
  fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------
-- Tabla Cuenta
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Cuenta (
  id INT PRIMARY KEY AUTO_INCREMENT,
  usuario_id INT NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  saldo_actual DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
  tipo ENUM('Ahorro', 'Corriente', 'Efectivo', 'Digital') NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Tabla Categoria
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Categoria (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  tipo ENUM('Ingreso', 'Gasto') NOT NULL
);

-- -----------------------------------------------------
-- MEJORA 1 IMPLEMENTADA: Tabla Operacion
-- Tabla Operacion (reemplaza Movimiento y Transaccion)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Operacion (
  id INT PRIMARY KEY AUTO_INCREMENT,
  usuario_id INT NOT NULL,
  tipo ENUM('Ingreso', 'Gasto', 'Transferencia') NOT NULL,
  monto DECIMAL(15, 2) NOT NULL,
  fecha_hora DATETIME NOT NULL,
  descripcion TEXT NULL,
  categoria_id INT NULL,
  cuenta_origen_id INT NULL,
  cuenta_destino_id INT NULL,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE,
  FOREIGN KEY (categoria_id) REFERENCES Categoria(id),
  FOREIGN KEY (cuenta_origen_id) REFERENCES Cuenta(id),
  FOREIGN KEY (cuenta_destino_id) REFERENCES Cuenta(id),
  CONSTRAINT chk_ingreso CHECK (
    (tipo != 'Ingreso') OR (cuenta_origen_id IS NULL AND cuenta_destino_id IS NOT NULL AND categoria_id IS NOT NULL)
  ),
  CONSTRAINT chk_gasto CHECK (
    (tipo != 'Gasto') OR (cuenta_origen_id IS NOT NULL AND cuenta_destino_id IS NULL AND categoria_id IS NOT NULL)
  ),
  CONSTRAINT chk_transferencia CHECK (
    (tipo != 'Transferencia') OR (cuenta_origen_id IS NOT NULL AND cuenta_destino_id IS NOT NULL AND categoria_id IS NULL)
  )
);

-- -----------------------------------------------------
-- MEJORA 2 IMPLEMENTADA: Tabla OperacionRecurrente
-- Esta tabla almacena las plantillas para las operaciones automáticas.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS OperacionRecurrente (
  id INT PRIMARY KEY AUTO_INCREMENT,
  usuario_id INT NOT NULL,
  
  -- Información de la plantilla (qué crear)
  tipo ENUM('Ingreso', 'Gasto', 'Transferencia') NOT NULL,
  monto DECIMAL(15, 2) NOT NULL,
  descripcion TEXT NULL,
  categoria_id INT NULL, 
  cuenta_origen_id INT NULL, 
  cuenta_destino_id INT NULL,
  
  -- Reglas de la recurrencia (cuándo crearlo)
  frecuencia ENUM('Diaria', 'Semanal', 'Quincenal', 'Mensual', 'Anual') NOT NULL,
  fecha_inicio DATETIME NOT NULL,
  fecha_proxima_ejecucion DATETIME NOT NULL,
  fecha_fin DATETIME NULL, -- NULL si es para siempre
  activo BOOLEAN NOT NULL DEFAULT TRUE,

  FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE,
  FOREIGN KEY (categoria_id) REFERENCES Categoria(id),
  FOREIGN KEY (cuenta_origen_id) REFERENCES Cuenta(id),
  FOREIGN KEY (cuenta_destino_id) REFERENCES Cuenta(id),

  -- Se pueden añadir las mismas restricciones CHECK que en la tabla Operacion
  CONSTRAINT chk_recurrente_ingreso CHECK (
    (tipo != 'Ingreso') OR (cuenta_origen_id IS NULL AND cuenta_destino_id IS NOT NULL AND categoria_id IS NOT NULL)
  ),
  CONSTRAINT chk_recurrente_gasto CHECK (
    (tipo != 'Gasto') OR (cuenta_origen_id IS NOT NULL AND cuenta_destino_id IS NULL AND categoria_id IS NOT NULL)
  ),
  CONSTRAINT chk_recurrente_transferencia CHECK (
    (tipo != 'Transferencia') OR (cuenta_origen_id IS NOT NULL AND cuenta_destino_id IS NOT NULL AND categoria_id IS NULL)
  )
);

-- -----------------------------------------------------
-- Tabla Meta
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Meta (
  id INT PRIMARY KEY AUTO_INCREMENT,
  usuario_id INT NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  monto_objetivo DECIMAL(15, 2) NOT NULL,
  monto_actual DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
  fecha_hora_limite DATETIME NULL,
  descripcion TEXT,
  estado ENUM('En progreso', 'Completada', 'Pendiente') NOT NULL DEFAULT 'Pendiente',
  FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Tabla ProgresoMeta
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS ProgresoMeta (
  id INT PRIMARY KEY AUTO_INCREMENT,
  meta_id INT NOT NULL,
  fecha_hora DATETIME NOT NULL,
  aporte DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (meta_id) REFERENCES Meta(id) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Tabla Notificacion
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Notificacion (
  id INT PRIMARY KEY AUTO_INCREMENT,
  usuario_id INT NOT NULL,
  mensaje TEXT NOT NULL,
  tipo ENUM('Meta', 'Gasto', 'Saldo', 'General') NOT NULL,
  leido BOOLEAN NOT NULL DEFAULT FALSE,
  fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Tabla Recordatorio
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Recordatorio (
  id INT PRIMARY KEY AUTO_INCREMENT,
  usuario_id INT NOT NULL,
  titulo VARCHAR(100) NOT NULL,
  descripcion TEXT,
  fecha_hora_recordatorio DATETIME NOT NULL,
  repeticion ENUM('Ninguna', 'Diaria', 'Semanal', 'Mensual') NOT NULL DEFAULT 'Ninguna',
  activo BOOLEAN NOT NULL DEFAULT TRUE,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE
); 