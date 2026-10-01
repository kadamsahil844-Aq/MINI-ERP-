# Mini ERP: Inventory, Procurement & Sales

A small ERP-style database in **MySQL** with SQL reporting and an **Excel** report, modelling three core ERP modules: inventory, procurement (purchase orders) and sales (orders).

## Files
| File | Purpose |
|---|---|
| `schema.sql` | Creates the `mini_erp` database: 6 tables with primary/foreign keys and CHECK constraints, plus the `v_sales_detail` reporting view |
| `sample_data.sql` | Sample data: 7 suppliers, 20 products, 15 customers, 70 orders (161 line items), 9 purchase orders |
| `queries.sql` | 9 reporting queries (JOINs, GROUP BY, HAVING, LEFT JOIN, views) |
| `export_to_excel.py` | Pulls data from MySQL and builds `Mini_ERP_Report.xlsx` |
| `Mini_ERP_Report.xlsx` | Sample output: Summary, Sales_Detail, Inventory, Sales_By_Product, Monthly_Sales |
| `gen_data.py` | Regenerates `sample_data.sql` |

## Data model
`suppliers` 1-N `products` · `customers` 1-N `orders` 1-N `order_items` N-1 `products` · `purchase_orders` link `suppliers` and `products`.
Stock on hand is kept in `products.stock_qty` with a `reorder_level` per product.

## How to run
1. `mysql -u root -p < schema.sql`
2. `mysql -u root -p < sample_data.sql`
3. Run the queries in `queries.sql` (MySQL Workbench or the `mysql` CLI).
4. `pip install openpyxl mysql-connector-python`
5. Set `DB_HOST`, `DB_USER`, `DB_PASSWORD` if needed, then `python export_to_excel.py`
   (use `python export_to_excel.py --demo` to test without MySQL).

## Excel report
All totals and summary tables are **formulas** (SUMIFS, COUNTIF, INDEX/MATCH, IF) over the exported data, so the report recalculates when the data changes. Includes a revenue-by-product bar chart, a monthly revenue line chart, and a REORDER flag with highlighting for low-stock items.

## Sample insights
- Total revenue (excluding cancelled orders): 24.4 lakh INR; best month: May 2026
- Top product by revenue: 27-inch Monitor
- 4 products at or below their reorder level; 2 customers have never ordered
