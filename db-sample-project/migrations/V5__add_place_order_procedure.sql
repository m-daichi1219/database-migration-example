-- V5__add_place_order_procedure.sql
-- 注文を受け付け、在庫を更新するストアドプロシージャを追加

CREATE OR REPLACE PROCEDURE place_order(
    p_customer_id INTEGER,
    p_shipping_address TEXT,
    p_product_ids INTEGER[],
    p_quantities INTEGER[],
    OUT p_order_id INTEGER,
    OUT p_error_message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_product_id INTEGER;
    v_quantity INTEGER;
    v_product_price NUMERIC(10, 2);
    v_stock INTEGER;
    i INTEGER;
BEGIN
    p_order_id := NULL;
    p_error_message := NULL;

    -- 配列の長さチェック
    IF array_length(p_product_ids, 1) IS NULL OR array_length(p_quantities, 1) IS NULL OR array_length(p_product_ids, 1) <> array_length(p_quantities, 1) THEN
        p_error_message := '商品IDと数量の配列の長さが一致しません。';
        RETURN;
    END IF;

    -- 在庫チェック (FOR UPDATEでロックを取得すべきだが、例として簡略化)
    FOR i IN 1..array_length(p_product_ids, 1) LOOP
        v_product_id := p_product_ids[i];
        v_quantity := p_quantities[i];

        -- 商品が存在するか、在庫があるか確認
        SELECT stock_quantity INTO v_stock FROM products WHERE id = v_product_id;

        IF v_stock IS NULL THEN
            p_error_message := '商品ID ' || v_product_id || ' が見つかりません。';
            RAISE EXCEPTION USING MESSAGE = p_error_message;
        END IF;

        IF v_stock < v_quantity THEN
            p_error_message := '商品ID ' || v_product_id || ' の在庫が不足しています。(在庫: ' || v_stock || ', 要求: ' || v_quantity || ')';
            RAISE EXCEPTION USING MESSAGE = p_error_message;
        END IF;
    END LOOP;

    -- トランザクション開始点 (プロシージャの外側で管理するのが一般的)
    -- BEGIN;

    -- 注文作成
    INSERT INTO orders (customer_id, shipping_address, status)
    VALUES (p_customer_id, p_shipping_address, 'pending')
    RETURNING id INTO p_order_id;

    -- 注文アイテム作成と在庫更新
    FOR i IN 1..array_length(p_product_ids, 1) LOOP
        v_product_id := p_product_ids[i];
        v_quantity := p_quantities[i];

        -- 現在の商品価格を取得
        SELECT price INTO v_product_price FROM products WHERE id = v_product_id;

        -- 注文アイテム挿入
        INSERT INTO order_items (order_id, product_id, quantity, unit_price)
        VALUES (p_order_id, v_product_id, v_quantity, v_product_price);

        -- 在庫更新
        UPDATE products
        SET stock_quantity = stock_quantity - v_quantity
        WHERE id = v_product_id;
    END LOOP;

    -- トランザクションコミット点
    -- COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS p_error_message = MESSAGE_TEXT;
        -- エラーが発生した場合、ロールバックすべき
        -- ROLLBACK;
        -- 既に挿入された注文をキャンセル状態にするか、あるいは呼び出し側で制御
        IF p_order_id IS NOT NULL THEN
             UPDATE orders SET status = 'cancelled' WHERE id = p_order_id;
        END IF;
        -- エラーメッセージはOUTパラメータで返す
END;
$$;