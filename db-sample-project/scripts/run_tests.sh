#!/bin/bash
set -e

# 色の設定
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}PgTapテストを実行します...${NC}"

# スキーマテストの実行
echo -e "${YELLOW}スキーマテストを実行しています...${NC}"
docker exec -it postgres_db pg_prove -U postgres -d sampledb /tests/test_schema.sql

# 実行結果の確認
if [ $? -eq 0 ]; then
  echo -e "${GREEN}スキーマテストが正常に完了しました。${NC}"
else
  echo -e "${RED}スキーマテストに失敗しました。${NC}"
  exit 1
fi

# データテストの実行
echo -e "${YELLOW}データテストを実行しています...${NC}"
docker exec -it postgres_db pg_prove -U postgres -d sampledb /tests/test_data.sql

# 実行結果の確認
if [ $? -eq 0 ]; then
  echo -e "${GREEN}データテストが正常に完了しました。${NC}"
else
  echo -e "${RED}データテストに失敗しました。${NC}"
  exit 1
fi

echo -e "${GREEN}すべてのテストが正常に完了しました。${NC}" 