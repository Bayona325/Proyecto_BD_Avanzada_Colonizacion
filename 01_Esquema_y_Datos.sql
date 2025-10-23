CREATE TABLE Categorias (
  id_categoria INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  descripcion VARCHAR(255) NOT NULL
);

CREATE TABLE Proveedores (
  id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  email_contacto VARCHAR(100) UNIQUE,
  telefono_contacto VARCHAR(20)
);

CREATE TABLE Productos (
  id_producto INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT,
  precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
  costo DECIMAL(10,2) NOT NULL CHECK (costo >= 0),
  stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
  sku VARCHAR(50) NOT NULL UNIQUE,
  fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  activo BOOLEAN DEFAULT TRUE,
  id_categoria INT NOT NULL,
  id_proveedor INT NOT NULL,
  FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria),
  FOREIGN KEY (id_proveedor) REFERENCES Proveedores(id_proveedor)
);

CREATE TABLE Clientes (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  apellido VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  contraseña VARCHAR(255) NOT NULL,
  direccion_envio VARCHAR(255) NOT NULL,
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Ventas (
  id_venta INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  fecha_venta DATETIME DEFAULT CURRENT_TIMESTAMP,
  estado ENUM('PENDIENTE_PAGO','PROCESANDO','ENVIADO','ENTREGADO','CANCELADO') DEFAULT 'PENDIENTE_PAGO',
  total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
  FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

CREATE TABLE Detalle_Ventas (
  id_detalle INT AUTO_INCREMENT PRIMARY KEY,
  id_venta INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad INT NOT NULL CHECK (cantidad > 0),
  precio_unitario_congelado DECIMAL(10,2) NOT NULL CHECK (precio_unitario_congelado > 0),
  FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta),
  FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

INSERT INTO Categorias (nombre, descripcion)
VALUES
('Electrónica', 'Productos electrónicos y dispositivos tecnológicos.'),
('Ropa', 'Prendas de vestir para hombres y mujeres.'),
('Hogar', 'Artículos y accesorios para el hogar.'),
('Juguetes', 'Juguetes y juegos para niños de todas las edades.'),
('Deportes', 'Equipamiento y accesorios deportivos.');

INSERT INTO Proveedores (nombre, email_contacto, telefono_contacto)
VALUES
('TechWorld S.A.', 'contacto@techworld.com', '+34 600 123 456'),
('ModaPlus Ltd.', 'ventas@modaplus.com', '+34 601 654 321'),
('CasaBonita S.L.', 'info@casabonita.es', '+34 602 222 333'),
('PlayTime Co.', 'soporte@playtime.co', '+34 603 444 555'),
('SportZone España', 'ventas@sportzone.es', '+34 604 999 888');

INSERT INTO Productos (nombre, descripcion, precio, costo, stock, sku, id_categoria, id_proveedor)
VALUES
('Smartphone Galaxy X', 'Teléfono inteligente de última generación con 128GB de almacenamiento.', 699.99, 450.00, 30, 'ELEC-001', 1, 1),
('Camiseta Básica Blanca', 'Camiseta de algodón 100% unisex.', 14.99, 6.00, 100, 'ROP-001', 2, 2),
('Cafetera Automática', 'Cafetera programable con molinillo integrado.', 129.90, 80.00, 20, 'HOG-001', 3, 3),
('Muñeca Interactiva', 'Muñeca con voz y movimientos automáticos.', 49.99, 25.00, 50, 'JUY-001', 4, 4),
('Balón de Fútbol Pro', 'Balón oficial tamaño 5 de alta resistencia.', 34.95, 18.00, 40, 'DEP-001', 5, 5);

INSERT INTO Clientes (nombre, apellido, email, contraseña, direccion_envio)
VALUES
('Laura', 'García', 'laura.garcia@email.com', 'hash123abc', 'Calle Mayor 12, Madrid'),
('Carlos', 'Fernández', 'carlos.fernandez@email.com', 'hash456def', 'Av. del Sol 45, Sevilla'),
('Marta', 'López', 'marta.lopez@email.com', 'hash789ghi', 'C/ Jardines 8, Valencia'),
('Javier', 'Ruiz', 'javier.ruiz@email.com', 'hash000xyz', 'Paseo del Río 22, Barcelona');

INSERT INTO Ventas (id_cliente, estado, total)
VALUES
(1, 'Procesando', 749.98),
(2, 'Enviado', 49.99),
(3, 'Pendiente de Pago', 129.90),
(4, 'Entregado', 34.95);

INSERT INTO Detalle_Ventas (id_venta, id_producto, cantidad, precio_unitario_congelado)
VALUES
(1, 1, 1, 699.99),
(1, 2, 1, 14.99),
(2, 4, 1, 49.99),
(3, 3, 1, 129.90),
(4, 5, 1, 34.95);
