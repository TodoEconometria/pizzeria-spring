-- =============================================
-- DATOS INICIALES DE LA PIZZERIA
-- =============================================
-- ORDEN IMPORTANTE: primero las tablas sin dependencias,
-- luego las que dependen de otras.

-- 1. Pizzas (sin dependencias)
INSERT INTO pizzas (nombre, precio, categoria) VALUES ('Margarita', 8.50, 'CLASICA');
INSERT INTO pizzas (nombre, precio, categoria) VALUES ('Cuatro Quesos', 11.00, 'PREMIUM');
INSERT INTO pizzas (nombre, precio, categoria) VALUES ('Pepperoni', 9.50, 'CLASICA');
INSERT INTO pizzas (nombre, precio, categoria) VALUES ('Vegetal', 10.00, 'VEGANA');
INSERT INTO pizzas (nombre, precio, categoria) VALUES ('Hawaiana', 9.00, 'CLASICA');
INSERT INTO pizzas (nombre, precio, categoria) VALUES ('Trufa y Parmesano', 15.00, 'PREMIUM');
INSERT INTO pizzas (nombre, precio, categoria) VALUES ('Mini Jamon', 6.50, 'INFANTIL');

-- 2. Clientes (sin dependencias)
INSERT INTO clientes (nombre, categoria_cliente, tipo_cliente)
    VALUES ('Carlos Garcia', 'ORO', 'PARTICULAR');
INSERT INTO clientes (nombre, categoria_cliente, tipo_cliente)
    VALUES ('Ana Lopez', 'PLATA', 'PARTICULAR');
INSERT INTO clientes (nombre, categoria_cliente, tipo_cliente)
    VALUES ('Restaurante El Buen Sabor', 'PLATINO', 'EMPRESA');
INSERT INTO clientes (nombre, categoria_cliente, tipo_cliente)
    VALUES ('Maria Torres', 'BRONCE', 'PARTICULAR');

-- 3. Pedidos (dependen de clientes -> cliente_id debe existir)
INSERT INTO pedidos (cliente_id, fecha, total)
    VALUES (1, CURRENT_TIMESTAMP, 28.00);
INSERT INTO pedidos (cliente_id, fecha, total)
    VALUES (2, CURRENT_TIMESTAMP, 11.00);
INSERT INTO pedidos (cliente_id, fecha, total)
    VALUES (1, CURRENT_TIMESTAMP, 15.00);

-- 4. Relacion pedido-pizzas (depende de pedidos Y pizzas)
INSERT INTO pedido_pizzas (pedido_id, pizza_id) VALUES (1, 1);
INSERT INTO pedido_pizzas (pedido_id, pizza_id) VALUES (1, 2);
INSERT INTO pedido_pizzas (pedido_id, pizza_id) VALUES (1, 5);
INSERT INTO pedido_pizzas (pedido_id, pizza_id) VALUES (2, 2);
INSERT INTO pedido_pizzas (pedido_id, pizza_id) VALUES (3, 6);
