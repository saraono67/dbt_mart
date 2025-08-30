FROM ghcr.io/dbt-labs/dbt-bigquery:1.9.0
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates jq curl&& \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /work/

ARG POETRY_VERSION=1.6.1
ENV POETRY_HOME=/work/poetry\
    POETRY_VERSION="${POETRY_VERSION}"

RUN curl -sSL https://install.python-poetry.org | python && \
    cd /usr/local/bin && \
    ln -s /work/poetry/bin/poetry && \
    poetry --version && \
    poetry config virtualenvs.create true && \
    poetry config virtualenvs.in-project true

#pyproject.toml poetry.lockを参照する
COPY pyproject.toml poetry.lock ./

RUN poetry install --no-root

#dbtにprofiles.ymlの場所を教える（elementaryの使用時に必要）
ENV DBT_PROFILES_DIR /work/dbt
#ベースイメージで'dbt'というentrypointが設定されているため、無効化する
ENTRYPOINT []