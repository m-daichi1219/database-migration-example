-- test_data.sql
-- 新しいeコマーススキーマのデータ整合性テスト

BEGIN;

-- テストプランの設定
SELECT plan(5);

-- サンプルデータが正しく挿入されているかテスト
SELECT is(
    (SELECT COUNT(*) FROM customers),
    2::bigint,
    'customersテーブルには2件のデータがあること'
);

SELECT is(
    (SELECT COUNT(*) FROM categories),
    3::bigint,
    'categoriesテーブルには3件のデータがあること'
);

SELECT is(
    (SELECT COUNT(*) FROM products),
    4::bigint,
    'productsテーブルには4件のデータがあること'
);

SELECT is(
    (SELECT COUNT(*) FROM product_categories),
    4::bigint,
    'product_categoriesテーブルには4件のデータがあること'
);

-- ordersとorder_itemsは初期データがないので0件
SELECT is(
    (SELECT COUNT(*) FROM orders),
    0::bigint,
    'ordersテーブルには初期データが0件であること'
);

-- テスト終了
SELECT * FROM finish();

ROLLBACK; 