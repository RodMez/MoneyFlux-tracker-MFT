-- =====================================================
-- SECCIÓN DE LIMPIEZA (DROP)
-- Ejecuta esto para borrar cualquier estructura previa
-- =====================================================
DROP TABLE IF EXISTS Recordatorio CASCADE;
DROP TABLE IF EXISTS Notificacion CASCADE;
DROP TABLE IF EXISTS ProgresoMeta CASCADE;
DROP TABLE IF EXISTS Meta CASCADE;
DROP TABLE IF EXISTS Presupuesto CASCADE;
DROP TABLE IF EXISTS OperacionRecurrente CASCADE;
DROP TABLE IF EXISTS Operacion CASCADE;
DROP TABLE IF EXISTS Categoria CASCADE;
DROP TABLE IF EXISTS Cuenta CASCADE;
DROP TABLE IF EXISTS Usuario CASCADE;

DROP TYPE IF EXISTS rol_usuario;
DROP TYPE IF EXISTS tipo_cuenta;
DROP TYPE IF EXISTS tipo_categoria;
DROP TYPE IF EXISTS tipo_operacion;
DROP TYPE IF EXISTS frecuencia_recurrencia;
DROP TYPE IF EXISTS estado_meta;
DROP TYPE IF EXISTS tipo_notificacion;
DROP TYPE IF EXISTS repeticion_recordatorio;

-- =====================================================
-- SECCIÓN DE CREACIÓN (CREATE)
-- =====================================================

-- -----------------------------------------------------
-- Creación de Tipos ENUM para PostgreSQL
-- -----------------------------------------------------
CREATE TYPE rol_usuario AS ENUM ('superadmin', 'admin', 'usuario', 'invitado');
CREATE TYPE tipo_cuenta AS ENUM ('Ahorro', 'Corriente', 'Efectivo', 'Digital');
CREATE TYPE tipo_categoria AS ENUM ('Ingreso', 'Gasto');
CREATE TYPE tipo_operacion AS ENUM ('Ingreso', 'Gasto', 'Transferencia');
CREATE TYPE frecuencia_recurrencia AS ENUM ('Diaria', 'Semanal', 'Quincenal', 'Mensual', 'Anual');
CREATE TYPE estado_meta AS ENUM ('En progreso', 'Completada', 'Pendiente');
CREATE TYPE tipo_notificacion AS ENUM ('Meta', 'Gasto', 'Saldo', 'General');
CREATE TYPE repeticion_recordatorio AS ENUM ('Ninguna', 'Diaria', 'Semanal', 'Mensual');

-- -----------------------------------------------------
-- Tabla Usuario
-- -----------------------------------------------------
CREATE TABLE Usuario (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  rol rol_usuario NOT NULL DEFAULT 'usuario',
  activo BOOLEAN NOT NULL DEFAULT TRUE,
  fecha_ultimo_acceso TIMESTAMP NULL,
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------
-- Tabla Cuenta
-- -----------------------------------------------------
CREATE TABLE Cuenta (
  id SERIAL PRIMARY KEY,
  usuario_id INT NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  saldo_actual DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
  tipo tipo_cuenta NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Tabla Categoria
-- -----------------------------------------------------
CREATE TABLE Categoria (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  tipo tipo_categoria NOT NULL
);

-- -----------------------------------------------------
-- Tabla Operacion
-- -----------------------------------------------------
CREATE TABLE Operacion (
  id SERIAL PRIMARY KEY,
  usuario_id INT NOT NULL,
  tipo tipo_operacion NOT NULL,
  monto DECIMAL(15, 2) NOT NULL,
  fecha_hora TIMESTAMP NOT NULL,
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
-- Tabla OperacionRecurrente
-- -----------------------------------------------------
CREATE TABLE OperacionRecurrente (
  id SERIAL PRIMARY KEY,
  usuario_id INT NOT NULL,
  tipo tipo_operacion NOT NULL,
  monto DECIMAL(15, 2) NOT NULL,
  descripcion TEXT NULL,
  categoria_id INT NULL, 
  cuenta_origen_id INT NULL, 
  cuenta_destino_id INT NULL,
  frecuencia frecuencia_recurrencia NOT NULL,
  fecha_inicio TIMESTAMP NOT NULL,
  fecha_proxima_ejecucion TIMESTAMP NOT NULL,
  fecha_fin TIMESTAMP NULL,
  activo BOOLEAN NOT NULL DEFAULT TRUE,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE,
  FOREIGN KEY (categoria_id) REFERENCES Categoria(id),
  FOREIGN KEY (cuenta_origen_id) REFERENCES Cuenta(id),
  FOREIGN KEY (cuenta_destino_id) REFERENCES Cuenta(id),
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
-- Tabla Presupuesto
-- -----------------------------------------------------
CREATE TABLE Presupuesto (
  id SERIAL PRIMARY KEY,
  usuario_id INT NOT NULL,
  categoria_id INT NOT NULL,
  monto_limite DECIMAL(15, 2) NOT NULL,
  periodo frecuencia_recurrencia NOT NULL DEFAULT 'Mensual',
  fecha_inicio TIMESTAMP NOT NULL,
  activo BOOLEAN NOT NULL DEFAULT TRUE,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE,
  FOREIGN KEY (categoria_id) REFERENCES Categoria(id),
  UNIQUE (usuario_id, categoria_id, periodo) 
);

-- -----------------------------------------------------
-- Tabla Meta
-- -----------------------------------------------------
CREATE TABLE Meta (
  id SERIAL PRIMARY KEY,
  usuario_id INT NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  monto_objetivo DECIMAL(15, 2) NOT NULL,
  monto_actual DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
  fecha_hora_limite TIMESTAMP NULL,
  descripcion TEXT,
  estado estado_meta NOT NULL DEFAULT 'Pendiente',
  FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Tabla ProgresoMeta
-- -----------------------------------------------------
CREATE TABLE ProgresoMeta (
  id SERIAL PRIMARY KEY,
  meta_id INT NOT NULL,
  fecha_hora TIMESTAMP NOT NULL,
  aporte DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (meta_id) REFERENCES Meta(id) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Tabla Notificacion
-- -----------------------------------------------------
CREATE TABLE Notificacion (
  id SERIAL PRIMARY KEY,
  usuario_id INT NOT NULL,
  mensaje TEXT NOT NULL,
  tipo tipo_notificacion NOT NULL,
  leido BOOLEAN NOT NULL DEFAULT FALSE,
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Tabla Recordatorio
-- -----------------------------------------------------
CREATE TABLE Recordatorio (
  id SERIAL PRIMARY KEY,
  usuario_id INT NOT NULL,
  titulo VARCHAR(100) NOT NULL,
  descripcion TEXT,
  fecha_hora_recordatorio TIMESTAMP NOT NULL,
  repeticion repeticion_recordatorio NOT NULL DEFAULT 'Ninguna',
  activo BOOLEAN NOT NULL DEFAULT TRUE,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE
);