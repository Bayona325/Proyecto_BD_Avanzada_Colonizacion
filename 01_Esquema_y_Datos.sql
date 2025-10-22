CREATE TABLE `Productos` (
  `id_producto` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `nombre` VARCHAR(50) NOT NULL,
  `descripcion` VARCHAR(100) NOT NULL,
  `precio` DECIMAL(10,2) NOT NULL DEFAULT 1 CHECK(precio > 0),
  `costo` DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK(costo >= 0),
  `stock` INT NOT NULL DEFAULT 1 CHECK(stock >= 0),
  `sku` INT NOT NULL KEEPING UNIQUE,
  `fecha_creacion` DATETIME NOT NULL,
  `activo` BOOLEAN NOT NULL
);

CREATE TABLE `Categorias` (
  `id_categoria` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `nombre` VARCHAR(50) NOT NULL,
  `descripcion` VARCHAR(100) NOT NULL
);

CREATE TABLE `Proveedores` (
  `id_proveedor` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `nombre` VARCHAR(50) NOT NULL,
  `email_contacto` VARCHAR(50) NOT NULL UNIQUE,
  `telefono_contacto` VARCHAR(50) NOT NULL
);

CREATE TABLE `Clientes` (
  `id_cliente` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `nombre` VARCHAR(50) NOT NULL,
  `apellido` VARCHAR(50) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `contraseña` VARCHAR(100) HASH NOT NULL,
  `direccion_envio` VARCHAR(100) NOT NULL,
  `fecha_registro` DATETIME NOT NULL
);

CREATE TABLE `Ventas` (
  `id_venta` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `fecha_venta` DATETIME NOT NULL,
  `estado` ENUM('Pendiente de Pago', 'Procesando', 'Enviado', 'Entregado', 'Cancelado') DEFAULT 'Pendiente de Pago',
  `total` DECIMAL(10,2) NOT NULL
);

CREATE TABLE `Detalle_Ventas` (
  `id_detalle` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `cantidad` INT NOT NULL DEFAULT 1 CHECK(cantidad > 0),
  `precio_unitario_congelado` DECIMAL(10,2) NOT NULL
);