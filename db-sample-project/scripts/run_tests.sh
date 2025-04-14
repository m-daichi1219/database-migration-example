#!/bin/bash
set -e

# 色の設定
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# テスト対象ファイル
TEST_FILES=("/tests/test_schema.sql" "/tests/test_data.sql" "/tests/test_logic.sql")

echo -e "${YELLOW}PgTapテストを実行します...${NC}"

ALL_TESTS_PASSED=true

for test_file in "${TEST_FILES[@]}"; do
    echo -e "\n${YELLOW}テストファイルを実行中: ${test_file}${NC}"
    docker exec -it postgres_db pg_prove -U postgres -d sampledb "${test_file}"

    if [ $? -ne 0 ]; then
        echo -e "${RED}テスト失敗: ${test_file}${NC}"
        ALL_TESTS_PASSED=false
    else
        echo -e "${GREEN}テスト成功: ${test_file}${NC}"
    fi
done

if [ "${ALL_TESTS_PASSED}" = true ]; then
    echo -e "\n${GREEN}すべてのテストが正常に完了しました。${NC}"
    exit 0
else
    echo -e "\n${RED}一部のテストが失敗しました。${NC}"
    exit 1
fi 