-- test_data.sql
-- PgTapを使用したデータ整合性テスト

BEGIN;

-- テストプランの設定
SELECT plan(6);

-- サンプルデータが正しく挿入されているかテスト
SELECT is(
    (SELECT COUNT(*) FROM users),
    3::bigint,
    'usersテーブルには3件のデータがあること'
);

SELECT is(
    (SELECT COUNT(*) FROM tasks),
    8::bigint,
    'tasksテーブルには8件のデータがあること'
);

-- 特定のユーザーが存在するかテスト
SELECT is(
    (SELECT COUNT(*) FROM users WHERE username = 'admin'),
    1::bigint,
    'adminユーザーが存在すること'
);

-- 特定のユーザーのタスク数をテスト
SELECT is(
    (SELECT COUNT(*) FROM tasks WHERE user_id = (SELECT id FROM users WHERE username = 'user1')),
    3::bigint,
    'user1のタスク数は3件であること'
);

SELECT is(
    (SELECT COUNT(*) FROM tasks WHERE user_id = (SELECT id FROM users WHERE username = 'user2')),
    2::bigint,
    'user2のタスク数は2件であること'
);

-- 特定のステータスのタスク数をテスト
SELECT is(
    (SELECT COUNT(*) FROM tasks WHERE status = 'pending'),
    6::bigint,
    'pendingステータスのタスク数は6件であること'
);

-- テスト終了
SELECT * FROM finish();

ROLLBACK; 