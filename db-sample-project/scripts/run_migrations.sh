#!/bin/bash
set -e

# 色の設定
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Flyway マイグレーションを実行します...${NC}"

# コンテナ内でFlywayを実行
docker exec -it postgres_db flyway \
  -url=jdbc:postgresql://localhost:5432/sampledb \
  -user=postgres \
  -password=postgres \
  -locations=filesystem:/flyway/sql \
  migrate

# 実行結果の確認
if [ $? -eq 0 ]; then
  echo -e "${GREEN}マイグレーションが正常に完了しました。${NC}"
else
  echo -e "${RED}マイグレーションに失敗しました。${NC}"
  exit 1
fi

# スキーマ情報を表示
echo -e "${YELLOW}マイグレーション履歴:${NC}"
docker exec -it postgres_db psql -U postgres -d sampledb -c "SELECT * FROM flyway_schema_history ORDER BY installed_rank;" 