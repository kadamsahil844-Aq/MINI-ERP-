USE mini_erp;

-- 1. Low-stock items that need reordering
SELECT p.product_id, p.product_name, p.stock_qty, p.reorder_level, s.supplier_name
FROM products p
JOIN suppliers s ON s.supplier_id = p.supplier_id
WHERE p.stock_qty <= p.reorder_level
ORDER BY p.stock_qty - p.reorder_level;

-- 2. Units sold and revenue by product (cancelled orders excluded)
SELECT product_name, SUM(quantity) AS units_sold, SUM(line_total) AS revenue
FROM v_sales_detail
GROUP BY product_name
ORDER BY revenue DESC;

-- 3. Revenue by customer
SELECT customer_name, COUNT(DISTINCT order_id) AS orders, SUM(line_total) AS revenue
FROM v_sales_detail
GROUP BY customer_name
ORDER BY revenue DESC;

-- 4. Monthly sales trend
SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month, SUM(line_total) AS revenue
FROM v_sales_detail
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY order_month;

-- 5. Revenue by category
SELECT category, SUM(quantity) AS units_sold, SUM(line_total) AS revenue
FROM v_sales_detail
GROUP BY category
ORDER BY revenue DESC;

-- 6. Open purchase orders with supplier and product details
SELECT po.po_id, s.supplier_name, p.product_name, po.quantity, po.po_date
FROM purchase_orders po
JOIN suppliers s ON s.supplier_id = po.supplier_id
JOIN products p  ON p.product_id  = po.product_id
WHERE po.status = 'Open'
ORDER BY po.po_date;

-- 7. Inventory value (at cost) per supplier
SELECT s.supplier_name, SUM(p.stock_qty * p.unit_cost) AS inventory_value
FROM suppliers s
JOIN products p ON p.supplier_id = s.supplier_id
GROUP BY s.supplier_name
ORDER BY inventory_value DESC;

-- 8. Customers who have never placed an order (LEFT JOIN)
SELECT c.customer_id, c.customer_name, c.city
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- 9. Gross margin by product (revenue minus cost of goods sold)
SELECT p.product_name,
       SUM(oi.quantity * oi.unit_price) AS revenue,
       SUM(oi.quantity * p.unit_cost)   AS cost,
       SUM(oi.quantity * (oi.unit_price - p.unit_cost)) AS gross_margin
FROM order_items oi
JOIN orders o   ON o.order_id   = oi.order_id AND o.status <> 'Cancelled'
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_name
HAVING gross_margin > 0
ORDER BY gross_margin DESC
LIMIT 5;
