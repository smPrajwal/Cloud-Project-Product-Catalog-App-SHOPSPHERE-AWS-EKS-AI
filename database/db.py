import os, time, pymysql
from flask import g
from database.seed_data import seed_data

# 1. Connect to Database
def get_db():
    if not getattr(g, '_database', None):
        conn_str = os.environ.get('DB_CONN_STRING')
        if not conn_str: return None

        parts = conn_str.split(":")
        try:
            g._database = pymysql.connect(host=parts[0], user=parts[1], password=parts[2], database=parts[3])
            print("LOG: Connected to RDS MySQL")
        except:
            time.sleep(3)
            g._database = pymysql.connect(host=parts[0], user=parts[1], password=parts[2], database=parts[3])

    return g._database

def close_connection(e):
    db = getattr(g, '_database', None)
    if db: db.close()

# 2. Easy Helpers
def query_db(sql, params=()):
    cursor = get_db().cursor()
    cursor.execute(sql, params)
    if cursor.description:
        columns = [c[0] for c in cursor.description]
        return [dict(zip(columns, row)) for row in cursor.fetchall()]
    return None

def query_one(sql, params=()):
    res = query_db(sql, params)
    return res[0] if res else None

def execute_db(sql, params=()):
    cursor = get_db().cursor()
    cursor.execute(sql, params)
    get_db().commit()
    return cursor

def insert_get_id(sql, params=()):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute(sql, params)
    new_id = cursor.lastrowid
    conn.commit()
    return new_id

# 3. Setup Tables & Default Data
def ensure_database():
    conn_str = os.environ.get('DB_CONN_STRING')
    if not conn_str: return
    try:
        parts = conn_str.split(":")
        conn = pymysql.connect(host=parts[0], user=parts[1], password=parts[2])
        conn.cursor().execute("CREATE DATABASE IF NOT EXISTS shopsphere")
        conn.close()
    except Exception as e:
        print(f"LOG: DB creation warning: {e}")

def init_db(app):
    with app.app_context():
        ensure_database()
        if not get_db(): return

        # Create Tables
        tables = [
            """products (id INT AUTO_INCREMENT PRIMARY KEY, name TEXT, description TEXT,
                price FLOAT, original_price FLOAT, thumbnail_url TEXT)""",
            """reviews (id INT AUTO_INCREMENT PRIMARY KEY, product_id INT, reviewer TEXT,
                review_text TEXT, sentiment_score FLOAT, sentiment_label TEXT,
                FOREIGN KEY(product_id) REFERENCES products(id))""",
            """product_tags (id INT AUTO_INCREMENT PRIMARY KEY, product_id INT, tag_name TEXT,
                FOREIGN KEY(product_id) REFERENCES products(id))""",
            """site_settings (`key` VARCHAR(450) PRIMARY KEY, value TEXT)""",
            """advertisements (id INT AUTO_INCREMENT PRIMARY KEY, badge TEXT, title TEXT,
                subtitle TEXT, button_text TEXT, category TEXT, image_url TEXT, gradient TEXT)"""
        ]
        for t in tables:
            name = t.strip().split(' ')[0].split('(')[0]
            execute_db(f"CREATE TABLE IF NOT EXISTS {t}")

        # Seed Products/Reviews
        seed_data(get_db())

        # Seed Footer Defaults
        defaults = [
            ('footer_brand_description', 'Your destination for quality products that blend aesthetics with functionality.'),
            ('footer_email', 'prajwalprajwal1999@gmail.com'),
            ('footer_phone', '+91 9035147223')
        ]
        for k, v in defaults:
            if not query_one("SELECT 1 FROM site_settings WHERE `key` = %s", (k,)):
                execute_db("INSERT INTO site_settings (`key`, value) VALUES (%s, %s)", (k, v))

        # Seed Ads
        ads = [
            ('LIMITED TIME', 'Tech Fest Sale', 'Up to 40% off on Electronics', 'Shop Now →', 'tech', '/static/uploads/promo_electronics.png', 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)'),
            ('NEW ARRIVALS', 'Fashion Week', 'Trendy styles at best prices', 'Explore →', 'fashion', '/static/uploads/promo_fashion.png', 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)'),
            ('MEGA SALE', 'Kitchen Essentials', 'Premium appliances at 30% off', 'Shop Now →', 'kitchen', '/static/uploads/promo_kitchen.png', 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)'),
            ('TRENDING', 'Lifestyle Picks', 'Curated collection for you', 'Discover →', 'lifestyle', '/static/uploads/promo_lifestyle.png', 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)'),
            ('WORK SMART', 'Office Essentials', 'Upgrade your workspace today', 'Shop Now →', 'office', '/static/uploads/promo_office.png', 'linear-gradient(135deg, #11998e 0%, #38ef7d 100%)')
        ]
        for ad in ads:
            if not query_one("SELECT 1 FROM advertisements WHERE title = %s", (ad[1],)):
                execute_db(
                    "INSERT INTO advertisements (badge, title, subtitle, button_text, category, image_url, gradient) VALUES (%s, %s, %s, %s, %s, %s, %s)", ad
                )
