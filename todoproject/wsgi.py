
## Django（内装）と外の世界（WEBサーバー）と繋ぐための『★仲介(翻訳)の仕組み』


"""

# 1、WSGI（ウェブサーバーと繋ぐためのルール）の設定ファイル               　　　　　　　　　　　　　#1　ファイル全体がWEBサーバー（Gunicorn）とDjangoを繋ぐための「本番環境用の接続マニュアル」であるという★宣言。
WSGI config for todoproject project.　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　


# 2，application 名前の変数（窓口）　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　#2 WEBサーバー側に対し、このapplication(変数受付窓口)が、外部からの通信を「一番最初に受け取る本番モードの総合受付窓口だよ」と★伝えている。
It exposes the WSGI callable as a module-level variable named ``application``.　　　　　　　　　#なので、まずこの「application」窓口をノックしてね。


# 3, 参考リンク                                                                               #3 Django公式のこのURL（マニュアル）を見に行ってね」という参考リンク。
For more information on this file, see
https://docs.djangoproject.com/en/6.0/howto/deployment/wsgi/
"""

# 4, osモジュールを取り込む。
import os

# 5-1　【準備】　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　 #5-1 本番モードのWEBサーバーと繋ぐための翻訳窓口プログラム（WSGI）の「★部品」を呼ぶ。
from django.core.wsgi import get_wsgi_application　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
# 5-2　【伝達】　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　 #5-2  窓口を開く前に、このアプリの全ルールが書かれた「todoproject.settingsの★場所」をシステムに教える。 
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'todoproject.settings')                         

# 5-3　【実行】　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　 #5-3 【get_wsgi_application() ＝翻訳プログラム】　【application　＝名前の本番モード用受付窓口（変数）】
application = get_wsgi_application)　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　#5-2で教えたルール（settings）を基に、外部データを受け取る「本番モードのapplication（受付窓口）を★正式に起動」する。





