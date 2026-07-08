
## Django（内装）と外の世界（WEBサーバー）と繋ぐための『★仲介(翻訳)の仕組み』


"""

# 1、todoproject というプロジェクトのための、WSGI（ウェブサーバーと繋ぐための世界共通ルール）の設定ファイル
WSGI config for todoproject project.


# 2，application という名前の変数（窓口）→(application っていう受付窓口を作っておいたから、通信が来たらここを叩いてね！)と伝えている。
It exposes the WSGI callable as a module-level variable named ``application``.


# 3,Django公式のこのURL（マニュアル）を見に行ってね」という参考リンク。
For more information on this file, see
https://docs.djangoproject.com/en/6.0/howto/deployment/wsgi/
"""

# 4, osモジュールを取り込む。
import os

# 5-1　【準備】データを、get_wsgi_application() という「翻訳プログラム」で翻訳し、Djangoの内部へと送る準備。
from django.core.wsgi import get_wsgi_application

# 5-2　このアプリの取扱説明書（設定ファイル）は settings.py だよ」 とシステムに教えている。
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'todoproject.settings')

# 5-3　【実行】get_wsgi_application() という「翻訳プログラム」で、外部からのデータを初めに受け取る「application」という名前の受付窓口（変数）。
application = get_wsgi_application()
