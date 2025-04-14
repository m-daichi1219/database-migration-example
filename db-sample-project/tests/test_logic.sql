-- test_logic.sql
-- 関数、プロシージャ、トリガーのロジックテスト

BEGIN;

-- テストプランの設定 (トップレベルのSELECT is/ok/results_eq の数)
SELECT plan(7); -- place_order正常系(4) + calculate_total(1) + trigger(1) + place_orderエラー系(1)

-- 1. place_orderプロシージャの正常系テスト: アクション実行
DO $$
DECLARE
    v_customer1_id INTEGER;
    v_laptop_id INTEGER;
    v_shirt_id INTEGER;
    v_order_id INTEGER; -- この変数はDOブロック外から参照不可
    v_error_message TEXT; -- この変数もDOブロック外から参照不可
BEGIN
    -- テスト用ID取得
    SELECT id INTO v_customer1_id FROM customers WHERE email = 'taro.yamada@example.com';
    SELECT id INTO v_laptop_id FROM products WHERE name = 'Laptop Pro X';
    SELECT id INTO v_shirt_id FROM products WHERE name = 'Classic T-Shirt';

    -- 注文実行
    CALL place_order(v_customer1_id, 'Tokyo Main St 123', ARRAY[v_laptop_id, v_shirt_id], ARRAY[1, 2], v_order_id, v_error_message);
END $$;

-- 1.1 place_order正常系テスト: 注文とアイテム数の検証
SELECT is(
    (SELECT COUNT(*) FROM orders WHERE shipping_address = 'Tokyo Main St 123'),
    1::bigint,
    'place_order: 正常系 - 注文が1件作成されること'
);
SELECT is(
    (SELECT COUNT(*) FROM order_items WHERE order_id = (SELECT id FROM orders WHERE shipping_address = 'Tokyo Main St 123')),
    2::bigint,
    'place_order: 正常系 - 注文アイテムが2件作成されること'
);

-- 1.2 place_order正常系テスト: 在庫数の検証
SELECT results_eq(
    $$ SELECT name, stock_quantity FROM products WHERE name IN ('Laptop Pro X', 'Classic T-Shirt') ORDER BY name $$,
    $$ VALUES ('Classic T-Shirt'::varchar, 198::integer), ('Laptop Pro X'::varchar, 49::integer) $$, -- 型キャストを追加して比較の確実性を高める
    'place_order: 正常系 - 在庫が正しく減少すること'
);

-- 1.3 place_order正常系テスト: トリガーによる合計金額の検証
SELECT is(
    (SELECT total_amount FROM orders WHERE shipping_address = 'Tokyo Main St 123'),
    (SELECT (p1.price * 1) + (p2.price * 2)
     FROM products p1, products p2
     WHERE p1.name = 'Laptop Pro X' AND p2.name = 'Classic T-Shirt')::numeric,
    'place_order: 正常系 - トリガーにより合計金額が計算されること'
);

-- 2. calculate_order_total関数のテスト
SELECT is(
    calculate_order_total((SELECT id FROM orders WHERE shipping_address = 'Tokyo Main St 123')),
    (SELECT total_amount FROM orders WHERE shipping_address = 'Tokyo Main St 123'),
    'calculate_order_total: 関数が正しい合計金額を返すこと'
);

-- 3. アイテム追加時のトリガーテスト: アクション実行
DO $$
DECLARE
    v_order_id INTEGER;
    v_book_id INTEGER;
    v_book_price NUMERIC;
BEGIN
    SELECT id INTO v_order_id FROM orders WHERE shipping_address = 'Tokyo Main St 123';
    SELECT id, price INTO v_book_id, v_book_price FROM products WHERE name = 'Introduction to SQL';
    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (v_order_id, v_book_id, 1, v_book_price);
END $$;

-- 3.1 アイテム追加時のトリガーテスト: 合計金額の検証
SELECT is(
    (SELECT total_amount FROM orders WHERE shipping_address = 'Tokyo Main St 123'),
    (SELECT (p1.price * 1) + (p2.price * 2) + p3.price -- 元の合計 + 書籍の価格
     FROM products p1, products p2, products p3
     WHERE p1.name = 'Laptop Pro X' AND p2.name = 'Classic T-Shirt' AND p3.name = 'Introduction to SQL')::numeric,
    'trigger: アイテム追加時に合計金額が更新されること'
);

-- 4. place_orderプロシージャのエラー系テスト: アクション実行 (在庫不足)
DO $$
DECLARE
    v_customer1_id INTEGER;
    v_laptop_id INTEGER;
    v_order_id INTEGER;
    v_error_message TEXT;
    v_high_quantity INTEGER;
BEGIN
    SELECT id INTO v_customer1_id FROM customers WHERE email = 'taro.yamada@example.com';
    SELECT id INTO v_laptop_id FROM products WHERE name = 'Laptop Pro X';
    -- 現在の在庫+1で要求
    SELECT stock_quantity + 1 INTO v_high_quantity FROM products WHERE id = v_laptop_id;
    -- 例外が発生してもテストが止まらないようにブロックで囲む
    BEGIN
        CALL place_order(v_customer1_id, 'Error Address', ARRAY[v_laptop_id], ARRAY[v_high_quantity], v_order_id, v_error_message);
    EXCEPTION WHEN OTHERS THEN
        -- place_order内のEXCEPTIONブロックでエラーは握りつぶされ、
        -- OUTパラメータにメッセージが入る想定だが、ここでは何もしない
    END;
END $$;

-- 4.1 place_orderプロシージャのエラー系テスト: 副作用の検証
SELECT is(
    (SELECT COUNT(*) FROM orders WHERE shipping_address = 'Error Address'),
    0::bigint,
    'place_order: 在庫不足エラー後、該当の注文は作成/残存していないこと'
);

-- テスト終了
SELECT * FROM finish();

ROLLBACK; 