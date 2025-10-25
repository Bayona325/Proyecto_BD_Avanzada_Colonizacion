# Proyecto de Base de Datos E-commerce

## 📘 Descripción del Proyecto

Este proyecto implementa el diseño, desarrollo y automatización de una base de datos avanzada para un **sistema de comercio electrónico (E-commerce)**.
El objetivo principal es gestionar de forma eficiente y segura los productos, clientes, ventas, inventarios y demás procesos críticos del negocio.
La base de datos está optimizada para **consultas analíticas, auditorías automáticas y mantenimiento programado**, garantizando **integridad, escalabilidad y trazabilidad de la información**.

---

## 👥 Integrantes del Equipo

- Adrián David Bayona Solano
- Juan José Rivero Camargo
- Andrés Felipe perea Carballido

---

## ⚙️ Requisitos Técnicos

- **Gestor de Base de Datos:** MySQL 8.0 o superior
- **Modo de Ejecución:** Se recomienda activar el `event_scheduler` y tener permisos administrativos para ejecutar funciones, triggers y procedimientos.
- **Codificación:** UTF-8
- **Motor de almacenamiento:** InnoDB

---

## 🧩 Estructura del Repositorio

El repositorio debe tener los siguientes archivos en la raíz:

```
Proyecto_BD_Avanzada_Colonizacion/
│
├── 01_Esquema_y_Datos.sql
├── 02_Consultas_Avanzadas.sql
├── 03_Funciones.sql
├── 04_Seguridad.sql
├── 05_Triggers.sql
├── 06_Eventos.sql
├── 07_Procedimientos_Almacenados.sql
├── Proyecto_BD_Avanzada_Colonizacion.png
└── README.md
```

---

## 🚀 Instrucciones de Ejecución

Para recrear completamente la base de datos y todas sus funcionalidades, sigue el siguiente orden:

### 🧱 1. Crear el esquema y cargar los datos base

Ejecutar:

```sql
SOURCE 01_Esquema_y_Datos.sql;
```

📄 Este archivo:

- Crea todas las tablas principales (`Productos`, `Clientes`, `Ventas`, `Detalle_Ventas`, etc.).
- Inserta datos de ejemplo realistas en cada tabla.
- Define relaciones mediante claves foráneas.

---

### 📊 2. Consultas de análisis y reportes

Ejecutar:

```sql
SOURCE 02_Consultas_Avanzadas.sql;
```

📄 Este archivo contiene **20 consultas SQL avanzadas** que responden preguntas de negocio como:

- Top 10 productos más vendidos
- Clientes con mayor valor de vida (LTV)
- Rotación de inventario por categoría
- Segmentación RFM y predicción de demanda simple

---

### 🧠 3. Funciones definidas por el usuario (UDFs)

Ejecutar:

```sql
SOURCE 03_Funciones.sql;
```

📄 Este archivo implementa **20 funciones** que encapsulan lógica de negocio reutilizable, tales como:

- `fn_CalcularTotalVenta`
- `fn_VerificarDisponibilidadStock`
- `fn_DeterminarEstadoLealtad`
- `fn_ValidarComplejidadContraseña`

---

### 🔐 4. Configuración de seguridad y roles

Ejecutar:

```sql
SOURCE 04_Seguridad.sql;
```

📄 Este script (por implementar) definirá **roles, permisos y usuarios** como:

- `Administrador_Sistema`, `Gerente_Marketing`, `Analista_Datos`, `Empleado_Inventario`, entre otros.
- Se establecerán políticas de contraseñas y auditorías de acceso.

---

### ⚙️ 5. Triggers (Disparadores)

Ejecutar:

```sql
SOURCE 05_Triggers.sql;
```

📄 Contendrá **20 triggers** para automatizar procesos:

- Auditoría de cambios de precio
- Validaciones de stock
- Actualización automática de totales y fechas
- Registro de eventos de negocio

---

### ⏰ 6. Eventos programados

Ejecutar:

```sql
SOURCE 06_Eventos.sql;
```

📄 Contendrá **20 eventos automáticos** que realizan tareas de mantenimiento y reportes:

- Generación semanal de reportes de ventas
- Limpieza de tablas temporales
- Recalculo nocturno de niveles de lealtad
- Backup automatizado

---

### 🧮 7. Procedimientos almacenados

Ejecutar:

```sql
SOURCE 07_Procedimientos_Almacenados.sql;
```

📄 Este archivo incluirá **20 procedimientos transaccionales** como:

- `sp_RealizarNuevaVenta`
- `sp_ProcesarDevolucion`
- `sp_GenerarReporteMensualVentas`
- `sp_RegistrarNuevoCliente`

---

## 🧾 Consideraciones Finales

- Todos los scripts deben ejecutarse en el orden indicado.
- Los nombres de tablas y funciones deben coincidir exactamente con los definidos en el esquema.
- Antes de ejecutar los eventos, asegúrate de habilitar el programador:

  ```sql
  SET GLOBAL event_scheduler = ON;
  ```
- Se recomienda crear una base de datos limpia antes de comenzar:

  ```sql
  DROP DATABASE IF EXISTS ecommerce_db;
  CREATE DATABASE ecommerce_db;
  USE ecommerce_db;
  ```

---

## 🖼️ Diagrama Entidad-Relación

El archivo `Proyecto_BD_Avanzada_Colonizacion.png` contiene el **modelo visual de la base de datos**, mostrando las relaciones entre entidades principales y sus claves foráneas.

---

## ✅ Estado del Proyecto

| Módulo              | Estado         | Archivos                            |
| ------------------- | -------------- | ----------------------------------- |
| Esquema y Datos     | ✅ Completo     | `01_Esquema_y_Datos.sql`            |
| Consultas Avanzadas | ✅ Completo     | `02_Consultas_Avanzadas.sql`        |
| Funciones (UDFs)    | ✅ Completo     | `03_Funciones.sql`                  |
| Seguridad           | 🚧 En progreso | `04_Seguridad.sql`                  |
| Triggers            | ✅ Completo   | `05_Triggers.sql`                   |
| Eventos             | ✅ Completo   | `06_Eventos.sql`                    |
| Procedimientos      | ✅ Completo   | `07_Procedimientos_Almacenados.sql` |

---
