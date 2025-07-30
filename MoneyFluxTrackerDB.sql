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
-- Tabla Movimiento
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Movimiento (
  id INT PRIMARY KEY AUTO_INCREMENT,
  usuario_id INT NOT NULL,
  cuenta_id INT NOT NULL,
  categoria_id INT NOT NULL,
  fecha_hora DATETIME NOT NULL,
  monto DECIMAL(15, 2) NOT NULL,
  descripcion TEXT,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE,
  FOREIGN KEY (cuenta_id) REFERENCES Cuenta(id),
  FOREIGN KEY (categoria_id) REFERENCES Categoria(id)
);

-- -----------------------------------------------------
-- Tabla Transaccion
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Transaccion (
  id INT PRIMARY KEY AUTO_INCREMENT,
  usuario_id INT NOT NULL,
  cuenta_origen_id INT NOT NULL,
  cuenta_destino_id INT NOT NULL,
  fecha_hora DATETIME NOT NULL,
  monto DECIMAL(15, 2) NOT NULL,
  descripcion TEXT,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE,
  FOREIGN KEY (cuenta_origen_id) REFERENCES Cuenta(id),
  FOREIGN KEY (cuenta_destino_id) REFERENCES Cuenta(id)
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