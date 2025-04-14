-- V6__insert_sample_data.sql
-- 基本的なサンプルデータを挿入

-- 顧客データ
INSERT INTO customers (name, email, password_hash) VALUES
('山田 太郎', 'taro.yamada@example.com', '$2a$10$rANlOYaVUfzYAYOQr4Dyt.wuTEZZCYRoYQVTu6n2oF7cCPRz8EgZ.'), -- password: password123
('佐藤 花子', 'hanako.sato@example.com', '$2a$10$X18YkGmkmRRrk/s/9l3H9Ob1vWIDuTIUdw5VeBhkR8MDw6x7/0ww6'); -- password: password456

-- カテゴリデータ
INSERT INTO categories (name) VALUES ('Electronics'), ('Books'), ('Clothing');

-- 商品データ
INSERT INTO products (name, description, price, stock_quantity) VALUES
('Laptop Pro X', 'High-performance laptop', 1500.00, 50),
('Introduction to SQL', 'A comprehensive guide to SQL', 45.50, 100),
('Classic T-Shirt', 'Comfortable cotton T-shirt', 25.00, 200),
('Smartphone Z', 'Latest smartphone model', 999.99, 30);

-- 商品カテゴリデータ
INSERT INTO product_categories (product_id, category_id) VALUES
((SELECT id FROM products WHERE name = 'Laptop Pro X'), (SELECT id FROM categories WHERE name = 'Electronics')),
((SELECT id FROM products WHERE name = 'Introduction to SQL'), (SELECT id FROM categories WHERE name = 'Books')),
((SELECT id FROM products WHERE name = 'Classic T-Shirt'), (SELECT id FROM categories WHERE name = 'Clothing')),
((SELECT id FROM products WHERE name = 'Smartphone Z'), (SELECT id FROM categories WHERE name = 'Electronics'));

-- ordersとorder_itemsはプロシージャやアプリケーション経由で作成されるため、ここでは挿入しない 