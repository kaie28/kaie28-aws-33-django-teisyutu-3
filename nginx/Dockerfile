#Nginx部屋の組み立て説明書(設計図)

#1, 脆弱性とroot権限の危険性を排除した、非privilegedの安定版（1.25）を採用
FROM nginxinc/nginx-unprivileged:1.25-alpine

#2, 一時的にroot権限で、システム初期設定とディレクトリ構築を行う
USER root

#3，OSのパッケージを最新に更新し、既知の脆弱性を修正（本番必須）
RUN apk update && apk upgrade --no-cache

#4,ログおよびキャッシュ用ディレクトリの作成と権限を一括変更
RUN mkdir -p /var/log/nginx /var/cache/nginx /usr/src/app/static /usr/src/app/media && chown -R nginx:nginx /var/log/nginx /var/cache/nginx /usr/src/app

#5 既存の不要なデフォルト設定を削除し、1枚目の設計図（default.conf）を配置
RUN rm -f /etc/nginx/conf.d/default.conf
COPY default.conf /etc/nginx/conf.d/default.conf
RUN chown nginx:nginx /etc/nginx/conf.d/default.conf

#6,非rootユーザーがプロセス（PID）を管理できるよう、書き込み権限のある場所に設定変更
RUN sed -i 's|/var/run/nginx.pid|/tmp/nginx.pid|g' /etc/nginx/nginx.conf

#7,一般ユーザー（nginx）に権限を戻して,実行（セキュリティの担保）
USER nginx

#8, 静的ファイル用(css)の領域を,外部（Volume）に公開する宣言
VOLUME ["/usr/src/app/static", "/usr/src/app/media"]

#9,コンテナ起動時のデフォルト命令
CMD ["nginx", "-g", "daemon off;"]
