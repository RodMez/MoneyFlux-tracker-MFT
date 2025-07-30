### **Documentación del Proyecto: Base de Datos "MoneyFluxTracker" (MFT)**

**Versión del Documento:** 1.0
**Fecha:** 27 de julio de 2025

#### **1. Resumen del Proyecto**

MoneyFluxTracker (MFT) es una aplicación de finanzas personales diseñada para proporcionar claridad, control y fomentar buenos hábitos financieros. El núcleo de la aplicación es una base de datos relacional robusta que registra ingresos, gastos, cuentas, metas de ahorro y recordatorios.

Este documento detalla la estructura final de la base de datos en su versión 1.0 y describe una hoja de ruta con posibles mejoras y funcionalidades para futuras versiones.

---

### **2. Diseño de la Base de Datos (Versión 1.0)**

La versión 1.0 está diseñada para ser funcional, coherente y robusta, aplicando las mejores prácticas de diseño para garantizar la integridad y la legibilidad de los datos.

#### **2.1. Principios de Diseño Aplicados**

- **Normalización:** La estructura evita la redundancia de datos. La decisión clave fue eliminar el campo `tipo` de la tabla `Movimiento`, dejando a `Categoria` como la única fuente de verdad.
- **Consistencia de Nomenclatura:** Todos los nombres de tablas y columnas están en español y siguen un patrón lógico (ej: `fecha_creacion`, `fecha_hora_limite`).
- **Estandarización de Tipos de Dato:**
  - **Finanzas:** Se utiliza `DECIMAL(15, 2)` para todos los campos monetarios, garantizando precisión.
  - **Fechas:** Se utiliza `DATETIME` de forma estándar para registrar la fecha y la hora de todos los eventos.
  - **Booleanos:** Se utiliza el tipo `BOOLEAN` para claridad semántica.

#### **2.2. Descripción Detallada de las Tablas**

- **`Usuario`**: Almacena la información de los usuarios. Es la tabla central del sistema.
- **`Cuenta`**: Registra las diferentes fuentes de dinero del usuario (efectivo, banco, cuenta digital).
- **`Categoria`**: Clasifica los movimientos como 'Ingreso' o 'Gasto' con una etiqueta específica (Comida, Transporte, Salario).
- **`Movimiento`**: Registra cada ingreso o gasto que afecta el saldo de una cuenta.
- **`Transaccion`**: Registra las transferencias de dinero entre dos cuentas del mismo usuario. No altera el patrimonio neto.
- **`Meta`**: Permite al usuario definir objetivos de ahorro con un monto y una fecha límite.
- **`ProgresoMeta`**: Registra cada aporte individual realizado para alcanzar una meta.
- **`Notificacion`**: Almacena mensajes generados por la aplicación para el usuario.
- **`Recordatorio`**: Guarda recordatorios de eventos o pagos futuros.

#### **2.3. Script SQL para Creación (v1.0)**

Este es el script final y aprobado para la creación de la base de datos.

```sql
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
```

---

### **3. Hoja de Ruta de Mejoras Futuras (v2.0 y Posteriores)**

Esta sección describe funcionalidades potenciales que pueden ser implementadas en futuras versiones para enriquecer la aplicación.

#### **Mejora 1: Unificar `Movimiento` y `Transaccion`**

- **Oportunidad:** Simplificar la consulta del historial completo de actividades financieras en una sola vista cronológica.
- **Solución Propuesta:** Fusionar ambas tablas en una sola tabla `Operacion` con un campo `tipo ENUM('Ingreso', 'Gasto', 'Transferencia')`.
- **Beneficio:** Facilita la lógica de la aplicación para generar reportes y vistas de "estado de cuenta" unificadas.

#### **Mejora 2: Automatización de Movimientos Recurrentes**

- **Oportunidad:** Automatizar el registro de ingresos y gastos fijos (salarios, arriendos, suscripciones) para reducir la entrada manual de datos.
- **Solución Propuesta:** Crear una tabla `MovimientoRecurrente` que defina la frecuencia y el monto. Un proceso automático (cron job) registraría las operaciones en la tabla `Movimiento` en las fechas correspondientes.
- **Beneficio:** Aumenta la precisión, ahorra tiempo al usuario y permite proyecciones financieras más exactas.

#### **Mejora 3: Sistema de Presupuestos (Budgeting)**

- **Oportunidad:** Pasar de un seguimiento reactivo a una planificación proactiva, permitiendo al usuario fijar límites de gasto por categoría.
- **Solución Propuesta:** Crear una tabla `Presupuesto` que relacione una `categoria_id` con un `monto_limite` para un periodo de tiempo definido.
- **Beneficio:** Es una herramienta de control financiero muy poderosa que fomenta directamente la creación de buenos hábitos.

#### **Mejora 4: Modelado Detallado de Deudas y Activos**

- **Oportunidad:** Obtener una visión completa del patrimonio neto del usuario, considerando no solo el flujo de dinero, sino también el valor de sus deudas y activos.
- **Solución Propuesta:** Crear tablas especializadas como `Deuda` (con campos para saldo pendiente, interés, etc.) y `ActivoInversion` (con campos para valor de compra, valor actual, etc.).
- **Beneficio:** Prepara la aplicación para la gestión de inversiones y proporciona la métrica financiera más importante: el patrimonio neto real (Activos - Deudas).
