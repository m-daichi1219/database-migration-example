# データベース管理サンプルプロジェクト

WSL2 と Docker を使用した PostgreSQL データベース管理のサンプルプロジェクトです。Flyway による DB マイグレーションと PgTap によるテスト自動化を実装しています。

## 前提条件

- WSL2 がインストールされていること
- WSL2 上に Docker がインストールされていること
- Git

## セットアップ手順

### 1. リポジトリのクローン

```bash
git clone <リポジトリURL>
cd db-sample-project
```

### 2. WSL2 で Docker が起動していることを確認

WSL2 で以下のコマンドを実行して Docker が起動していることを確認します。

```bash
wsl -d Ubuntu # または使用しているディストリビューション名
docker --version
```

Docker が起動していない場合は、以下のコマンドで起動します。

```bash
sudo service docker start
```

### 3. Docker コンテナのビルドと起動

```bash
cd db-sample-project/docker
chmod +x init-db.sh
docker-compose up -d --build
```

### 4. マイグレーションの実行

```bash
cd ../scripts
chmod +x run_migrations.sh
./run_migrations.sh
```

### 5. テストの実行

```bash
chmod +x run_tests.sh
./run_tests.sh
```

## プロジェクト構成

- **docker/**: Dockerfile と docker-compose.yml
- **migrations/**: Flyway マイグレーションスクリプト
- **tests/**: PgTap テストスクリプト
- **scripts/**: 実行スクリプト

## マイグレーションスクリプト

Flyway の命名規則に従ってマイグレーションスクリプトを作成します。

```
V1__initial_schema.sql
V2__add_sample_data.sql
```

## テストスクリプト

PgTap を使用したテストスクリプトです。

- test_schema.sql: スキーマ構造のテスト
- test_data.sql: データ整合性のテスト

## データベース接続情報

- ホスト: localhost
- ポート: 5432
- データベース: sampledb
- ユーザー名: postgres
- パスワード: postgres

アプリケーション用ユーザー:

- ユーザー名: app_user
- パスワード: app_password

## トラブルシューティング

### Docker コンテナが起動しない場合

```bash
docker logs postgres_db
```

でログを確認してください。

### マイグレーションに失敗する場合

Flyway のエラーメッセージを確認し、SQL スクリプトの構文や参照整合性を確認してください。

```bash
docker exec -it postgres_db flyway info
```

### テストに失敗する場合

テストスクリプトの期待値と実際のデータベース状態を確認してください。

```bash
docker exec -it postgres_db psql -U postgres -d sampledb
```
