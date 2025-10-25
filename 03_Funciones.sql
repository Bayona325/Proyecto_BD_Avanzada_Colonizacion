-- fn_CalcularTotalVenta
CREATE FUNCTION fn_CalcularTotalVenta(p_id_venta INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE total DECIMAL(10,2);
  SELECT SUM(cantidad * precio_unitario)
  INTO total
  FROM DetalleVentas
  WHERE id_venta = p_id_venta;
  RETURN IFNULL(total, 0);
END;

-- fn_VerificarDisponibilidadStock
CREATE FUNCTION fn_VerificarDisponibilidadStock(p_id_producto INT, p_cantidad INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
  DECLARE disponible INT;
  SELECT stock INTO disponible FROM Productos WHERE id_producto = p_id_producto;
  RETURN disponible >= p_cantidad;
END;

-- fn_ObtenerPrecioProducto
CREATE FUNCTION fn_ObtenerPrecioProducto(p_id_producto INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE precio DECIMAL(10,2);
  SELECT precio INTO precio FROM Productos WHERE id_producto = p_id_producto;
  RETURN IFNULL(precio, 0);
END;

-- fn_CalcularEdadCliente
CREATE FUNCTION fn_CalcularEdadCliente(p_fecha_nacimiento DATE)
RETURNS INT
DETERMINISTIC
BEGIN
  RETURN TIMESTAMPDIFF(YEAR, p_fecha_nacimiento, CURDATE());
END;

-- fn_FormatearNombreCompleto
CREATE FUNCTION fn_FormatearNombreCompleto(p_nombre VARCHAR(50), p_apellido VARCHAR(50))
RETURNS VARCHAR(120)
DETERMINISTIC
BEGIN
  RETURN CONCAT(UCASE(LEFT(p_nombre,1)), LCASE(SUBSTRING(p_nombre,2)), ' ',
                UCASE(LEFT(p_apellido,1)), LCASE(SUBSTRING(p_apellido,2)));
END;

-- fn_EsClienteNuevo
CREATE FUNCTION fn_EsClienteNuevo(p_id_cliente INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
  DECLARE primera DATE;
  SELECT MIN(fecha_venta) INTO primera FROM Ventas WHERE id_cliente = p_id_cliente;
  RETURN primera >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
END;

-- fn_CalcularCostoEnvio
CREATE FUNCTION fn_CalcularCostoEnvio(p_id_venta INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE peso_total DECIMAL(10,2);
  SELECT SUM(p.peso * dv.cantidad)
  INTO peso_total
  FROM DetalleVentas dv
  JOIN Productos p ON dv.id_producto = p.id_producto
  WHERE dv.id_venta = p_id_venta;
  RETURN peso_total * 0.5; -- Ejemplo: $0.5 por kg
END;

-- fn_AplicarDescuento
CREATE FUNCTION fn_AplicarDescuento(p_monto DECIMAL(10,2), p_descuento DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  RETURN p_monto - (p_monto * p_descuento / 100);
END;

-- fn_ObtenerUltimaFechaCompra
CREATE FUNCTION fn_ObtenerUltimaFechaCompra(p_id_cliente INT)
RETURNS DATE
DETERMINISTIC
BEGIN
  DECLARE ultima DATE;
  SELECT MAX(fecha_venta) INTO ultima FROM Ventas WHERE id_cliente = p_id_cliente;
  RETURN ultima;
END;

-- fn_ValidarFormatoEmail
CREATE FUNCTION fn_ValidarFormatoEmail(p_email VARCHAR(255))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
  RETURN p_email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$';
END;

-- fn_ObtenerNombreCategoria
CREATE FUNCTION fn_ObtenerNombreCategoria(p_id_producto INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
  DECLARE nombre_cat VARCHAR(100);
  SELECT c.nombre INTO nombre_cat
  FROM Productos p
  JOIN Categorias c ON p.id_categoria = c.id_categoria
  WHERE p.id_producto = p_id_producto;
  RETURN nombre_cat;
END;

-- fn_ContarVentasCliente
CREATE FUNCTION fn_ContarVentasCliente(p_id_cliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM Ventas WHERE id_cliente = p_id_cliente;
  RETURN total;
END;

-- fn_CalcularDiasDesdeUltimaCompra
CREATE FUNCTION fn_CalcularDiasDesdeUltimaCompra(p_id_cliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE ultima DATE;
  SELECT MAX(fecha_venta) INTO ultima FROM Ventas WHERE id_cliente = p_id_cliente;
  RETURN DATEDIFF(CURDATE(), ultima);
END;

-- fn_DeterminarEstadoLealtad
CREATE FUNCTION fn_DeterminarEstadoLealtad(p_id_cliente INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
  DECLARE gasto DECIMAL(10,2);
  SELECT SUM(total) INTO gasto FROM Ventas WHERE id_cliente = p_id_cliente;
  RETURN CASE
    WHEN gasto >= 5000 THEN 'Oro'
    WHEN gasto >= 2000 THEN 'Plata'
    ELSE 'Bronce'
  END;
END;

-- fn_CalcularIVA
CREATE FUNCTION fn_CalcularIVA(p_total DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  RETURN p_total * 0.19;
END;

-- fn_ObtenerStockTotalPorCategoria
CREATE FUNCTION fn_ObtenerStockTotalPorCategoria(p_id_categoria INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE total INT;
  SELECT SUM(stock) INTO total FROM Productos WHERE id_categoria = p_id_categoria;
  RETURN IFNULL(total, 0);
END;

-- fn_EstimarFechaEntrega
CREATE FUNCTION fn_EstimarFechaEntrega(p_ubicacion VARCHAR(50))
RETURNS DATE
DETERMINISTIC
BEGIN
  RETURN CASE
    WHEN p_ubicacion = 'Local' THEN DATE_ADD(CURDATE(), INTERVAL 2 DAY)
    WHEN p_ubicacion = 'Regional' THEN DATE_ADD(CURDATE(), INTERVAL 5 DAY)
    ELSE DATE_ADD(CURDATE(), INTERVAL 10 DAY)
  END;
END;

-- fn_ConvertirMoneda
CREATE FUNCTION fn_ConvertirMoneda(p_monto DECIMAL(10,2), p_tasa DECIMAL(10,4))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  RETURN p_monto * p_tasa;
END;

-- fn_ValidarComplejidadContraseña
CREATE FUNCTION fn_ValidarComplejidadContraseña(p_pass VARCHAR(255))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
  RETURN (LENGTH(p_pass) >= 8)
     AND (p_pass REGEXP '[A-Z]')
     AND (p_pass REGEXP '[a-z]')
     AND (p_pass REGEXP '[0-9]')
     AND (p_pass REGEXP '[!@#$%^&*()]');
END;
