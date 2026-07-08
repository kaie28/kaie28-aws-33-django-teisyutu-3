
## Djangoで作ったアプリ（内装）」を「外の世界（WEBサーバー）」と繋ぐための『★仲介(翻訳)の仕組み』


"""

# 1、todoproject というプロジェクトのための、WSGI（ウェブサーバーと繋ぐための世界共通ルール）の設定ファイル
WSGI config for todoproject project.


# 2，application という名前の変数（窓口）。
#(つまり、application っていう受付窓口を作っておいたから、通信が来たらここを叩いてね！)と伝えている。
It exposes the WSGI callable as a module-level variable named ``application``.


# 3,このファイルについてもっと詳しく知りたければ、Django公式のこのURL（マニュアル）を見に行ってね」というただの参考リンク。
For more information on this file, see
https://docs.djangoproject.com/en/6.0/howto/deployment/wsgi/
"""

# 4, osモジュールを取り込む。
#(osモジュールとは、パソコンのシステム（OS）の機能や 環境変数をいじるためのPythonの道具の意味）
import os

# 5-1　【準備】外部（Webサーバー）からのデータを、get_wsgi_application() という★「翻訳プログラム」で翻訳し、Djangoの内部へと引き渡す準備をする。
from django.core.wsgi import get_wsgi_application

# 5-2　このアプリの取扱説明書（設定ファイル）は settings.py だよ」 とシステムに教えている。
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'todoproject.settings')

# 5-3　【実行】get_wsgi_application() という★「翻訳プログラム」を実際に起動させて、外部からのデータを初めに受け取る「application」という名前の受付窓口（変数）を完成させる。
application = get_wsgi_application()
