#!/bin/bash
set -eux

# AWS Batchによって注入された環境変数から、サービスアカウントキーの値のみをjqコマンドで抽出
#環境変数にはAWS Secrets Managerに登録した、BQの認証キーを記載している
secret_json=$(echo "${GOOGLE_APPLICATION_CREDENTIALS}" | jq -r '.google_sa_key')

# 抽出したサービスアカウントキーを一時ファイルに保存
echo "${secret_json}" > /tmp/key.json

# 新しいパスを環境変数に設定する
export GOOGLE_APPLICATION_CREDENTIALS=/tmp/key.json

# dbtコマンドを実行
dbt deps
dbt run
dbt test

echo "dbt job finished successfully!"