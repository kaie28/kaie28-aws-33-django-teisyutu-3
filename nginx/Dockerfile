#【Nginx部屋の組み立て説明書(設計図)】

#1, 【Nginxの製品】　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　#1 脆弱性とroot権限の危険性を排除した、非privilegedの安定版（1.25）を採用
FROM nginxinc/nginx-unprivileged:1.25-alpine


#2, 【初期設定時のroot権限】　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　#2 一時的にroot権限で、システム初期設定とディレクトリ構築を行う
USER root


#3，【OSのパッケージを最新更新】　　　　　　　　　　　　　　　　　　　　　　　　　　　　#3 OSのパッケージを最新に更新し、既知の脆弱性を修正（本番必須）
RUN apk update && apk upgrade --no-cache


#4,【ディレクトリ作成と権限】　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　#4 ログおよびキャッシュ用ディレクトリの作成と権限を一括変更
RUN mkdir -p /var/log/nginx /var/cache/nginx /usr/src/app/static /usr/src/app/media && chown -R nginx:nginx /var/log/nginx /var/cache/nginx /usr/src/app


#5 【デフォルトのNginx案内図から自作案内図（default.conf）へと変更 / また管理者を一般ユーザー（nginx）にする】
RUN rm -f /etc/nginx/conf.d/default.conf
COPY default.conf /etc/nginx/conf.d/default.conf
RUN chown nginx:nginx /etc/nginx/conf.d/default.conf


#6,【Nginxが起動中に使う「自分のIDメモ（PIDファイル）」の★置き場所を、安全な一時フォルダ（/tmp）へ移動する】
RUN sed -i 's|/var/run/nginx.pid|/tmp/nginx.pid|g' /etc/nginx/nginx.conf


#7,【これ以降のすべての命令やWEBサーバーの起動を、最高権限（root）から★一般ユーザー（nginx）に切り替える(※安全のため)】
USER nginx


#8, Djangoが作成した（CSS）や画像の領域を,共有の荷物置き場（Volume）に公開する宣言。
VOLUME ["/usr/src/app/static", "/usr/src/app/media"]


#9,Dockerコンテナ起動時に、まずNginxが最前線で動けという命令
CMD ["nginx", "-g", "daemon off;"]
