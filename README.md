# dbt_mart
-----

## 環境構築手順

### 1\. 事前準備

以下のツールを事前にインストールし、アカウントを登録しておく。

  - **BigQuery (BQ)** アカウント
  - **Git** アカウント
  - **Docker**
  - **VS Code**
  - **VS Code** 拡張機能: Dev Containers
  - **VS Code** と **Git** の連携、リポジトリの作成
      - [参考記事](https://qiita.com/yuto_h9m8/items/1d5867981c81a18bc1db)


また、以下のファイルをプロジェクトのルートディレクトリに作成する。
-   `Dockerfile`（AWSのジョブ実行用のdockerコンテナ）
-   `Dockerfile.local`(開発用のdockerコンテナ)
-   `docker-compose.yaml`
-   `poetry.toml`
-   `poetry.lock` (poetryコマンドを任意に実行して作成)

以下のファイルを./dbt/binに作成する
-   `run.sh`(AWSのジョブ実行時のコマンドを記載する)

-----

### 2\. ツールインストール (Mac/zsh)

zshターミナルで以下のコマンドを実行し、必要なツールをインストールする。

#### Homebrew & Python

1.  **Homebrew** をインストールする。

    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    ```
2.  インストールを確認する。
    ```bash
    brew -v
    ```

2.  **Python** をインストールする。

    ```bash
    brew install python3
    ```

3.  `.zprofile` にパスを追加し、変更を反映させる。

    ```bash
    # .zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH=/opt/homebrew/bin/python3.13/libexec/bin:$PATH

    # 変更を反映
    source ~/.zprofile
    ```

#### Poetry

1.  **Poetry** をインストールする。

    ```bash
    curl -sSL https://install.python-poetry.org | python3 -
    ```

2.  `.zshrc` にパスを追加し、変更を反映させる。

    ```bash
    # .zshrc
    export PATH="/Users/onosara/Library/Application Support/pypoetry/venv/bin:$PATH"

    # 変更を反映
    source ~/.zshrc
    ```

#### Google Cloud CLI (gcloud)

1.  gcloud CLI をインストールする。
    [公式ドキュメント](https://cloud.google.com/sdk/docs/install?hl=JA)を参照。

2.  `.zshrc` にパスを追加し、認証を行う。

    ```bash
    # .zshrc
    source '/Users/onosara/google-cloud-sdk/path.zsh.inc'

    # 認証
    gcloud auth application-default login
    ```

#### Docker Compose

1.  パッケージを更新する。

    ```bash
    sudo apt-get update
    ```

2.  **Docker Compose** プラグインをインストールする。

    ```bash
    sudo apt-get install docker-compose-plugin
    ```
3.  インストールを確認する。
    ```bash
    docker compose version
    ```
-----


### 3\. コンテナの起動とプロジェクト初期化

1.  VS Codeでプロジェクトを開く。コンテナを起動する。

    ```bash
    # Dockerfile・docker-compose.yamlがある階層で実行
    docker compose up -d
    ```
2.  Dev Containersでコンテナを起動する。

2.  コンテナ内でdbtプロジェクトを新規作成する。

    ```bash
    dbt init <プロジェクト名>
    ```

-----

### 補足: `.zshrc` ファイルの編集方法

`vi` を使った編集方法。

1.  `.zshrc` を開く

    ```bash
    vi ~/.zshrc
    ```

2.  `i` キーで編集モードに切り替え、内容を追記する。

3.  `ESC` キーで編集モードを終了する。

4.  `:w !sudo tee %` を入力して強制保存する。
-----

### 4. AWS Batch実行環境のセットアップ

#### 4.1. IAMロールの作成
AWSサービスが連携するために必要なIAMロールを作成する。
* **`AWSBatchServiceRole`**: AWS BatchサービスがAWSリソースを管理するために必要なロール。
* **`AmazonECSTaskExecutionRolePolicy`**: コンテナがECRやCloudWatchにアクセスするために必要なポリシー。`BatchEcsTaskExecutionRole`（任意の名前）というロールに付与する

#### 4.2. BigQuery認証キーとSecrets Managerの設定
dbtがBigQueryに接続するための認証情報を設定する。
1.  **BigQuery認証キーの取得**:
    * Google Cloudコンソールで「IAM と管理」→「サービス アカウント」に移動。
    * `dbt-runner`（任意の名前）を作成し、「BigQuery データ編集者」と「BigQuery ジョブユーザー」のロールを付与する。
    * 「キー」タブから、JSON形式の新しい鍵を生成し、ダウンロードする。
2.  **AWS Secrets Managerへの登録**:
    * AWS Secrets Managerで「その他のシークレット」タイプを選択し、新しいシークレットを作成する。
    * キーに`google_sa_key`（任意の名前）と入力し、値にダウンロードしたJSONファイルの中身を貼り付ける。
    * シークレットに`dbt/bigquery/service_account`（任意の名前）を付けて保存する。

#### 4.3. AWS Batchの設定
AWS Batchでジョブを実行するための環境を構築する。
1.  **ジョブ実行ロールの権限付与**:
    * Secrets Managerで、シークレットを取得するためのカスタムポリシー（`secretsmanager:GetSecretValue`アクションを許可）を新規作成する
    * `BatchEcsTaskExecutionRole`にアタッチする
2.  **コンピューティング環境の作成**:
    * コンピューティング環境設定
        * コンピューティング: Fargate
        * サービスロール：AWSBatchServiceRoleForBatch（デフォルト値）
    * インスタンス設定:
        * 最大vCPU：４（仮）
        * vCPUはdbtのコンテナ内で実行される前処理や後処理、および並列処理のスレッド数に影響する。dbtの設定で、threadsの数をvCPU数より多く設定しても、vCPUがボトルネックになり、パフォーマンスが向上しない場合がある

3.  **ジョブキューの作成**:
    * 作成したコンピューティング環境と紐づくジョブキューを作成する。
4.  **ジョブ定義の設定**:
    * **コンテナ設定**: ECRにプッシュしたDockerイメージのURIを入力する。
    * **コマンド - オプション**: **空欄。**　実際のコマンドはdbt/bin/run.shに記述するため
    * **シークレット**: Secrets Managerで作成したキーのARNを登録する。
        * **名前**: `GOOGLE_APPLICATION_CREDENTIALS`
        * **値**: Secrets ManagerのシークレットのARN
5.  **ジョブの作成**:
    * 作成したジョブ定義とジョブキューを指定してジョブを作成する。

-----

### 5. DockerイメージのビルドとECRへのプッシュ
dbtプロジェクトのDockerfileを使用してイメージをビルドし、ECRにプッシュする。
1. AWS CLIのインストール
    * [公式ドキュメント](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/getting-started-install.html)を参考にインストールする。
2.  ECRへの認証を行う。
    ```bash
    #aws ecr get-login-password --region <リージョン名> | docker login --username AWS --password-stdin <ユーザーID>.dkr.ecr.<リージョン名>.amazonaws.com
    aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 501235162149.dkr.ecr.ap-northeast-1.amazonaws.com
    ```
3. ECRのリポジトリを作成する.
    * リポジトリ名
        * 501235162149.dkr.ecr.ap-northeast-1.amazonaws.com/`dbt_work_dev_server(任意の名前)`

4.  イメージをビルドする。
    ```bash
    #docker build --platform linux/amd64 --provenance=false -t <docerイメージ名> .
    
    docker build --platform linux/amd64 --provenance=false -t dbt_work_dev .
    ```
5.  ECRリポジトリのタグを付ける。(タグ名=latest)
    ```bash
    #docker tag <docerイメージ名>:latest <ユーザーID>.dkr.ecr.<リージョン名> .amazonaws.com/<ECRリポジトリ名>:latest
    docker tag dbt_work_dev:latest 501235162149.dkr.ecr.ap-northeast-1.amazonaws.com/dbt_work_dev_server:latest
    ```
5.  イメージをECRにプッシュする。
    ```bash
    # docker push <ユーザーID>.dkr.ecr.<リージョン名>.amazonaws.com/<ECRリポジトリ名>:latest
    docker push 501235162149.dkr.ecr.ap-northeast-1.amazonaws.com/dbt_work_dev_server:latest
    ```
