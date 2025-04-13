#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  -- PgTap拡張をインストール
  CREATE EXTENSION IF NOT EXISTS pgtap;
  
  -- データベース用のロールとユーザー設定
  CREATE ROLE app_user WITH LOGIN PASSWORD 'app_password';
  ALTER ROLE app_user SET client_min_messages TO 'warning';
  GRANT ALL PRIVILEGES ON DATABASE "$POSTGRES_DB" TO app_user;
  
  -- スキーマ作成（Flywayでも行えるが、初期化のため）
  CREATE SCHEMA IF NOT EXISTS public;
  GRANT ALL ON SCHEMA public TO app_user;
EOSQL

# 実行権限を付与
chmod +x /docker-entrypoint-initdb.d/init-db.sh 