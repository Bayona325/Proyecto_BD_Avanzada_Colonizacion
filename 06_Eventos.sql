-- 1. Generar reporte semanal de ventas
CREATE EVENT evt_generate_weekly_sales_report
ON SCHEDULE EVERY 1 WEEK
DO
INSERT INTO Reporte_Semanal (fecha_reporte, total_ventas)
SELECT NOW(), SUM(total) FROM Ventas;

-- 2. Borrar logs antiguos
CREATE EVENT evt_cleanup_logs
ON SCHEDULE EVERY 1 DAY
DO
DELETE FROM Log_Cambios_Precio WHERE fecha_cambio < NOW() - INTERVAL 90 DAY;

-- 3. Archivar ventas canceladas
CREATE EVENT evt_archive_cancelled_sales
ON SCHEDULE EVERY 1 MONTH
DO
INSERT INTO Ventas_Archivadas SELECT * FROM Ventas WHERE estado='CANCELADO';

-- 4. Desactivar productos sin stock
CREATE EVENT evt_deactivate_outofstock
ON SCHEDULE EVERY 1 DAY
DO
UPDATE Productos SET activo=FALSE WHERE stock=0;

-- 5. Generar ranking mensual
CREATE EVENT evt_update_top_products
ON SCHEDULE EVERY 1 MONTH
DO
INSERT INTO Ranking_Productos (mes, id_producto, total_vendido)
SELECT MONTH(NOW()), id_producto, SUM(cantidad)
FROM Detalle_Ventas GROUP BY id_producto;

-- 6. Limpiar alertas viejas
CREATE EVENT evt_clear_old_alerts
ON SCHEDULE EVERY 1 WEEK
DO
DELETE FROM Alertas_Stock WHERE fecha_alerta < NOW() - INTERVAL 30 DAY;

-- 7. Actualizar total gastado por cliente
CREATE EVENT evt_refresh_client_spend
ON SCHEDULE EVERY 1 WEEK
DO
UPDATE Clientes SET total_gastado = (
    SELECT SUM(total) FROM Ventas WHERE Ventas.id_cliente = Clientes.id_cliente
);

-- 8. Recalcular stock general
CREATE EVENT evt_recalculate_stock
ON SCHEDULE EVERY 1 DAY
DO
UPDATE Productos p
SET p.stock = p.stock;

-- 9. Limpieza de ventas antiguas
CREATE EVENT evt_purge_old_sales
ON SCHEDULE EVERY 6 MONTH
DO
DELETE FROM Ventas WHERE fecha_venta < NOW() - INTERVAL 2 YEAR;

-- 10. Crear backup lógico de productos
CREATE EVENT evt_backup_products
ON SCHEDULE EVERY 1 WEEK
DO
CREATE TABLE Productos_Backup AS SELECT * FROM Productos;

-- 11. Recalcular total ventas diario
CREATE EVENT evt_daily_sales_summary
ON SCHEDULE EVERY 1 DAY
DO
INSERT INTO Reporte_Semanal (fecha_reporte, total_ventas)
SELECT NOW(), SUM(total) FROM Ventas WHERE fecha_venta >= NOW() - INTERVAL 1 DAY;

-- 12. Desactivar clientes inactivos
CREATE EVENT evt_deactivate_inactive_clients
ON SCHEDULE EVERY 3 MONTH
DO
UPDATE Clientes SET total_gastado=total_gastado WHERE fecha_ultima_compra < NOW() - INTERVAL 1 YEAR;

-- 13. Eliminar productos inactivos hace más de 1 año
CREATE EVENT evt_purge_inactive_products
ON SCHEDULE EVERY 1 MONTH
DO
DELETE FROM Productos WHERE activo=FALSE AND fecha_creacion < NOW() - INTERVAL 1 YEAR;

-- 14. Crear alertas por ventas lentas
CREATE EVENT evt_alert_low_sales
ON SCHEDULE EVERY 1 MONTH
DO
INSERT INTO Alertas_Stock (id_producto, stock_actual)
SELECT id_producto, stock FROM Productos WHERE stock > 0 AND id_producto NOT IN (
    SELECT DISTINCT id_producto FROM Detalle_Ventas WHERE fecha_compra >= NOW() - INTERVAL 6 MONTH
);

-- 15. Generar reporte de proveedores
CREATE EVENT evt_supplier_report
ON SCHEDULE EVERY 1 MONTH
DO
INSERT INTO Reporte_Proveedores (fecha_reporte, id_proveedor, total_ventas)
SELECT NOW(), p.id_proveedor, SUM(v.total)
FROM Ventas v
JOIN Detalle_Ventas d ON v.id_venta = d.id_venta
JOIN Productos p ON d.id_producto = p.id_producto
GROUP BY p.id_proveedor;

-- 16. Actualizar ranking diario de productos
CREATE EVENT evt_daily_product_ranking
ON SCHEDULE EVERY 1 DAY
DO
UPDATE Productos SET activo=activo;

-- 17. Monitorear tamaño de base de datos
CREATE EVENT evt_log_db_size
ON SCHEDULE EVERY 1 WEEK
DO
INSERT INTO Reporte_DB (fecha, tamaño_mb)
SELECT NOW(), SUM(data_length + index_length)/1024/1024
FROM information_schema.tables WHERE table_schema=DATABASE();

-- 18. Borrar reportes antiguos
CREATE EVENT evt_purge_old_reports
ON SCHEDULE EVERY 3 MONTH
DO
DELETE FROM Reporte_Semanal WHERE fecha_reporte < NOW() - INTERVAL 1 YEAR;

-- 19. Actualizar total de productos por categoría
CREATE EVENT evt_refresh_category_counts
ON SCHEDULE EVERY 1 DAY
DO
UPDATE Categorias c
SET total_productos = (SELECT COUNT(*) FROM Productos p WHERE p.id_categoria = c.id_categoria);

-- 20. Detectar ventas sin detalle
CREATE EVENT evt_detect_empty_sales
ON SCHEDULE EVERY 1 DAY
DO
INSERT INTO Log_Cambio_Estado (id_venta, estado_anterior, estado_nuevo)
SELECT v.id_venta, 'Sin Detalle', v.estado
FROM Ventas v
WHERE v.id_venta NOT IN (SELECT id_venta FROM Detalle_Ventas);