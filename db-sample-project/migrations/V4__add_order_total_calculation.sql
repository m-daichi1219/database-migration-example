-- V4__add_order_total_calculation.sql
-- 注文合計金額を計算する関数と、order_items変更時にorders.total_amountを更新するトリガーを追加

-- 注文合計金額を計算する関数
CREATE OR REPLACE FUNCTION calculate_order_total(p_order_id INTEGER)
RETURNS NUMERIC(12, 2) AS $$
DECLARE
    v_total_amount NUMERIC(12, 2) := 0.00;
BEGIN
    SELECT COALESCE(SUM(quantity * unit_price), 0.00)
    INTO v_total_amount
    FROM order_items
    WHERE order_id = p_order_id;

    RETURN v_total_amount;
END;
$$ LANGUAGE plpgsql;

-- 注文アイテム変更時に注文合計金額を更新する関数
CREATE OR REPLACE FUNCTION update_order_total_amount()
RETURNS TRIGGER AS $$
BEGIN
    -- order_itemsのINSERT, UPDATE, DELETE時にorders.total_amountを更新
    UPDATE orders
    SET total_amount = calculate_order_total(COALESCE(NEW.order_id, OLD.order_id))
    WHERE id = COALESCE(NEW.order_id, OLD.order_id);

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- order_itemsテーブルにトリガーを設定
CREATE TRIGGER trigger_update_order_total_after_change
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_order_total_amount(); 