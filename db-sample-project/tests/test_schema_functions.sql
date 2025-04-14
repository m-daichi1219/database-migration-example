-- test_schema_functions.sql
-- 関数の存在テスト

BEGIN;

SELECT plan(3);

-- 関数とプロシージャのテスト
SELECT has_function('public', 'update_updated_at_column', '関数 "update_updated_at_column" が存在すること');
SELECT has_function('public', 'calculate_order_total', ARRAY['integer'], '関数 "calculate_order_total" が存在すること');
SELECT has_function('public', 'update_order_total_amount', '関数 "update_order_total_amount" が存在すること');

SELECT * FROM finish();
ROLLBACK; 