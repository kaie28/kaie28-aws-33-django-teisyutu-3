# Nginxの部屋の組み立て説明書

#1,新しい＆圧倒的に軽い(AWSの容量を圧迫せずに爆速で動く)
FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    gcc \                           #gcc や libpq-devをインストールして,本番環境のエラーを未然に防ぐ
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*  #部屋をきれいに保つ

WORKDIR /app

# 1. まず最初に材料を部屋に持ってくる！
COPY requirements.txt .

# 2. 持ってきた材料を使ってインストールする！
RUN pip install --no-cache-dir -r requirements.txt

# 3. 本番用の起動ツールを入れる！
RUN pip install --no-cache-dir gunicorn

# 4. 最後にDjangoのプログラムたちを全部流し込む！（※別件だが・・2枚目の設計図にも繋がる）
COPY . .

