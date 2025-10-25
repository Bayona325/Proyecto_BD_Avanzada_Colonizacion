-- 1.Top 10 Productos Más Vendidos: Generar un ranking con los 10 productos que han generado más ingresos.
SELECT 
p.id_producto p.nombre_producto AS Producto,
    SUM(dv.cantidad * dv.precio_unitario) AS Total_Ingresos
FROM detalle_ventas dv
JOIN productos p ON dv.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre_producto
ORDER BY Total_Ingresos DESC
LIMIT 10;

-- 2.productos con bajas Ventas  identificar los productos  en el 10% interir de Ventas 
SELECT 
    p.id_producto,
    p.nombre_producto,
    c.nombre AS categoria,
    SUM(dv.cantidad) AS total_vendido
FROM 
    Productos p
JOIN 
    Categorias c ON p.id_categoria = c.id_categoria
JOIN 
    DetalleVentas dv ON p.id_producto = dv.id_producto
JOIN 
    Ventas v ON dv.id_venta = v.id_venta
WHERE 
    v.estado = 'ENTREGADO'
GROUP BY 
    p.id_producto, p.nombre_producto, c.nombre
HAVING 
COUNT(p.id_producto) > 1 AND SUM(dv.cantidad) < (
        SELECT 
            SUM(dv2.cantidad) * 0.1
        FROM 
            DetalleVentas dv2
        JOIN 
            Ventas v2 ON dv2.id_venta = v2.id_venta
        WHERE 
            v2.estado = 'ENTREGADO'
        GROUP BY 
            dv2.id_producto
);
 SELECT 
    p.id_producto,
    p.nombre_producto,
    c.nombre AS categoria,
    SUM(dv.cantidad) AS total_vendido


            

    total_vendido ASC;

-- 3.clientes BLP listar los 5 clientes con el mayor valorr de vida (LTV), basando en su gasto total historrico.
SELECT 
    c.id_cliente,
    c.nombre,
    SUM(v.total) AS valor_vida_cliente
FROM 
    Clientes c
JOIN 
    Ventas v ON c.id_cliente = v.id_cliente
GROUP BY 
    c.id_cliente, c.nombre
ORDER BY 
    valor_vida_cliente DESC
LIMIT 5;
FROM 
    Productos p
JOIN 
    DetalleVentas dv ON p.id_producto = dv.id_producto
JOIN 
    Ventas v ON dv.id_venta = v.id_venta
WHERE 
    v.estado = 'ENTREGADO'
GROUP BY 
    p.id_producto, p.nombre_producto
ORDER BY 
    total_vendido ASC;

-- 4. ANALISIS DE VENTAS Mensuales : mostrar las ventas totales agrupadas por mes y año
SELECT 
    YEAR(fecha) AS anio,
    MONTH(fecha) AS mes,
    SUM(total) AS ventas_totales
FROM 
    Ventas
GROUP BY 
    YEAR(fecha), MONTH(fecha)
ORDER BY 
    YEAR(fecha), MONTH(fecha);

--- 5.Crecimiento de Clientes: Calcular el número de nuevos clientes registrados por trimestre.

SELECT 
    YEAR(fecha_registro) AS anio,
    QUARTER(fecha_registro) AS trimestre,
    COUNT(id_cliente) AS nuevos_clientes
FROM 
    Clientes
GROUP BY 
    YEAR(fecha_registro), QUARTER(fecha_registro)
ORDER BY 
    YEAR(fecha_registro), QUARTER(fecha_registro);

-- 6. tasa de compras repetida: determinar que porcentaje de clientes ha realizado mas de una crompra.SELECT 
    ROUND(
        (COUNT(DISTINCT CASE WHEN compras_por_cliente > 1 THEN id_cliente END) 
        / COUNT(DISTINCT id_cliente)) * 100, 2
    ) AS tasa_compra_repetida
FROM (
    SELECT 
        id_cliente,
        COUNT(*) AS compras_por_cliente
    FROM 
        Ventas
    GROUP BY 
        id_cliente
) AS subconsulta;

-- 7. productos comprados juntos: identificar los pares de productos que a menudo se compran en la misma transacción.
SELECT 
    dv1.id_producto AS producto_a,
    dv2.id_producto AS producto_b,
    COUNT(*) AS veces_comprados_juntos

FROM 
    DetalleVenta dv1
JOIN 
    DetalleVenta dv2 
    ON dv1.id_venta = dv2.id_venta 
    AND dv1.id_producto < dv2.id_producto   -- evita duplicados e inversos (A-B y B-A)
GROUP BY 
    dv1.id_producto, dv2.id_producto
ORDER BY 
    veces_comprados_juntos DESC
LIMIT 10;

-- 8. rotación de inventario: calcular la rotación de stock para cada categoría de producto.
SELECT 
    c.id_categoria,
    c.nombre AS categoria,
    SUM(dv.cantidad) AS total_unidades_vendidas,
    SUM(p.stock) AS stock_actual_total,
    ROUND(SUM(dv.cantidad) / NULLIF(SUM(p.stock), 0), 2) AS tasa_rotacion
FROM 
    Categorias c
JOIN 
    Productos p ON c.id_categoria = p.id_categoria
JOIN 
    DetalleVenta dv ON p.id_producto = dv.id_producto
GROUP BY 
    c.id_categoria, c.nombre
ORDER BY 
    tasa_rotacion DESC;


-- 9. productos que nesecitan reabastecimiento: listar los productos cuyo stock actual esta por debajo de su umbral minimo.
SELECT 
    id_producto,
    nombre,
    stock_actual,
    stock_minimo,
    (stock_minimo - stock_actual) AS cantidad_a_reponer
FROM 
    Productos
WHERE 
    stock_actual < stock_minimo
ORDER BY 
    (stock_minimo - stock_actual) DESC;

-- 10. analisis de carro abandonado (simulado): identificar clientes que agregaron productos pero no comepletaron una venta en un periodo determinado.
SELECT 
    c.id_cliente,
    c.nombre,
    COUNT(ca.id_producto) AS productos_en_carro,
    MAX(ca.fecha_agregado) AS ultima_actividad
FROM 
    Clientes c
JOIN 
    Carrito ca ON c.id_cliente = ca.id_cliente
WHERE 
    ca.fecha_agregado > NOW() - INTERVAL '30 days'
GROUP BY 
    c.id_cliente, c.nombre
HAVING 
    COUNT(ca.id_producto) > 0;

-- 11. rendimientos de proveedores: evaluar el rendimiento de los proveedores segun el volumen de ventas de sus productos.
SELECT 
    pr.id_proveedor,
    pr.nombre AS proveedor,
    SUM(dv.cantidad) AS total_unidades_vendidas,
    SUM(dv.cantidad * dv.precio_unitario) AS total_ventas,
    ROUND(AVG(dv.precio_unitario), 2) AS precio_promedio
FROM 
    Proveedores pr
JOIN 
    Productos p ON pr.id_proveedor = p.id_proveedor
JOIN 
    DetalleVenta dv ON p.id_producto = dv.id_producto
GROUP BY 
    pr.id_proveedor, pr.nombre
ORDER BY 
    total_ventas DESC;

--12.analisis geografico de ventas: Agrupar las ventas por region o ciudad del clientes.
SELECT 
    c.region,
    c.ciudad,
    SUM(v.total) AS ventas_totales,
    COUNT(v.id_venta) AS numero_de_ventas
FROM 
    Clientes c
JOIN 
    Ventas v ON c.id_cliente = v.id_cliente
GROUP BY 
    c.region, c.ciudad
ORDER BY 
    ventas_totales DESC;

-- 13. Ventas por Hora del Día: Determinar las horas pico de compras para optimizar campañas de marketing.
SELECT 
    HOUR(fecha_venta) AS hora_del_dia,
    COUNT(*) AS cantidad_ventas,
    SUM(total) AS total_vendido
FROM Ventas
GROUP BY HOUR(fecha_venta)
ORDER BY cantidad_ventas DESC;

-- 14. Impacto de Promociones: Comparar las ventas de un producto antes, durante y después de una campaña de descuento.
SELECT
    p.id_producto,
    p.descripcion,
    
    -- Ventas antes de la promoción (7 días antes)
    (SELECT SUM(v.cantidad)
     FROM Ventas v
     WHERE v.id_producto = p.id_producto
       AND v.fecha_venta BETWEEN DATE_SUB(p.fecha_inicio, INTERVAL 7 DAY) AND p.fecha_inicio - INTERVAL 1 DAY
    ) AS ventas_antes,

    -- Ventas durante la promoción
    (SELECT SUM(v.cantidad)
     FROM Ventas v
     WHERE v.id_producto = p.id_producto
       AND v.fecha_venta BETWEEN p.fecha_inicio AND p.fecha_fin
    ) AS ventas_durante,

    -- Ventas después de la promoción (7 días después)
    (SELECT SUM(v.cantidad)
     FROM Ventas v
     WHERE v.id_producto = p.id_producto
       AND v.fecha_venta BETWEEN p.fecha_fin + INTERVAL 1 DAY AND DATE_ADD(p.fecha_fin, INTERVAL 7 DAY)
    ) AS ventas_despues

FROM Promociones p;

-- 15.Análisis de Cohort: Analizar la retención de clientes mes a mes desde su primera compra.
WITH primera_compra AS (
    SELECT 
        id_cliente,
        MIN(DATE_FORMAT(fecha_venta, '%Y-%m')) AS mes_cohorte
    FROM Ventas
    GROUP BY id_cliente
),
cohortes AS (
    SELECT 
        v.id_cliente,
        DATE_FORMAT(v.fecha_venta, '%Y-%m') AS mes_venta,
        p.mes_cohorte
    FROM Ventas v
    JOIN primera_compra p ON v.id_cliente = p.id_cliente
),
conteo AS (
    SELECT 
        mes_cohorte,
        mes_venta,
        COUNT(DISTINCT id_cliente) AS clientes_activos
    FROM cohortes
    GROUP BY mes_cohorte, mes_venta
)
SELECT 
    c1.mes_cohorte,
    c1.mes_venta,
    c1.clientes_activos,
    ROUND(c1.clientes_activos / c2.inicial * 100, 2) AS tasa_retencion
FROM conteo c1
JOIN (
    SELECT 
        mes_cohorte, 
        MAX(clientes_activos) AS inicial
    FROM conteo
    WHERE mes_cohorte = mes_venta
    GROUP BY mes_cohorte
) c2 ON c1.mes_cohorte = c2.mes_cohorte
ORDER BY c1.mes_cohorte, c1.mes_venta;


-- 16.Margen de Beneficio por Producto: Calcular el margen de beneficio para cada producto (requiere añadir un campo costo a la tabla productos).
SELECT 
    p.id_producto,
    p.nombre,
    SUM(v.cantidad) AS unidades_vendidas,
    SUM(v.total) AS ingresos_totales,
    SUM(v.cantidad * p.costo) AS costo_total,
    (SUM(v.total) - SUM(v.cantidad * p.costo)) AS beneficio_total,
    ROUND(((SUM(v.total) - SUM(v.cantidad * p.costo)) / SUM(v.total)) * 100, 2) AS margen_beneficio_porcentaje
FROM Ventas v
JOIN Productos p ON v.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY margen_beneficio_porcentaje DESC;


-- 17.Tiempo Promedio Entre Compras: Calcular el tiempo medio que tarda un cliente en volver a comprar.
WITH diferencias AS (
    SELECT 
        id_cliente,
        fecha_venta,
        LAG(fecha_venta) OVER (PARTITION BY id_cliente ORDER BY fecha_venta) AS compra_anterior
    FROM Ventas
)
SELECT 
    id_cliente,
    ROUND(AVG(DATEDIFF(fecha_venta, compra_anterior)), 2) AS dias_promedio_entre_compras
FROM diferencias
WHERE compra_anterior IS NOT NULL
GROUP BY id_cliente
ORDER BY dias_promedio_entre_compras;

-- 18. Productos Más Vistos vs. Comprados: Comparar los productos más visitados con los más comprados
SELECT 
    p.id_producto,
    p.nombre,
    COUNT(DISTINCT v.id_visita) AS total_visitas,
    COALESCE(SUM(ve.cantidad), 0) AS total_compras
FROM Productos p
LEFT JOIN Visitas v ON p.id_producto = v.id_producto
LEFT JOIN Ventas ve ON p.id_producto = ve.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY total_visitas DESC, total_compras DESC;

--19. Segmentación de Clientes (RFM): Clasificar a los clientes en segmentos (Recencia, Frecuencia, Monetario)
WITH datos_rfm AS (
    SELECT 
        id_cliente,
        MAX(fecha_venta) AS ultima_compra,
        COUNT(id_venta) AS frecuencia,
        SUM(total) AS monetario
    FROM Ventas
    GROUP BY id_cliente
),
rfm_calculado AS (
    SELECT 
        id_cliente,
        DATEDIFF(CURDATE(), ultima_compra) AS recencia_dias,
        frecuencia,
        monetario
    FROM datos_rfm
)
SELECT
    id_cliente,
    recencia_dias,
    frecuencia,
    monetario,
    -- Asignación de puntajes 1-5 según rangos (más alto = mejor cliente)
    CASE 
        WHEN recencia_dias <= 7 THEN 5
        WHEN recencia_dias <= 30 THEN 4
        WHEN recencia_dias <= 90 THEN 3
        WHEN recencia_dias <= 180 THEN 2
        ELSE 1
    END AS R_score,
    CASE 
        WHEN frecuencia >= 20 THEN 5
        WHEN frecuencia >= 10 THEN 4
        WHEN frecuencia >= 5 THEN 3
        WHEN frecuencia >= 2 THEN 2
        ELSE 1
    END AS F_score,
    CASE 
        WHEN monetario >= 1000 THEN 5
        WHEN monetario >= 500 THEN 4
        WHEN monetario >= 200 THEN 3
        WHEN monetario >= 100 THEN 2
        ELSE 1
    END AS M_score
FROM rfm_calculado
ORDER BY R_score DESC, F_score DESC, M_score DESC;

-- 20. Predicción de Demanda Simple: Utilizar datos de ventas pasadas para proyectar las ventas del próximo mes para una categoría específica.
SELECT 
    c.nombre AS categoria,
    DATE_FORMAT(v.fecha_venta, '%Y-%m') AS mes,
    SUM(v.cantidad) AS total_vendido
FROM Ventas v
INNER JOIN Productos p ON v.id_producto = p.id_producto
INNER JOIN Categorias c ON p.id_categoria = c.id_categoria
WHERE c.nombre = 'Bebidas'  -- 👈 Cambia por la categoría que deseas analizar
GROUP BY c.nombre, DATE_FORMAT(v.fecha_venta, '%Y-%m')
ORDER BY mes;

-- Predicción de Demanda Simple por Categoría
SELECT 
    c.nombre AS categoria,
    ROUND(AVG(mensual.total_vendido), 2) AS promedio_ultimos_3_meses,
    ROUND(AVG(mensual.total_vendido), 2) AS proyeccion_proximo_mes
FROM (
    SELECT 
        p.id_categoria,
        DATE_FORMAT(v.fecha_venta, '%Y-%m') AS mes,
        SUM(v.cantidad) AS total_vendido
    FROM Ventas v
    INNER JOIN Productos p ON v.id_producto = p.id_producto
    GROUP BY p.id_categoria, DATE_FORMAT(v.fecha_venta, '%Y-%m')
    ORDER BY mes DESC
    LIMIT 3  -- 👈 Últimos 3 meses
) AS mensual
INNER JOIN Categorias c ON mensual.id_categoria = c.id_categoria
WHERE c.nombre = 'Bebidas'  -- Cambiar por la categoría deseada
GROUP BY c.nombre;
