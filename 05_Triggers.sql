-- Tabla de auditoría de cambios de precio
CREATE TABLE IF NOT EXISTS Log_Cambios_Precio (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    precio_anterior DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100)
);

-- 1. Auditoría de cambio de precios
CREATE TRIGGER trg_audit_precio_producto
AFTER UPDATE ON Productos
FOR EACH ROW
BEGIN
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO Log_Cambios_Precio (id_producto, precio_anterior, precio_nuevo, usuario)
        VALUES (NEW.id_producto, OLD.precio, NEW.precio, CURRENT_USER());
    END IF;
END;

-- 2. Verificar stock antes de venta
CREATE TRIGGER trg_check_stock_before_venta
BEFORE INSERT ON Detalle_Ventas
FOR EACH ROW
BEGIN
    DECLARE stock_actual INT;
    SELECT stock INTO stock_actual FROM Productos WHERE id_producto = NEW.id_producto;
    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para el producto.';
    END IF;
END;

-- 3. Descontar stock tras venta
CREATE TRIGGER trg_update_stock_after_venta
AFTER INSERT ON Detalle_Ventas
FOR EACH ROW
BEGIN
    UPDATE Productos
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END;

-- 4. Impedir eliminar categoría con productos
CREATE TRIGGER trg_prevent_delete_categoria
BEFORE DELETE ON Categorias
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Productos WHERE id_categoria = OLD.id_categoria) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar una categoría con productos asociados.';
    END IF;
END;

-- 5. Registrar nuevo cliente
CREATE TABLE IF NOT EXISTS Log_Nuevos_Clientes (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    nombre_completo VARCHAR(100),
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_log_new_cliente
AFTER INSERT ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Log_Nuevos_Clientes (id_cliente, nombre_completo)
    VALUES (NEW.id_cliente, CONCAT(NEW.nombre, ' ', NEW.apellido));
END;

-- 6. Actualizar total gastado por cliente
ALTER TABLE Clientes ADD COLUMN total_gastado DECIMAL(10,2) DEFAULT 0;

CREATE TRIGGER trg_update_total_gastado
AFTER INSERT ON Ventas
FOR EACH ROW
BEGIN
    UPDATE Clientes
    SET total_gastado = IFNULL(total_gastado,0) + NEW.total
    WHERE id_cliente = NEW.id_cliente;
END;

-- 7. Evitar stock negativo
CREATE TRIGGER trg_prevent_negative_stock
BEFORE UPDATE ON Productos
FOR EACH ROW
BEGIN
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El stock no puede ser negativo.';
    END IF;
END;

-- 8. Validar precio mayor a cero
CREATE TRIGGER trg_prevent_price_zero
BEFORE INSERT ON Productos
FOR EACH ROW
BEGIN
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio debe ser mayor que cero.';
    END IF;
END;

-- 9. Registrar cambio de estado de pedido
CREATE TABLE IF NOT EXISTS Log_Cambio_Estado (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT,
    estado_anterior VARCHAR(50),
    estado_nuevo VARCHAR(50),
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_log_estado_venta
AFTER UPDATE ON Ventas
FOR EACH ROW
BEGIN
    IF OLD.estado <> NEW.estado THEN
        INSERT INTO Log_Cambio_Estado (id_venta, estado_anterior, estado_nuevo)
        VALUES (NEW.id_venta, OLD.estado, NEW.estado);
    END IF;
END;

-- 10. Actualizar total en ventas tras cambio en detalle
CREATE TRIGGER trg_recalculate_total_venta
AFTER INSERT ON Detalle_Ventas
FOR EACH ROW
BEGIN
    UPDATE Ventas
    SET total = (
       SELECT SUM(cantidad * precio_unitario_congelado)
        FROM Detalle_Ventas
        WHERE id_venta = NEW.id_venta
    )
    WHERE id_venta = NEW.id_venta;
END;

-- 11. Capitalizar nombre de cliente
CREATE TRIGGER trg_capitalize_cliente
BEFORE INSERT ON Clientes
FOR EACH ROW
BEGIN
    SET NEW.nombre = CONCAT(UPPER(LEFT(NEW.nombre,1)), LOWER(SUBSTRING(NEW.nombre,2)));
    SET NEW.apellido = CONCAT(UPPER(LEFT(NEW.apellido,1)), LOWER(SUBSTRING(NEW.apellido,2)));
END;

-- 12. Registrar bajas existencias
CREATE TABLE IF NOT EXISTS Alertas_Stock (
    id_alerta INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    stock_actual INT,
    fecha_alerta DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_alerta_bajo_stock
AFTER UPDATE ON Productos
FOR EACH ROW
BEGIN
    IF NEW.stock < 5 THEN
        INSERT INTO Alertas_Stock (id_producto, stock_actual)
        VALUES (NEW.id_producto, NEW.stock);
    END IF;
END;

-- 13. Evitar eliminar proveedor con productos
CREATE TRIGGER trg_prevent_delete_proveedor
BEFORE DELETE ON Proveedores
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Productos WHERE id_proveedor = OLD.id_proveedor) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar proveedor con productos asociados.';
    END IF;
END;

-- 14. Validar formato de email cliente
CREATE TRIGGER trg_validate_email_cliente
BEFORE INSERT ON Clientes
FOR EACH ROW
BEGIN
    IF NEW.email NOT LIKE '%_@_%._%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Formato de correo electrónico inválido.';
    END IF;
END;

-- 15. Registrar ventas eliminadas
CREATE TABLE IF NOT EXISTS Ventas_Archivadas LIKE Ventas;

CREATE TRIGGER trg_archive_venta
BEFORE DELETE ON Ventas
FOR EACH ROW
BEGIN
  INSERT INTO Ventas_Archivadas SELECT * FROM Ventas WHERE id_venta = OLD.id_venta;
END;

-- 16. Registrar fecha última compra
ALTER TABLE Clientes ADD COLUMN fecha_ultima_compra DATETIME NULL;

CREATE TRIGGER trg_update_fecha_ultima_compra
AFTER INSERT ON Ventas
FOR EACH ROW
BEGIN
    UPDATE Clientes
    SET fecha_ultima_compra = NOW()
    WHERE id_cliente = NEW.id_cliente;
END;

-- 17. Actualizar contador de productos en categoría
ALTER TABLE Categorias ADD COLUMN total_productos INT DEFAULT 0;

CREATE TRIGGER trg_update_producto_count
AFTER INSERT ON Productos
FOR EACH ROW
BEGIN
    UPDATE Categorias
    SET total_productos = total_productos + 1
    WHERE id_categoria = NEW.id_categoria;
END;

-- 18. Asignar categoría “General” si es NULL
CREATE TRIGGER trg_default_categoria
BEFORE INSERT ON Productos
FOR EACH ROW
BEGIN
    IF NEW.id_categoria IS NULL THEN
        SET NEW.id_categoria = (SELECT id_categoria FROM Categorias WHERE nombre='Electrónica' LIMIT 1);
    END IF;
END;

-- 19. Evitar precio menor al costo
CREATE TRIGGER trg_prevent_loss_price
BEFORE UPDATE ON Productos
FOR EACH ROW
BEGIN
    IF NEW.precio < NEW.costo THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio no puede ser menor al costo.';
    END IF;
END;

-- 20. Registrar producto inactivo
CREATE TABLE IF NOT EXISTS Log_Productos_Inactivos (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    nombre VARCHAR(100),
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_log_inactive_product
AFTER UPDATE ON Productos
FOR EACH ROW
BEGIN
    IF NEW.activo = FALSE AND OLD.activo = TRUE THEN
        INSERT INTO Log_Productos_Inactivos (id_producto, nombre)
        VALUES (NEW.id_producto, NEW.nombre);
    END IF;
END;