# Full reproducible script — replace placeholders for DB connection before running.
# ---------------------------------------------------------------
from sqlalchemy import create_engine, text
import pandas as pd
import numpy as np

# --------- CONFIG: replace these with your values (do NOT post real passwords) ----------
DB_USER = "postgres"
DB_PASS = "YOUR_PASSWORD"         # <- replace
DB_HOST = "localhost"
DB_PORT = "1223"
DB_NAME_ADMIN = "postgres"        # admin/default DB for initial listing
DB_NAME_WORK = "demo"             # target DB where we'll create/load table
# ---------------------------------------------------------------------------------------

# Connect to Postgres (admin/db list)
admin_engine = create_engine(f"postgresql+psycopg2://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME_ADMIN}")
print("✅ Connected via SQLAlchemy! Databases available:")
dbs = pd.read_sql_query("SELECT datname FROM pg_database;", admin_engine)
print(dbs)

# Connect to working DB
engine = create_engine(f"postgresql+psycopg2://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME_WORK}")

# List existing public tables
tables = pd.read_sql_query(
    "SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name;",
    engine
)
print("\n📋 Tables in 'public' schema:")
print(tables)

# Optional: show preview + counts for each table (useful for context)
for table in tables['table_name']:
    print('\n' + '-'*50)
    print(f"📋 Table: {table}")
    print('-'*50)
    count_query = f'SELECT COUNT(*) AS cnt FROM public."{table}";'
    count = pd.read_sql_query(count_query, engine)['cnt'].values[0]
    print(f"Total Rows: {count}\n")
    preview_query = f'SELECT * FROM public."{table}" LIMIT 5;'
    display(pd.read_sql_query(preview_query, engine))
    print('\n' + '='*100 + '\n')

# -------------------------
# Build vendor_sales_summary
# -------------------------
rcb = ("""
WITH freightsummary AS (
    SELECT vendornumber, SUM(freight) AS freightcost
    FROM vendor_invoice
    GROUP BY vendornumber
),

purchasesummary AS (
    SELECT
        p.vendornumber,
        p.vendorname,
        p.brand,
        p.description,
        p.purchaseprice,
        pp.price AS actualprice,
        pp.volume,
        SUM(p.quantity) AS totalpurchasequantity,
        SUM(p.dollars) AS totalpurchasedollars
    FROM purchases p
    JOIN purchase_prices pp ON p.brand = pp.brand
    WHERE p.purchaseprice > 0
    GROUP BY
        p.vendornumber,
        p.vendorname,
        p.brand,
        p.description,
        p.purchaseprice,
        pp.price,
        pp.volume
),

salessummary AS (
    SELECT
        vendorno,
        brand,
        SUM(salesdollars) AS totalsaledollar,
        SUM(salesprice) AS totalsaleprice,
        SUM(salesquantity) AS totalsalesquantity,
        SUM(excisetax) AS totalexcisetax
    FROM sales
    GROUP BY vendorno, brand
)

SELECT
    ps.vendornumber,
    ps.vendorname,
    ps.brand,
    ps.description,
    ps.purchaseprice,
    ps.actualprice,
    ps.volume,
    ps.totalpurchasequantity,
    ps.totalpurchasedollars,
    ss.totalsaledollar,
    ss.totalsaleprice,
    ss.totalsalesquantity,
    ss.totalexcisetax,
    fs.freightcost
FROM purchasesummary ps
LEFT JOIN salessummary ss
    ON ps.vendornumber = ss.vendorno
    AND ps.brand = ss.brand
LEFT JOIN freightsummary fs
    ON ps.vendornumber = fs.vendornumber
ORDER BY ps.totalpurchasedollars DESC;
""")

print("📥 Running aggregation query to build vendor_sales_summary — this may take a while for large datasets...")
vendor_sales_summary = pd.read_sql_query(rcb, engine)
print("✅ Aggregation finished — sample:")
display(vendor_sales_summary.head())

# -------------------------
# Clean & enrich DataFrame
# -------------------------
# ensure numeric types
vendor_sales_summary['volume'] = pd.to_numeric(vendor_sales_summary['volume'], errors='coerce').fillna(0).astype('float64')
vendor_sales_summary['purchaseprice'] = pd.to_numeric(vendor_sales_summary['purchaseprice'], errors='coerce').fillna(0.0)
vendor_sales_summary['actualprice'] = pd.to_numeric(vendor_sales_summary['actualprice'], errors='coerce').fillna(0.0)

# fill missing numeric values with 0
vendor_sales_summary.fillna(0, inplace=True)

# strip whitespace from text fields
vendor_sales_summary['vendorname'] = vendor_sales_summary['vendorname'].astype(str).str.strip()
vendor_sales_summary['description'] = vendor_sales_summary['description'].astype(str).str.strip()

# create KPI columns (handle divide-by-zero safely)
vendor_sales_summary['GrossProfit'] = vendor_sales_summary['totalsaledollar'] - vendor_sales_summary['totalpurchasedollars']
vendor_sales_summary['ProfitMargin'] = vendor_sales_summary.apply(
    lambda r: (r['GrossProfit'] / r['totalsaledollar'] * 100) if r['totalsaledollar'] != 0 else 0, axis=1
)
vendor_sales_summary['StockTurnover'] = vendor_sales_summary.apply(
    lambda r: (r['totalsalesquantity'] / r['totalpurchasequantity']) if r['totalpurchasequantity'] != 0 else 0, axis=1
)
vendor_sales_summary['SaleToPurchaseRatio'] = vendor_sales_summary.apply(
    lambda r: (r['totalsaledollar'] / r['totalpurchasedollars']) if r['totalpurchasedollars'] != 0 else 0, axis=1
)

print("✅ Data cleaning + KPI computation complete — dtypes:")
print(vendor_sales_summary.dtypes)

# -------------------------
# Create vendor_sales table DDL (optional; to ensure schema)
# -------------------------
create_table_query = """
CREATE TABLE IF NOT EXISTS vendor_sales (
    vendornumber INT,
    vendorname VARCHAR(255),
    brand VARCHAR(50),
    description VARCHAR(255),
    purchaseprice DECIMAL(10,2),
    actualprice DECIMAL(10,2),
    volume DECIMAL(15,2),
    totalpurchasequantity BIGINT,
    totalpurchasedollars DECIMAL(18,2),
    totalsaledollar DECIMAL(18,2),
    totalsaleprice DECIMAL(18,2),
    totalsalesquantity BIGINT,
    totalexcisetax DECIMAL(18,2),
    freightcost DECIMAL(18,2),
    GrossProfit DECIMAL(18,2),
    ProfitMargin DOUBLE PRECISION,
    StockTurnover DOUBLE PRECISION,
    SaleToPurchaseRatio DOUBLE PRECISION
);
"""

with engine.connect() as conn:
    conn.execute(text(create_table_query))
    conn.commit()
print("✅ Table 'vendor_sales' ensured in DB (DDL executed).")

# -------------------------
# Push cleaned DataFrame to Postgres (replace)
# -------------------------
vendor_sales_summary.to_sql('vendor_sales', con=engine, if_exists='replace', index=False)
print("✅ Data from 'vendor_sales_summary' written to 'vendor_sales' table (if_exists='replace').")

# -------------------------
# Quick verification (counts + sample)
# -------------------------
row_count = pd.read_sql_query("SELECT COUNT(*) AS cnt FROM vendor_sales;", engine)['cnt'].iloc[0]
print(f"📊 Rows in vendor_sales: {row_count}")
print("🔎 Sample rows from vendor_sales:")
display(pd.read_sql_query("SELECT * FROM vendor_sales LIMIT 5;", engine))
# ---------------------------------------------------------------
