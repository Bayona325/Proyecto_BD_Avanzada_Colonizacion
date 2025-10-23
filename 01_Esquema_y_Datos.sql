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

INSERT INTO Categorias (nombre, descripcion) VALUES
('Electrónica', 'Productos electrónicos y dispositivos tecnológicos.'),
('Ropa', 'Prendas de vestir para hombres y mujeres.'),
('Hogar', 'Artículos y accesorios para el hogar.'),
('Juguetes', 'Juguetes y juegos para niños de todas las edades.'),
('Deportes', 'Equipamiento y accesorios deportivos.'),
('Libros', 'Libros y material de lectura.'),
('Belleza', 'Productos de cuidado personal y belleza.'),
('Automotriz', 'Accesorios y repuestos para vehículos.'),
('Jardinería', 'Herramientas y suministros para jardín.'),
('Oficina', 'Material de oficina y papelería.'),
('Mascotas', 'Artículos para el cuidado de mascotas.'),
('Salud', 'Productos para el bienestar y salud personal.'),
('Música', 'Instrumentos y accesorios musicales.'),
('Videojuegos', 'Consolas y juegos electrónicos.'),
('Calzado', 'Zapatos, botas y zapatillas.'),
('Electrodomésticos', 'Pequeños y grandes electrodomésticos.'),
('Decoración', 'Artículos decorativos para interiores.'),
('Fotografía', 'Cámaras y accesorios fotográficos.'),
('Viajes', 'Artículos para viajes y equipaje.'),
('Ferretería', 'Herramientas y materiales de construcción.');

INSERT INTO Proveedores (nombre, email_contacto, telefono_contacto) VALUES
('TechWorld S.A.', 'contacto@techworld.com', '+34 600 123 456'),
('ModaPlus Ltd.', 'ventas@modaplus.com', '+34 601 654 321'),
('CasaBonita S.L.', 'info@casabonita.es', '+34 602 222 333'),
('PlayTime Co.', 'soporte@playtime.co', '+34 603 444 555'),
('SportZone España', 'ventas@sportzone.es', '+34 604 999 888'),
('BookPlanet S.A.', 'info@bookplanet.com', '+34 605 123 777'),
('BeautyStore S.L.', 'contacto@beautystore.es', '+34 606 888 444'),
('AutoPro Ltd.', 'ventas@autopro.com', '+34 607 222 111'),
('GardenLife S.A.', 'info@gardenlife.es', '+34 608 999 222'),
('OfficeMax España', 'ventas@officemax.es', '+34 609 555 333'),
('PetWorld Co.', 'info@petworld.com', '+34 610 111 777'),
('HealthPlus S.L.', 'contacto@healthplus.es', '+34 611 333 888'),
('MusicManía', 'ventas@musicmania.com', '+34 612 666 000'),
('GameCenter S.A.', 'info@gamecenter.es', '+34 613 444 555'),
('ShoeStyle', 'contacto@shoestyle.com', '+34 614 222 333'),
('ElectroHome S.L.', 'ventas@electrohome.es', '+34 615 999 888'),
('DecoraPlus', 'info@decoraplus.com', '+34 616 555 777'),
('FotoTech', 'ventas@fototech.es', '+34 617 333 444'),
('TravelPack', 'contacto@travelpack.com', '+34 618 888 999'),
('FerreTools', 'info@ferretools.es', '+34 619 111 222');

INSERT INTO Productos (nombre, descripcion, precio, costo, stock, sku, id_categoria, id_proveedor) VALUES
('Smartphone Galaxy X', 'Teléfono inteligente de última generación con 128GB de almacenamiento.', 699.99, 450.00, 30, 'ELEC-001', 1, 1),
('Camiseta Básica Blanca', 'Camiseta de algodón 100% unisex.', 14.99, 6.00, 100, 'ROP-001', 2, 2),
('Cafetera Automática', 'Cafetera programable con molinillo integrado.', 129.90, 80.00, 20, 'HOG-001', 3, 3),
('Muñeca Interactiva', 'Muñeca con voz y movimientos automáticos.', 49.99, 25.00, 50, 'JUY-001', 4, 4),
('Balón de Fútbol Pro', 'Balón oficial tamaño 5 de alta resistencia.', 34.95, 18.00, 40, 'DEP-001', 5, 5),
('Libro: El Arte de Programar', 'Edición revisada con ejemplos prácticos.', 24.50, 10.00, 60, 'LIB-001', 6, 6),
('Crema Hidratante Natural', 'Crema para piel seca con aloe vera.', 12.90, 5.00, 80, 'BEL-001', 7, 7),
('Aceite para Motor 10W40', 'Lubricante sintético de alta calidad.', 45.00, 25.00, 50, 'AUT-001', 8, 8),
('Set de Herramientas Jardín', 'Incluye pala, rastrillo y guantes.', 29.99, 15.00, 40, 'JAR-001', 9, 9),
('Silla Ergonómica Oficina', 'Silla ajustable con soporte lumbar.', 199.00, 120.00, 15, 'OFI-001', 10, 10),
('Collar para Perro Grande', 'Cuero resistente con hebilla metálica.', 17.50, 8.00, 70, 'MAS-001', 11, 11),
('Termómetro Digital', 'Mide temperatura corporal con precisión.', 9.99, 3.00, 90, 'SAL-001', 12, 12),
('Guitarra Acústica', 'Instrumento de madera con funda incluida.', 159.99, 100.00, 25, 'MUS-001', 13, 13),
('Consola X-Gamer 5', 'Consola de videojuegos de última generación.', 499.00, 350.00, 20, 'VID-001', 14, 14),
('Zapatillas Running Air', 'Zapatillas deportivas ultraligeras.', 79.90, 40.00, 60, 'CAL-001', 15, 5),
('Aspiradora Ciclónica', 'Alta potencia de succión sin bolsa.', 149.90, 90.00, 25, 'ELEC-002', 16, 16),
('Lámpara de Mesa LED', 'Luz cálida regulable con diseño moderno.', 39.99, 20.00, 45, 'DEC-001', 17, 17),
('Cámara Reflex Pro', 'Sensor de 24MP y lente 18-55mm.', 699.00, 500.00, 10, 'FOT-001', 18, 18),
('Maleta Rígida 24"', 'Equipaje resistente con cierre TSA.', 89.99, 45.00, 30, 'VIA-001', 19, 19),
('Taladro Percutor 800W', 'Herramienta eléctrica profesional.', 99.99, 55.00, 25, 'FER-001', 20, 20);

INSERT INTO Clientes (nombre, apellido, email, contraseña, direccion_envio) VALUES
('Laura', 'García', 'laura.garcia@email.com', 'hash123abc', 'Calle Mayor 12, Madrid'),
('Carlos', 'Fernández', 'carlos.fernandez@email.com', 'hash456def', 'Av. del Sol 45, Sevilla'),
('Marta', 'López', 'marta.lopez@email.com', 'hash789ghi', 'C/ Jardines 8, Valencia'),
('Javier', 'Ruiz', 'javier.ruiz@email.com', 'hash000xyz', 'Paseo del Río 22, Barcelona'),
('Ana', 'Martín', 'ana.martin@email.com', 'hash111aaa', 'Gran Vía 20, Madrid'),
('Diego', 'Santos', 'diego.santos@email.com', 'hash222bbb', 'Av. Andalucía 14, Málaga'),
('Lucía', 'Ortega', 'lucia.ortega@email.com', 'hash333ccc', 'Calle Luna 3, Bilbao'),
('Raúl', 'Herrera', 'raul.herrera@email.com', 'hash444ddd', 'Pza. España 10, Zaragoza'),
('Elena', 'Moreno', 'elena.moreno@email.com', 'hash555eee', 'Camino Verde 9, Murcia'),
('Pablo', 'Gómez', 'pablo.gomez@email.com', 'hash666fff', 'Av. del Mar 2, Cádiz'),
('Sofía', 'Pérez', 'sofia.perez@email.com', 'hash777ggg', 'Calle Sol 15, Madrid'),
('Daniel', 'Iglesias', 'daniel.iglesias@email.com', 'hash888hhh', 'Calle Norte 4, León'),
('Carmen', 'Serrano', 'carmen.serrano@email.com', 'hash999iii', 'Av. Reyes Católicos 18, Burgos'),
('Iván', 'Muñoz', 'ivan.munoz@email.com', 'hash101jjj', 'Calle Ocaso 21, Toledo'),
('María', 'Castro', 'maria.castro@email.com', 'hash202kkk', 'C/ Primavera 33, Granada'),
('José', 'Navarro', 'jose.navarro@email.com', 'hash303lll', 'Av. Europa 99, A Coruña'),
('Paula', 'Díaz', 'paula.diaz@email.com', 'hash404mmm', 'Calle Sur 11, Salamanca'),
('Andrés', 'Gil', 'andres.gil@email.com', 'hash505nnn', 'Calle Real 8, Córdoba'),
('Rosa', 'Luna', 'rosa.luna@email.com', 'hash606ooo', 'Av. Libertad 16, Oviedo'),
('Fernando', 'Blanco', 'fernando.blanco@email.com', 'hash707ppp', 'Paseo del Prado 25, Madrid');

INSERT INTO Ventas (id_cliente, estado, total) VALUES
(1, 'Procesando', 749.98),
(2, 'Enviado', 49.99),
(3, 'Pendiente_Pago', 129.90),
(4, 'Entregado', 34.95),
(5, 'Procesando', 499.00),
(6, 'Entregado', 89.99),
(7, 'Pendiente_Pago', 24.50),
(8, 'Procesando', 79.90),
(9, 'Enviado', 159.99),
(10, 'Cancelado', 12.90),
(11, 'Procesando', 699.00),
(12, 'Entregado', 199.00),
(13, 'Pendiente_Pago', 99.99),
(14, 'Procesando', 149.90),
(15, 'Entregado', 29.99),
(16, 'Enviado', 45.00),
(17, 'Procesando', 39.99),
(18, 'Pendiente_Pago', 89.99),
(19, 'Entregado', 9.99),
(20, 'Procesando', 699.99);

INSERT INTO Detalle_Ventas (id_venta, id_producto, cantidad, precio_unitario_congelado) VALUES
(1, 1, 1, 699.99),
(1, 2, 1, 14.99),
(2, 4, 1, 49.99),
(3, 3, 1, 129.90),
(4, 5, 1, 34.95),
(5, 14, 1, 499.00),
(6, 19, 1, 89.99),
(7, 6, 1, 24.50),
(8, 15, 1, 79.90),
(9, 13, 1, 159.99),
(10, 7, 1, 12.90),
(11, 18, 1, 699.00),
(12, 10, 1, 199.00),
(13, 20, 1, 99.99),
(14, 16, 1, 149.90),
(15, 9, 1, 29.99),
(16, 8, 1, 45.00),
(17, 17, 1, 39.99),
(18, 19, 1, 89.99),
(19, 12, 1, 9.99);
