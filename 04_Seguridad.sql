-- 0) USE la base de datos donde cargaste el esquema:
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- 1) Añadir columna 'ubicacion' a Productos (no existía; requerida para permisos de Inventario)
ALTER TABLE Productos
  ADD COLUMN ubicacion VARCHAR(100) DEFAULT 'almacen' AFTER stock;

-- 2) Tablas de auditoría y logs
CREATE TABLE IF NOT EXISTS price_logs (
  id_log INT AUTO_INCREMENT PRIMARY KEY,
  id_producto INT NOT NULL,
  precio_anterior DECIMAL(10,2),
  precio_nuevo DECIMAL(10,2),
  cambiado_por VARCHAR(255),
  fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

CREATE TABLE IF NOT EXISTS failed_logins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_attempt VARCHAR(255),
  host_attempt VARCHAR(255),
  intento_fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  motivo VARCHAR(255)
);

-- 3) Trigger para auditar cambios en precio (INSERT/UPDATE que altere precio)
DELIMITER $$
CREATE TRIGGER trg_product_price_update
BEFORE UPDATE ON Productos
FOR EACH ROW
BEGIN
  IF OLD.precio <> NEW.precio THEN
    INSERT INTO price_logs (id_producto, precio_anterior, precio_nuevo, cambiado_por)
      VALUES (OLD.id_producto, OLD.precio, NEW.precio, CURRENT_USER());
  END IF;
END$$
DELIMITER ;

-- 4) Procedimiento de ejemplo de reportes de marketing (para otorgar EXECUTE)
DROP PROCEDURE IF EXISTS sp_reportes_marketing;
DELIMITER $$
CREATE PROCEDURE sp_reportes_marketing()
BEGIN
  SELECT c.nombre as categoria, COUNT(dv.id_detalle) as unidades_vendidas,
         SUM(dv.precio_unitario_congelado * dv.cantidad) as total_facturado
  FROM Detalle_Ventas dv
  JOIN Productos p ON dv.id_producto = p.id_producto
  JOIN Categorias c ON p.id_categoria = c.id_categoria
  GROUP BY c.nombre;
END$$
DELIMITER ;

-- 5) Crear roles solicitados
CREATE ROLE IF NOT EXISTS Administrador_Sistema;
CREATE ROLE IF NOT EXISTS Gerente_Marketing;
CREATE ROLE IF NOT EXISTS Analista_Datos;
CREATE ROLE IF NOT EXISTS Empleado_Inventario;
CREATE ROLE IF NOT EXISTS Atencion_Cliente;
CREATE ROLE IF NOT EXISTS Auditor_Financiero;
CREATE ROLE IF NOT EXISTS Visitante;

-- 6) Privilegios del rol Administrador_Sistema (todos los privilegios)
GRANT ALL PRIVILEGES ON *.* TO Administrador_Sistema WITH ADMIN OPTION;

-- 7) Gerente_Marketing: acceso de solo lectura a ventas y clientes + permisos para ejecutar procedimientos de marketing
GRANT SELECT ON Ventas TO Gerente_Marketing;
GRANT SELECT ON Clientes TO Gerente_Marketing;
GRANT EXECUTE ON PROCEDURE ecommerce.sp_reportes_marketing TO Gerente_Marketing;

-- 8) Analista_Datos: solo lectura sobre todas las tablas EXCEPTO las de auditoría (price_logs, failed_logins)
GRANT SELECT ON ecommerce.* TO Analista_Datos;
REVOKE SELECT ON price_logs FROM Analista_Datos;
REVOKE SELECT ON failed_logins FROM Analista_Datos;

-- 9) Asegurar que el rol Analista_Datos no tenga DELETE ni TRUNCATE:
REVOKE DELETE, INSERT, UPDATE, CREATE, DROP, RELOAD, SHUTDOWN, FILE, PROCESS, GRANT OPTION ON *.* FROM Analista_Datos;

-- 10) Empleado_Inventario: puede modificar únicamente Productos(stock y ubicacion)
GRANT SELECT ON Productos TO Empleado_Inventario;
GRANT UPDATE (stock, ubicacion) ON Productos TO Empleado_Inventario;
REVOKE UPDATE (precio) ON Productos FROM Empleado_Inventario;

-- 11) Atencion_Cliente: puede ver clientes y ventas, pero no modificar precios
GRANT SELECT (id_cliente, nombre, apellido, email) ON Clientes TO Atencion_Cliente;
GRANT SELECT ON Ventas TO Atencion_Cliente;

-- 12) Auditor_Financiero: acceso lectura a ventas, productos y logs de precios
GRANT SELECT ON Ventas TO Auditor_Financiero;
GRANT SELECT ON Productos TO Auditor_Financiero;
GRANT SELECT ON price_logs TO Auditor_Financiero;

-- 13) Visitante: solo puede ver la tabla productos
GRANT SELECT (id_producto, nombre, descripcion, precio, stock, sku, activo, ubicacion) ON Productos TO Visitante;

-- 14) Crear usuarios y asignar roles
-- Usuarios creados con política de recursos mínima; ajustar contraseñas reales en producción.
CREATE USER IF NOT EXISTS 'admin_user'@'localhost' IDENTIFIED BY 'AdminPass#2025' PASSWORD EXPIRE NEVER;
CREATE USER IF NOT EXISTS 'marketing_user'@'%' IDENTIFIED BY 'Marketing#2025' PASSWORD EXPIRE NEVER;
CREATE USER IF NOT EXISTS 'inventory_user'@'%' IDENTIFIED BY 'Inventory#2025' PASSWORD EXPIRE NEVER;
CREATE USER IF NOT EXISTS 'support_user'@'%' IDENTIFIED BY 'Support#2025' PASSWORD EXPIRE NEVER;
CREATE USER IF NOT EXISTS 'analyst_user'@'%' IDENTIFIED BY 'Analyst#2025' PASSWORD EXPIRE NEVER;
CREATE USER IF NOT EXISTS 'visitante_user'@'%' IDENTIFIED BY 'Visit#2025' PASSWORD EXPIRE NEVER;

-- Asignar roles a usuarios
GRANT Administrador_Sistema TO 'admin_user'@'localhost';
GRANT Gerente_Marketing TO 'marketing_user'@'%';
GRANT Empleado_Inventario TO 'inventory_user'@'%';
GRANT Atencion_Cliente TO 'support_user'@'%';
GRANT Analista_Datos TO 'analyst_user'@'%';
GRANT Visitante TO 'visitante_user'@'%';

-- Activar roles por defecto en la sesión del usuario
SET DEFAULT ROLE Administrador_Sistema FOR 'admin_user'@'localhost';
SET DEFAULT ROLE Gerente_Marketing FOR 'marketing_user'@'%';
SET DEFAULT ROLE Empleado_Inventario FOR 'inventory_user'@'%';
SET DEFAULT ROLE Atencion_Cliente FOR 'support_user'@'%';
SET DEFAULT ROLE Analista_Datos FOR 'analyst_user'@'%';
SET DEFAULT ROLE Visitante FOR 'visitante_user'@'%';

-- 15) Impedir que el rol Analista_Datos ejecute comandos DELETE o TRUNCATE
REVOKE DELETE ON Productos FROM Analista_Datos;
REVOKE DELETE ON Ventas FROM Analista_Datos;

-- 16) Revocar permiso de UPDATE sobre la columna precio de Productos al rol Empleado_Inventario
REVOKE UPDATE ON Productos FROM Empleado_Inventario;
GRANT UPDATE (stock, ubicacion) ON Productos TO Empleado_Inventario;

-- 17) Política de contraseñas seguras (usar plugin validate_password)
SET GLOBAL validate_password.policy = MEDIUM;
SET GLOBAL validate_password.length = 12;
SET GLOBAL validate_password.mixed_case_count = 1;
SET GLOBAL validate_password.number_count = 1;
SET GLOBAL validate_password.special_char_count = 1;

-- 18) Asegurar que el usuario root no pueda ser usado desde conexiones remotas
DROP USER IF EXISTS 'root'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'StrongRootPassword#2025';

-- 19) Limitar número de consultas por hora para Analista_Datos -> se hace al crear usuario (MySQL limita por usuario)
ALTER USER 'analyst_user'@'%' WITH MAX_QUERIES_PER_HOUR 2000 MAX_UPDATES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 100 MAX_USER_CONNECTIONS 5;

-- 20) Asegurar que los usuarios solo puedan ver las ventas de la sucursal a la que pertenecen
DROP VIEW IF EXISTS v_ventas_sucursal;
CREATE VIEW v_ventas_sucursal AS
SELECT v.*
FROM Ventas v
WHERE v.id_sucursal = @session_sucursal_id;

-- Procedimiento para que la aplicación establezca la sucursal en la sesión (a ejecutar durante login)
DROP PROCEDURE IF EXISTS sp_set_sucursal_for_session;
DELIMITER $$
CREATE PROCEDURE sp_set_sucursal_for_session(IN p_employee_email VARCHAR(255))
BEGIN
  DECLARE v_id_sucursal INT;
  SELECT id_sucursal INTO v_id_sucursal
    FROM Empleados
    WHERE email = p_employee_email
    LIMIT 1;
  IF v_id_sucursal IS NULL THEN
    SET @session_sucursal_id = NULL;
  ELSE
    SET @session_sucursal_id = v_id_sucursal;
  END IF;
END$$
DELIMITER ;