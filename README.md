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
### 補足
1.  `Dockerfile` ・`docker-compose.yaml`・ `poetry.toml`は準備しておく
2.  poetryコマンドを任意に実行して`poetry.lock`は準備しておく

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