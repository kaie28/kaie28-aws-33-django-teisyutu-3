　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　# 1.env連携に必要な「3大道具(os, environ, Path)」を最初にすべて揃える（※下準備（拡張機能)）
import os　                                                     #★OS（土台 / ファイルパスを扱う）
import environ                                                  #★django-environライブラリ(.envを読み込む力)
from pathlib import Path                                        #★Path （ファイルパスを扱う）

from pathlib import Path
from dotenv import load_dotenv
load_dotenv()

BASE_DIR = Path(__file__).resolve().parent.parent　　　　　　　　#　👈【BASE_DIR 】


##★2【一連の流れ】本番デプロイでのIPなど変数化の仕組み    　　　　　#2  （★必ず【BASE_DIR の下】に追記）※コードの配置・順序が大事       

# 2-1 【実施初期での指示】                                         #2-1 settings.pyファイルが、「一時的にすり替わった本物の機密情報」の.envファイル内容を探して読み込む設定 
env = environ.Env() 　　　　　　　　　　　　　　　　　　　　　　　　　　#また、これから.envを読み込むための「準備と道作り」をしている初期指示
environ.Env.read_env(os.path.join(BASE_DIR, '.env')) 


# 2-2 【具体的実施の指示】　　　　　　　　　　　　　　　　　　　　　　　#2-2 settings.pyファイルが、「一時的な本物の情報」が入ってる.envファイル(シークレットキーやIP）をコピーする。
SECRET_KEY = env('SECRET_KEY', default= '')　　　　　　　　　　　　　　#万が一、空っぽだった場合の「身代わり（初期値）」も準備する。
MY_IP = env('MY_IP', default='127.0.0.1') 　　　　


# 2-3 【DEBUGでの指示】　　　　　　　　　　　　　　　　　　　　　　　　 #2-3 唯一このDEBUGだけは.envファイルに記している「★直接本物の情報」をコピーして、【文字からプログラム用(True/False)へ自動変換】して組み込む指示。
DEBUG = env.bool('DEBUG', default=False)　　　


# 2-4 【コピーした「本物の機密情報」を保管する箱】

ALLOWED_HOSTS = [　　　　　　　　　　　　　　　　　　　　　　　　　　　# 2-4
    MY_IP,               　　　　　　　　　　　　　　　　　　　　　　　# コピーした本物【本番モード用】IPなどを保管する箱」
    'localhost',         　　　　　　　　　　　　　　　　　　　　　　　# ←内部(Django)の専用の名前(★住所名を示す)　　　
    '127.0.0.1',　　　　　　　　　　　　　　　　　　　　　　　　　　　　# ←内部(Django)の★住所番号(世界共通の【開発モード】127.0.0.1)で通信検証のテスト用。　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
]


INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'todo',

]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'todoproject.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages', 

                ],  #context_processors の閉じカッコ
        },  # oPTIONS の閉じカッコ
    },  # 辞書データの閉じカッコ
]



#★ 3  WSGIで仲介（翻訳）させるための設定。　　　　　　　　　　　　　　　#3,Django玄関窓口から、Djangon内への仲介

WSGI_APPLICATION = 'todoproject.wsgi:application'


#★ 4 文字データ等の安全保管庫の住所を設定。　　　　　　　　　　　　　　　#4、Docker(コンテナ)が再構築・破壊されても、ToDoアプリ(お客さんの更新時など)の文字データ等が消えないようにするため

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',　　　　　　
        'NAME': BASE_DIR / 'db_data' / 'db.sqlite3',    　　　　　　　#Dockerの標準機能 「ボリュームマウント（Volume Mount）を使用する(文字が消えない設定)
　　　　　
 
    }
}


AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

LANGUAGE_CODE = 'ja'

TIME_ZONE = 'Asia/Tokyo'

USE_I18N = True

USE_TZ = True

STATIC_URL = 'static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
