-- test_schema_triggers.sql
-- トリガーの存在テスト

BEGIN;

SELECT plan(2);

SELECT has_trigger('public', 'products', 'trigger_update_products_updated_at', 'products テーブルに trigger_update_products_updated_at トリガーが存在すること');
SELECT has_trigger('public', 'order_items', 'trigger_update_order_total_after_change', 'order_items テーブルに trigger_update_order_total_after_change トリガーが存在すること');

SELECT * FROM finish();
ROLLBACK; 