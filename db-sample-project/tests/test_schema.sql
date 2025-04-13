-- test_schema.sql
-- PgTapを使用したスキーマテスト

BEGIN;

-- テストプランの設定（テスト数の宣言）
SELECT plan(16);

-- データベースのテスト
SELECT has_schema('public', 'public スキーマが存在すること');

-- usersテーブルのテスト
SELECT has_table('public', 'users', 'テーブル "users" が存在すること');
SELECT has_column('public.users', 'id', 'テーブル "users" に "id" カラムが存在すること');
SELECT has_column('public.users', 'email', 'テーブル "users" に "email" カラムが存在すること');
SELECT has_column('public.users', 'username', 'テーブル "users" に "username" カラムが存在すること');
SELECT has_column('public.users', 'password_hash', 'テーブル "users" に "password_hash" カラムが存在すること');
SELECT has_index('public.users', 'users_email_idx', 'インデックス "users_email_idx" が存在すること');

-- tasksテーブルのテスト
SELECT has_table('public', 'tasks', 'テーブル "tasks" が存在すること');
SELECT has_column('public.tasks', 'id', 'テーブル "tasks" に "id" カラムが存在すること');
SELECT has_column('public.tasks', 'user_id', 'テーブル "tasks" に "user_id" カラムが存在すること');
SELECT has_column('public.tasks', 'title', 'テーブル "tasks" に "title" カラムが存在すること');
SELECT has_column('public.tasks', 'description', 'テーブル "tasks" に "description" カラムが存在すること');
SELECT has_column('public.tasks', 'status', 'テーブル "tasks" に "status" カラムが存在すること');
SELECT has_index('public.tasks', 'tasks_user_id_status_idx', 'インデックス "tasks_user_id_status_idx" が存在すること');

-- 関数とトリガーのテスト
SELECT has_function('public', 'update_updated_at_column', 'update_updated_at_column関数が存在すること');
SELECT has_trigger('public', 'users', 'update_users_updated_at', 'usersテーブルにupdate_users_updated_atトリガーが存在すること');

-- テスト終了
SELECT * FROM finish();

ROLLBACK; 