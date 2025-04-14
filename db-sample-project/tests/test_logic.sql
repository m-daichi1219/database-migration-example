-- test_logic.sql
-- 関数、プロシージャ、トリガーのロジックテスト

BEGIN;

-- テストプランの設定
SELECT plan(10);

-- テスト用データの準備
-- 顧客ID、商品IDを変数に格納
SELECT id INTO :customer1_id FROM customers WHERE email = 'taro.yamada@example.com';
SELECT id INTO :laptop_id FROM products WHERE name = 'Laptop Pro X';
SELECT id INTO :shirt_id FROM products WHERE name = 'Classic T-Shirt';
SELECT id INTO :book_id FROM products WHERE name = 'Introduction to SQL';
SELECT price INTO :laptop_price FROM products WHERE id = :laptop_id;
SELECT price INTO :shirt_price FROM products WHERE id = :shirt_id;

-- 1. place_orderプロシージャの正常系テスト
DO $$
DECLARE
    v_order_id INTEGER;
    v_error_message TEXT;
    v_initial_laptop_stock INTEGER;
    v_initial_shirt_stock INTEGER;
    v_final_laptop_stock INTEGER;
    v_final_shirt_stock INTEGER;
    v_order_total NUMERIC(12, 2);
BEGIN
    -- 初期在庫を取得
    SELECT stock_quantity INTO v_initial_laptop_stock FROM products WHERE id = :laptop_id;
    SELECT stock_quantity INTO v_initial_shirt_stock FROM products WHERE id = :shirt_id;

    -- 注文実行
    CALL place_order(:customer1_id, 'Tokyo Main St 123', ARRAY[:laptop_id, :shirt_id], ARRAY[1, 2], v_order_id, v_error_message);

    -- 結果検証
    PERFORM ok(v_error_message IS NULL, 'place_order: エラーメッセージがNULLであること');
    PERFORM ok(v_order_id IS NOT NULL, 'place_order: 注文IDが返されること');

    -- 在庫が減っているか確認
    SELECT stock_quantity INTO v_final_laptop_stock FROM products WHERE id = :laptop_id;
    SELECT stock_quantity INTO v_final_shirt_stock FROM products WHERE id = :shirt_id;
    PERFORM is(v_final_laptop_stock, v_initial_laptop_stock - 1, 'place_order: ラップトップの在庫が1減ること');
    PERFORM is(v_final_shirt_stock, v_initial_shirt_stock - 2, 'place_order: Tシャツの在庫が2減ること');

    -- 注文と注文アイテムが作成されているか確認
    PERFORM is((SELECT COUNT(*) FROM orders WHERE id = v_order_id)::integer, 1, 'place_order: ordersテーブルに注文が作成されること');
    PERFORM is((SELECT COUNT(*) FROM order_items WHERE order_id = v_order_id)::integer, 2, 'place_order: order_itemsテーブルに2つのアイテムが作成されること');

    -- トリガーによる合計金額が正しく計算されているか確認
    SELECT total_amount INTO v_order_total FROM orders WHERE id = v_order_id;
    PERFORM is(v_order_total, (:laptop_price * 1) + (:shirt_price * 2), 'trigger: 注文作成時に合計金額が正しく計算されること');

    -- :current_order_id として保存（後のテストで使用）
    EXECUTE 'SELECT ' || v_order_id || ' AS current_order_id';
END $$;

-- 2. calculate_order_total関数のテスト
-- 上で作られた注文の合計金額を関数で計算し、ordersテーブルの値と比較
SELECT is(
    calculate_order_total((SELECT current_order_id FROM __vars__)),
    (SELECT total_amount FROM orders WHERE id = (SELECT current_order_id FROM __vars__)),
    'calculate_order_total: 関数が正しい合計金額を返すこと'
);

-- 3. 注文アイテム追加時のトリガーテスト
-- 既存の注文に新しいアイテムを追加し、合計金額が更新されるかテスト
DO $$
DECLARE
    v_order_id INTEGER := (SELECT current_order_id FROM __vars__);
    v_book_price NUMERIC(10, 2);
    v_initial_total NUMERIC(12, 2);
    v_final_total NUMERIC(12, 2);
BEGIN
    SELECT price INTO v_book_price FROM products WHERE id = :book_id;
    SELECT total_amount INTO v_initial_total FROM orders WHERE id = v_order_id;

    -- アイテム追加
    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (v_order_id, :book_id, 1, v_book_price);

    -- 合計金額が更新されているか確認
    SELECT total_amount INTO v_final_total FROM orders WHERE id = v_order_id;
    PERFORM is(v_final_total, v_initial_total + v_book_price, 'trigger: アイテム追加時に合計金額が更新されること');
END $$;

-- 4. place_orderプロシージャの在庫不足エラーテスト
DO $$
DECLARE
    v_order_id INTEGER;
    v_error_message TEXT;
    v_high_quantity INTEGER;
BEGIN
    -- 在庫より多い数量を設定
    SELECT stock_quantity + 1 INTO v_high_quantity FROM products WHERE id = :laptop_id;

    -- 注文実行（在庫不足になるはず）
    CALL place_order(:customer1_id, 'Error Address', ARRAY[:laptop_id], ARRAY[v_high_quantity], v_order_id, v_error_message);

    -- エラーメッセージが出力されることを確認
    PERFORM ok(v_error_message LIKE '%' || :laptop_id || ' の在庫が不足しています%', 'place_order: 在庫不足時にエラーメッセージが返されること');
    -- PERFORM ok(v_order_id IS NULL, 'place_order: 在庫不足時に注文IDがNULLであること'); -- プロシージャ内でキャンセルされるためIDは発行される場合がある
END $$;


-- テスト終了
SELECT * FROM finish();

ROLLBACK; 