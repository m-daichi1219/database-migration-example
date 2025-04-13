-- V2__add_sample_data.sql
-- サンプルデータの追加

-- ユーザーサンプルデータ
INSERT INTO users (email, username, password_hash) VALUES
('user1@example.com', 'user1', '$2a$10$rANlOYaVUfzYAYOQr4Dyt.wuTEZZCYRoYQVTu6n2oF7cCPRz8EgZ.'),
('user2@example.com', 'user2', '$2a$10$X18YkGmkmRRrk/s/9l3H9Ob1vWIDuTIUdw5VeBhkR8MDw6x7/0ww6'),
('admin@example.com', 'admin', '$2a$10$QO9RkWXFIeJqK2QdLK85nOIiGnxj5hV1EfWoN1n7PB2n0cjbOJZ9.');

-- タスクサンプルデータ（user1のタスク）
INSERT INTO tasks (user_id, title, description, status, priority, due_date) VALUES
((SELECT id FROM users WHERE username = 'user1'), 'データベース設計', 'テーブル定義とリレーションシップの設計', 'completed', 1, CURRENT_TIMESTAMP + INTERVAL '2 days'),
((SELECT id FROM users WHERE username = 'user1'), 'APIエンドポイント実装', 'RESTful APIのエンドポイント実装', 'in-progress', 2, CURRENT_TIMESTAMP + INTERVAL '5 days'),
((SELECT id FROM users WHERE username = 'user1'), 'フロントエンド開発', 'Reactコンポーネントの作成', 'pending', 2, CURRENT_TIMESTAMP + INTERVAL '10 days');

-- タスクサンプルデータ（user2のタスク）
INSERT INTO tasks (user_id, title, description, status, priority, due_date) VALUES
((SELECT id FROM users WHERE username = 'user2'), 'テスト作成', 'ユニットテストの実装', 'pending', 1, CURRENT_TIMESTAMP + INTERVAL '3 days'),
((SELECT id FROM users WHERE username = 'user2'), 'ドキュメント作成', 'APIドキュメントの作成', 'pending', 3, CURRENT_TIMESTAMP + INTERVAL '7 days');

-- タスクサンプルデータ（adminのタスク）
INSERT INTO tasks (user_id, title, description, status, priority, due_date) VALUES
((SELECT id FROM users WHERE username = 'admin'), 'デプロイメント設定', 'AWSへのデプロイメント設定', 'pending', 1, CURRENT_TIMESTAMP + INTERVAL '1 day'),
((SELECT id FROM users WHERE username = 'admin'), 'パフォーマンス改善', 'クエリ最適化とインデックス設定', 'pending', 2, CURRENT_TIMESTAMP + INTERVAL '6 days'),
((SELECT id FROM users WHERE username = 'admin'), 'セキュリティレビュー', '脆弱性診断と対策', 'pending', 1, CURRENT_TIMESTAMP + INTERVAL '4 days'); 