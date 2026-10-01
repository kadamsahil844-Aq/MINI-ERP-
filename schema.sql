-- Mini ERP: Inventory, Procurement & Sales
-- Target: MySQL 8.x
DROP DATABASE IF EXISTS mini_erp;
CREATE DATABASE mini_erp;
USE mini_erp;

CREATE TABLE suppliers (
    supplier_id   INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100) NOT NULL,
    city          VARCHAR(50),
    email         VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id    INT PRIMARY KEY AUTO_INCREMENT,
    sku           VARCHAR(20) NOT NULL UNIQUE,
    product_name  VARCHAR(100) NOT NULL,
    category      VARCHAR(50) NOT NULL,
    supplier_id   INT NOT NULL,
    unit_cost     DECIMAL(10,2) NOT NULL CHECK (unit_cost >= 0),
    unit_price    DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    stock_qty     INT NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
    reorder_level INT NOT NULL DEFAULT 10,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
) ENGINE=InnoDB;

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    city          VARCHAR(50),
    email         VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id    INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date  DATE NOT NULL,
    status      VARCHAR(20) NOT NULL DEFAULT 'Pending',  -- Pending / Shipped / Delivered / Cancelled
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id      INT NOT NULL,
    product_id    INT NOT NULL,
    quantity      INT NOT NULL CHECK (quantity > 0),
    unit_price    DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

CREATE TABLE purchase_orders (
    po_id        INT PRIMARY KEY AUTO_INCREMENT,
    supplier_id  INT NOT NULL,
    product_id   INT NOT NULL,
    quantity     INT NOT NULL CHECK (quantity > 0),
    po_date      DATE NOT NULL,
    status       VARCHAR(20) NOT NULL DEFAULT 'Open',  -- Open / Received
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (product_id)  REFERENCES products(product_id)
) ENGINE=InnoDB;

-- Reporting view: one row per sold line item (cancelled orders excluded)
CREATE VIEW v_sales_detail AS
SELECT o.order_id,
       o.order_date,
       c.customer_name,
       p.product_name,
       p.category,
       oi.quantity,
       oi.unit_price,
       oi.quantity * oi.unit_price AS line_total
FROM orders o
JOIN customers c    ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
JOIN products p     ON p.product_id  = oi.product_id
WHERE o.status <> 'Cancelled';
