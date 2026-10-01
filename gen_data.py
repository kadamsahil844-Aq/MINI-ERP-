"""Generates sample_data.sql (deterministic, seed=7)."""
import random, datetime
random.seed(7)
suppliers=[("TechSource India","Mumbai"),("Prime Office Supplies","Pune"),("Delta Electronics","Bengaluru"),
("Urban Furnishings","Thane"),("Paper & Pen Co.","Nashik"),("Nova Peripherals","Hyderabad"),("Bright Print Solutions","Mumbai")]
# name, category, supplier_idx(1-based), cost, price, stock, reorder
products=[("Wireless Mouse","Electronics",6,350,599,120,30),("Mechanical Keyboard","Electronics",6,1800,2799,45,15),
("USB-C Hub","Electronics",3,900,1499,60,20),("27-inch Monitor","Electronics",3,9500,13999,18,10),
("Laptop Stand","Electronics",3,600,999,8,15),("Webcam HD","Electronics",6,1200,1899,25,10),
("Ergonomic Chair","Furniture",4,5200,7999,12,8),("Office Desk","Furniture",4,6500,9499,6,8),
("Filing Cabinet","Furniture",4,3800,5499,14,5),("Monitor Arm","Furniture",4,1500,2399,22,10),
("A4 Paper Ream","Stationery",2,210,320,400,100),("Ball Pen Box (50)","Stationery",5,150,249,150,40),
("Notebook Pack (5)","Stationery",5,180,299,90,30),("Stapler","Stationery",2,120,199,7,20),
("Whiteboard Marker Set","Stationery",5,140,229,65,25),("Printer Toner","Printing",7,2400,3499,16,12),
("Inkjet Cartridge","Printing",7,700,1099,9,15),("Label Printer Rolls","Printing",7,320,499,55,20),
("External SSD 1TB","Electronics",3,5200,7499,30,10),("Surge Protector","Electronics",6,450,749,48,15)]
customers=[("Apex Logistics","Mumbai"),("Bluewave Traders","Pune"),("CityCare Clinics","Thane"),("Dhruv Consulting","Mumbai"),
("EduSmart Academy","Navi Mumbai"),("FreshMart Retail","Nashik"),("GreenLeaf Pharma","Mumbai"),("Horizon Realty","Pune"),
("InnoSoft Systems","Bengaluru"),("Jupiter Textiles","Surat"),("Kiran Hardware","Thane"),("Lotus Hospitality","Mumbai"),
("Metro Auto Parts","Pune"),("Nexus Media","Mumbai"),("Orbit Travels","Goa")]
statuses=["Delivered"]*7+["Shipped"]*2+["Pending"]*1
q=lambda s:"'"+s.replace("'","''")+"'"
out=["USE mini_erp;\n"]
out.append("INSERT INTO suppliers (supplier_id, supplier_name, city, email) VALUES")
out.append(",\n".join(f"({i+1}, {q(n)}, {q(c)}, {q(n.split()[0].lower().replace('&','')+'@example.com')})" for i,(n,c) in enumerate(suppliers))+";\n")
out.append("INSERT INTO products (product_id, sku, product_name, category, supplier_id, unit_cost, unit_price, stock_qty, reorder_level) VALUES")
out.append(",\n".join(f"({i+1}, {q('SKU-%03d'%(i+1))}, {q(n)}, {q(c)}, {s}, {co}, {pr}, {st}, {rl})" for i,(n,c,s,co,pr,st,rl) in enumerate(products))+";\n")
out.append("INSERT INTO customers (customer_id, customer_name, city, email) VALUES")
out.append(",\n".join(f"({i+1}, {q(n)}, {q(c)}, {q(n.split()[0].lower()+'@example.com')})" for i,(n,c) in enumerate(customers))+";\n")
orders=[];items=[];oi=1
start=datetime.date(2026,1,1)
for o in range(1,71):
    cust=random.randint(1,13)  # customers 14,15 never order -> shows LEFT JOIN query
    d=start+datetime.timedelta(days=random.randint(0,270))
    age=(datetime.date(2026,9,30)-d).days
    st="Cancelled" if random.random()<0.06 else ("Delivered" if age>30 else random.choice(statuses))
    orders.append((o,cust,d.isoformat(),st))
    for p in random.sample(range(1,21),random.randint(1,4)):
        qty=random.randint(1,12) if products[p-1][1]!="Furniture" else random.randint(1,4)
        items.append((oi,o,p,qty,products[p-1][4])); oi+=1
out.append("INSERT INTO orders (order_id, customer_id, order_date, status) VALUES")
out.append(",\n".join(f"({a}, {b}, {q(c)}, {q(d)})" for a,b,c,d in orders)+";\n")
out.append("INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES")
out.append(",\n".join(f"({a}, {b}, {c}, {d}, {e})" for a,b,c,d,e in items)+";\n")
low=[i+1 for i,p in enumerate(products) if p[5]<=p[6]]
pos=[]
for k,p in enumerate(low[:4]):
    pos.append((k+1,products[p-1][2],p,products[p-1][6]*3,"2026-09-%02d"%(10+k),"Open"))
for k in range(4,9):
    p=random.randint(1,20)
    pos.append((k+1,products[p-1][2],p,random.randint(20,100),"2026-0%d-%02d"%(random.randint(4,8),random.randint(1,28)),"Received"))
out.append("INSERT INTO purchase_orders (po_id, supplier_id, product_id, quantity, po_date, status) VALUES")
out.append(",\n".join(f"({a}, {b}, {c}, {d}, {q(e)}, {q(f)})" for a,b,c,d,e,f in pos)+";\n")
open("sample_data.sql","w").write("\n".join(out))
print(len(orders),"orders",len(items),"items","low stock:",low)
