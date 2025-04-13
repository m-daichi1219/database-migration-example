FROM postgres:14

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    postgresql-contrib \
    make \
    gcc \
    libpq-dev \
    postgresql-server-dev-14 \
    git \
    && rm -rf /var/lib/apt/lists/*

# PgTapのインストール
RUN git clone https://github.com/theory/pgtap.git \
    && cd pgtap \
    && make \
    && make install \
    && cd .. \
    && rm -rf pgtap

# Flywayのインストール
ENV FLYWAY_VERSION=9.8.1
RUN mkdir -p /opt/flyway \
    && curl -L https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz -o flyway-commandline.tar.gz \
    && tar -xzf flyway-commandline.tar.gz --strip-components=1 -C /opt/flyway \
    && rm flyway-commandline.tar.gz \
    && ln -s /opt/flyway/flyway /usr/local/bin/flyway

# 環境変数の設定
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=sampledb

# 初期化スクリプトを実行
COPY ./init-db.sh /docker-entrypoint-initdb.d/

EXPOSE 5432 