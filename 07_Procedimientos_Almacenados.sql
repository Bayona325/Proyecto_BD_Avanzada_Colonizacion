-- 1. Registrar un nuevo cliente
DELIMITER //
CREATE PROCEDURE sp_RegistrarNuevoCliente(
    IN p_nombre VARCHAR(50),
    IN p_apellido VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_contrasena VARCHAR(255),
    IN p_direccion VARCHAR(255)
)
BEGIN
    IF p_email NOT LIKE '%_@_%._%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Correo electrónico inválido.';
    END IF;

    INSERT INTO Clientes (nombre, apellido, email, contraseña, direccion_envio)
    VALUES (p_nombre, p_apellido, p_email, p_contrasena, p_direccion);
END //
DELIMITER ;

-- 2. Agregar nuevo producto
DELIMITER //
CREATE PROCEDURE sp_AgregarNuevoProducto(
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_costo DECIMAL(10,2),
    IN p_stock INT,
    IN p_sku VARCHAR(50),
    IN p_categoria INT,
    IN p_proveedor INT
)
BEGIN
    IF p_precio <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio debe ser mayor que 0.';
    END IF;

    INSERT INTO Productos (nombre, descripcion, precio, costo, stock, sku, id_categoria, id_proveedor)
    VALUES (p_nombre, p_descripcion, p_precio, p_costo, p_stock, p_sku, p_categoria, p_proveedor);
END //
DELIMITER ;

-- 3. Actualizar dirección de cliente
DELIMITER //
CREATE PROCEDURE sp_ActualizarDireccionCliente(
    IN p_id INT,
    IN p_direccion VARCHAR(255)
)
BEGIN
    UPDATE Clientes
    SET direccion_envio = p_direccion
    WHERE id_cliente = p_id;
END //
DELIMITER ;

-- 4. Obtener historial de compras de un cliente
DELIMITER //
CREATE PROCEDURE sp_HistorialComprasCliente(IN p_id_cliente INT)
BEGIN
    SELECT v.id_venta, v.fecha_venta, v.total, v.estado,
        d.id_producto, p.nombre AS producto, d.cantidad, d.precio_unitario_congelado
    FROM Ventas v
    JOIN Detalle_Ventas d ON v.id_venta = d.id_venta
    JOIN Productos p ON d.id_producto = p.id_producto
    WHERE v.id_cliente = p_id_cliente
    ORDER BY v.fecha_venta DESC;
END //
DELIMITER ;

-- 5. Cambiar estado de pedido
DELIMITER //
CREATE PROCEDURE sp_CambiarEstadoPedido(IN p_id_venta INT, IN p_estado VARCHAR(50))
BEGIN
    UPDATE Ventas SET estado = p_estado WHERE id_venta = p_id_venta;
END //
DELIMITER ;

-- 6. Calcular total de venta
DELIMITER //
CREATE PROCEDURE sp_CalcularTotalVenta(IN p_id_venta INT)
BEGIN
    UPDATE Ventas
    SET total = (
       SELECT SUM(cantidad * precio_unitario_congelado)
        FROM Detalle_Ventas
        WHERE id_venta = p_id_venta
    )
    WHERE id_venta = p_id_venta;
END //
DELIMITER ;

-- 7. Ajustar nivel de stock manualmente
DELIMITER //
CREATE PROCEDURE sp_AjustarStock(
    IN p_id_producto INT,
    IN p_nuevo_stock INT
)
BEGIN
    IF p_nuevo_stock < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El stock no puede ser negativo.';
    END IF;
    UPDATE Productos SET stock = p_nuevo_stock WHERE id_producto = p_id_producto;
END //
DELIMITER ;

-- 8. Procesar devolución de producto
DELIMITER //
CREATE PROCEDURE sp_ProcesarDevolucion(
    IN p_id_venta INT,
    IN p_id_producto INT,
    IN p_cantidad INT
)
BEGIN
    UPDATE Productos SET stock = stock + p_cantidad WHERE id_producto = p_id_producto;
    UPDATE Ventas SET total = total - (p_cantidad *
    (SELECT precio_unitario_congelado FROM Detalle_Ventas
        WHERE id_venta=p_id_venta AND id_producto=p_id_producto))
    WHERE id_venta = p_id_venta;
END //
DELIMITER ;

-- 9. Aplicar descuento a categoría
DELIMITER //
CREATE PROCEDURE sp_AplicarDescuentoCategoria(
    IN p_id_categoria INT,
    IN p_descuento DECIMAL(5,2)
)
BEGIN
    UPDATE Productos
    SET precio = precio - (precio * (p_descuento / 100))
    WHERE id_categoria = p_id_categoria;
END //
DELIMITER ;

-- 10. Generar reporte mensual de ventas
DELIMITER //
CREATE PROCEDURE sp_ReporteMensualVentas(IN p_mes INT, IN p_anio INT)
BEGIN
    SELECT v.id_venta, c.nombre AS cliente, v.total, v.estado, v.fecha_venta
    FROM Ventas v
    JOIN Clientes c ON v.id_cliente = c.id_cliente
    WHERE MONTH(v.fecha_venta)=p_mes AND YEAR(v.fecha_venta)=p_anio;
END //
DELIMITER ;

-- 11. Obtener productos más vendidos
DELIMITER //
CREATE PROCEDURE sp_TopProductosMasVendidos()
BEGIN
    SELECT p.nombre, SUM(d.cantidad) AS total_vendido
    FROM Detalle_Ventas d
    JOIN Productos p ON d.id_producto = p.id_producto
    GROUP BY p.id_producto
    ORDER BY total_vendido DESC
    LIMIT 10;
END //
DELIMITER ;

-- 12. Registrar nueva venta
DELIMITER //
CREATE PROCEDURE sp_RegistrarVenta(
    IN p_id_cliente INT,
    IN p_total DECIMAL(10,2),
    OUT p_id_venta INT
)
BEGIN
    INSERT INTO Ventas (id_cliente, total) VALUES (p_id_cliente, p_total);
    SET p_id_venta = LAST_INSERT_ID();
END //
DELIMITER ;

-- 13. Añadir detalle de venta
DELIMITER //
CREATE PROCEDURE sp_AgregarDetalleVenta(
    IN p_id_venta INT,
    IN p_id_producto INT,
    IN p_cantidad INT,
    IN p_precio DECIMAL(10,2)
)
BEGIN
    INSERT INTO Detalle_Ventas (id_venta, id_producto, cantidad, precio_unitario_congelado)
    VALUES (p_id_venta, p_id_producto, p_cantidad, p_precio);
END //
DELIMITER ;

-- 14. Fusionar cuentas duplicadas
DELIMITER //
CREATE PROCEDURE sp_FusionarClientes(IN p_id_origen INT, IN p_id_destino INT)
BEGIN
    UPDATE Ventas SET id_cliente = p_id_destino WHERE id_cliente = p_id_origen;
    DELETE FROM Clientes WHERE id_cliente = p_id_origen;
END //
DELIMITER ;

-- 15. Buscar productos por filtros
DELIMITER //
CREATE PROCEDURE sp_BuscarProductos(
    IN p_nombre VARCHAR(100),
    IN p_min DECIMAL(10,2),
    IN p_max DECIMAL(10,2)
)
BEGIN
  SELECT * FROM Productos
    WHERE nombre LIKE CONCAT('%', p_nombre, '%')
    AND precio BETWEEN p_min AND p_max;
END //
DELIMITER ;

-- 16. Obtener clientes VIP
DELIMITER //
CREATE PROCEDURE sp_ClientesVIP()
BEGIN
    SELECT nombre, apellido, total_gastado
    FROM Clientes
    ORDER BY total_gastado DESC
    LIMIT 5;
END //
DELIMITER ;

-- 17. Generar resumen de ventas por categoría
DELIMITER //
CREATE PROCEDURE sp_ResumenVentasCategoria()
BEGIN
    SELECT c.nombre AS categoria, SUM(d.cantidad * d.precio_unitario_congelado) AS total_ventas
    FROM Detalle_Ventas d
    JOIN Productos p ON d.id_producto = p.id_producto
    JOIN Categorias c ON p.id_categoria = c.id_categoria
    GROUP BY c.id_categoria;
END //
DELIMITER ;

-- 18. Calcular margen promedio
DELIMITER //
CREATE PROCEDURE sp_MargenPromedio()
BEGIN
    SELECT AVG(precio - costo) AS margen_promedio FROM Productos;
END //
DELIMITER ;

-- 19. Productos por debajo del stock mínimo
DELIMITER //
CREATE PROCEDURE sp_ProductosBajoStock()
BEGIN
    SELECT id_producto, nombre, stock FROM Productos WHERE stock < 5;
END //
DELIMITER ;

-- 20. Actualizar estado de pedidos pendientes a procesando
DELIMITER //
CREATE PROCEDURE sp_ProcesarPedidosPendientes()
BEGIN
    UPDATE Ventas SET estado='PROCESANDO' WHERE estado='PENDIENTE_PAGO';
END //
DELIMITER ;