-- test_schema_tables.sql
-- テーブル、カラム、制約、インデックスのテスト

BEGIN;

SELECT plan(37); -- テーブル6 + スキーマ1 + カラム/インデックス/制約 30

-- スキーマ存在確認
SELECT has_schema('public', 'public スキーマが存在すること');

-- テーブル存在確認
SELECT has_table('public', 'customers', 'テーブル "customers" が存在すること');
SELECT has_table('public', 'categories', 'テーブル "categories" が存在すること');
SELECT has_table('public', 'products', 'テーブル "products" が存在すること');
SELECT has_table('public', 'product_categories', 'テーブル "product_categories" が存在すること');
SELECT has_table('public', 'orders', 'テーブル "orders" が存在すること');
SELECT has_table('public', 'order_items', 'テーブル "order_items" が存在すること');

-- customersテーブルのテスト
SELECT has_column('public', 'customers', 'id', 'customers に "id" カラムが存在');
SELECT has_column('public', 'customers', 'name', 'customers に "name" カラムが存在');
SELECT has_column('public', 'customers', 'email', 'customers に "email" カラムが存在');
SELECT col_is_unique('public', 'customers', 'email', 'customers.email はユニークであること');
SELECT has_index('public', 'customers', 'idx_customers_email', 'customers に email のインデックスが存在');

-- productsテーブルのテスト
SELECT has_column('public', 'products', 'id', 'products に "id" カラムが存在');
SELECT has_column('public', 'products', 'name', 'products に "name" カラムが存在');
SELECT has_column('public', 'products', 'price', 'products に "price" カラムが存在');
SELECT col_has_check('public', 'products', 'price', 'products.price に CHECK 制約が存在');
SELECT has_column('public', 'products', 'stock_quantity', 'products に "stock_quantity" カラムが存在');
SELECT col_has_default('public', 'products', 'stock_quantity', 'products.stock_quantity にデフォルト値が存在');
SELECT col_has_check('public', 'products', 'stock_quantity', 'products.stock_quantity に CHECK 制約が存在');
SELECT has_index('public', 'products', 'idx_products_name', 'products に name のインデックスが存在');

-- ordersテーブルのテスト
SELECT has_column('public', 'orders', 'id', 'orders に "id" カラムが存在');
SELECT has_column('public', 'orders', 'customer_id', 'orders に "customer_id" カラムが存在');
SELECT col_is_fk('public', 'orders', 'customer_id', 'orders.customer_id は外部キーであること');
SELECT has_column('public', 'orders', 'status', 'orders に "status" カラムが存在');
SELECT col_has_check('public', 'orders', 'status', 'orders.status に CHECK 制約が存在');
SELECT has_column('public', 'orders', 'total_amount', 'orders に "total_amount" カラムが存在');
SELECT col_has_default('public', 'orders', 'total_amount', 'orders.total_amount にデフォルト値が存在');
SELECT has_index('public', 'orders', 'idx_orders_customer_id', 'orders に customer_id のインデックスが存在');
SELECT has_index('public', 'orders', 'idx_orders_status', 'orders に status のインデックスが存在');

-- order_itemsテーブルのテスト
SELECT has_column('public', 'order_items', 'id', 'order_items に "id" カラムが存在');
SELECT has_column('public', 'order_items', 'order_id', 'order_items に "order_id" カラムが存在');
SELECT col_is_fk('public', 'order_items', 'order_id', 'order_items.order_id は外部キーであること');
SELECT has_column('public', 'order_items', 'product_id', 'order_items に "product_id" カラムが存在');
SELECT col_is_fk('public', 'order_items', 'product_id', 'order_items.product_id は外部キーであること');
SELECT col_has_check('public', 'order_items', 'quantity', 'order_items.quantity に CHECK 制約が存在');
SELECT has_index('public', 'order_items', 'idx_order_items_order_id', 'order_items に order_id のインデックスが存在');
SELECT has_index('public', 'order_items', 'idx_order_items_product_id', 'order_items に product_id のインデックスが存在');

SELECT * FROM finish();
ROLLBACK; 