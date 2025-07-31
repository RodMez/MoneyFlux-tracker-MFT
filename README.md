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

![Diagrama entidad-relación de la base de datos](MFTDB-V1.png)

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

De acuerdo. Dejando a un lado la optimización de rendimiento con índices, y partiendo de la base de que tu esquema actual es excelente y funcional, podemos enfocar el análisis en **posibles mejoras evolutivas**.

Estas no son correcciones de errores (porque no los hay), sino **ideas para futuras versiones de tu aplicación** que añadirían funcionalidades más potentes y harían tu modelo aún más flexible y completo.

Aquí tienes un análisis profundo con posibles mejoras para "MoneyFluxTracker v2.0":

---

### **Análisis de Mejoras Potenciales (Evolución del Modelo)**

#### **Mejora 1: Fusionar `Movimiento` y `Transaccion` en una tabla `Operacion`**

*   **El "Porqué":** Actualmente tienes una separación limpia entre movimientos (que alteran tu patrimonio) y transacciones (que solo mueven dinero entre cuentas). Esto es bueno, pero tiene una desventaja: si quieres ver un historial cronológico completo de *toda* tu actividad financiera (gastos, ingresos y transferencias), necesitas consultar dos tablas y unir los resultados. Una tabla unificada simplificaría drásticamente los reportes y la visualización de la línea de tiempo.

*   **La Implementación:**
    *   Crear una única tabla llamada `Operacion`.
    *   Añadir una columna `tipo ENUM('Ingreso', 'Gasto', 'Transferencia')`.
    *   La tabla tendría `cuenta_id` (para ingresos/gastos) y `cuenta_destino_id` (que sería `NULL` para ingresos/gastos, pero contendría el ID de la cuenta de destino para las transferencias).
    *   `categoria_id` sería `NULL` para las operaciones de tipo 'Transferencia'.

*   **Ventaja:** Simplifica la lógica de la aplicación para obtener un "estado de cuenta" o historial unificado. Una sola consulta para obtener toda la actividad.

---

#### **Mejora 2: Modelar Explícitamente los Movimientos Recurrentes**

*   **El "Porqué":** Tu tabla `Recordatorio` es genial para alertarte de que debes hacer un pago. Sin embargo, no automatiza el registro. Las mejores apps financieras permiten definir gastos o ingresos fijos (el arriendo, el salario, la cuota de la moto) y los registran automáticamente cada mes. Esto es clave para desarrollar buenos hábitos y tener una previsión financiera real.

*   **La Implementación:**
    *   Crear una nueva tabla `MovimientoRecurrente`.
    *   Campos: `id`, `usuario_id`, `cuenta_id`, `categoria_id`, `monto`, `descripcion`, `frecuencia ENUM('Diaria', 'Semanal', 'Quincenal', 'Mensual')`, `fecha_inicio`, `fecha_fin` (opcional).
    *   Tu aplicación tendría un proceso (un "cron job" o tarea programada) que cada día revisa esta tabla y crea los registros correspondientes en la tabla `Movimiento`.

*   **Ventaja:** Automatiza gran parte de la entrada de datos, reduce el error humano y permite hacer proyecciones de flujo de caja a futuro con gran precisión.

---

#### **Mejora 3: Implementar un Sistema de Presupuestos (`Budgeting`)**

*   **El "Porqué":** Las metas de ahorro (`Meta`) son para un objetivo específico. Pero para el control del día a día, la herramienta más poderosa es un presupuesto. Te permite definir un límite de gasto por categoría para un periodo (ej: "No gastar más de $300.000 en 'Comida' este mes"). Esto ataca directamente tu objetivo de "desarrollar buenos hábitos financieros".

*   **La Implementación:**
    *   Crear una nueva tabla `Presupuesto`.
    *   Campos: `id`, `usuario_id`, `categoria_id` (para presupuestar por categoría), `monto_limite DECIMAL(15,2)`, `periodo ENUM('Semanal', 'Mensual', 'Anual')`, `fecha_inicio`.
    *   La aplicación podría entonces mostrarte barras de progreso de tus presupuestos, comparando el total de gastos de una categoría contra el límite que estableciste.

*   **Ventaja:** Transforma tu app de ser un simple rastreador de gastos a ser una herramienta proactiva de planificación y control financiero.

---

#### **Mejora 4: Modelar Deudas y Activos de Inversión de Forma Detallada**

*   **El "Porqué":** En tu descripción inicial mencionaste préstamos. Un préstamo es más que un simple gasto mensual (`la cuota de $181.000`). Es una deuda con un monto total, un saldo pendiente y, posiblemente, una tasa de interés. Lo mismo ocurrirá cuando empieces a invertir. Un activo tiene un valor que fluctúa. El esquema actual no captura esta complejidad.

*   **La Implementación:**
    *   Crear una tabla `Deuda`:
        *   Campos: `id`, `usuario_id`, `nombre` (ej: "Préstamo Moto"), `monto_total`, `saldo_pendiente`, `tasa_interes`, `fecha_adquisicion`. Cada pago en `Movimiento` reduciría el `saldo_pendiente`.
    *   Crear una tabla `ActivoInversion`:
        *   Campos: `id`, `usuario_id`, `nombre` (ej: "Acciones Ecopetrol"), `tipo` (ej: 'Acciones', 'Cripto'), `valor_compra`, `valor_actual`, `cantidad`.

*   **Ventaja:** Permite calcular tu **patrimonio neto real** (Activos - Deudas), una métrica financiera fundamental. Prepara tu aplicación para tu objetivo a largo plazo de gestionar inversiones.





## V2 - Unificación de Movimientos y Transacciones: Tabla `Operacion`

### **Resumen del Cambio**
Se introduce la tabla central `Operacion`, que reemplaza a las tablas `Movimiento` y `Transaccion`.  
Esto permite registrar todas las actividades financieras (ingresos, gastos y transferencias) en una sola tabla, facilitando la consulta y el análisis.

### **Estructura de la Tabla `Operacion`**

| Campo              | Tipo                              | Descripción                                                                 |
|--------------------|-----------------------------------|-----------------------------------------------------------------------------|
| id                 | INT, PK, AUTO_INCREMENT           | Identificador único de la operación                                         |
| usuario_id         | INT, FK                           | Usuario propietario de la operación                                         |
| tipo               | ENUM('Ingreso','Gasto','Transferencia') | Tipo de operación                                                          |
| monto              | DECIMAL(15,2)                     | Monto de la operación                                                      |
| fecha_hora         | DATETIME                          | Fecha y hora de la operación                                               |
| descripcion        | TEXT                              | Descripción opcional                                                       |
| categoria_id       | INT, FK, NULLABLE                 | Categoría (solo para Ingreso y Gasto)                                      |
| cuenta_origen_id   | INT, FK, NULLABLE                 | Cuenta de origen (ver reglas abajo)                                        |
| cuenta_destino_id  | INT, FK, NULLABLE                 | Cuenta de destino (ver reglas abajo)                                       |

### **Reglas según el tipo de operación**

- **Ingreso:**  
  - `cuenta_origen_id` = NULL  
  - `cuenta_destino_id` = cuenta que recibe el dinero  
  - `categoria_id` = obligatoria

- **Gasto:**  
  - `cuenta_origen_id` = cuenta de la que sale el dinero  
  - `cuenta_destino_id` = NULL  
  - `categoria_id` = obligatoria

- **Transferencia:**  
  - `cuenta_origen_id` = cuenta de origen  
  - `cuenta_destino_id` = cuenta de destino  
  - `categoria_id` = NULL

### **Ejemplo de consulta para historial financiero**

```sql
SELECT * FROM Operacion WHERE usuario_id = ? ORDER BY fecha_hora DESC;
```

### **Ventajas de este modelo**
- Historial unificado y ordenado.
- Menos tablas y lógica más simple.
- Integridad garantizada por restricciones CHECK.

