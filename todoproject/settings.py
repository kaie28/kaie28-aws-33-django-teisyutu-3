
import os　                                                     # 1★
import environ                                                  # 1★django-environライブラリを使うので。
from pathlib import Path                                        # 1★

from pathlib import Path
from dotenv import load_dotenv
load_dotenv()

BASE_DIR = Path(__file__).resolve().parent.parent


##★1【一連の流れ】本番デプロイでのIPなど変数化の仕組み

# 1-1 【実施初期での指示】                                         #1-1 settings.pyファイルが、「一時的にすり替わった本物の機密情報」の.envファイル内容を探して読み込む設定 （★★このBASE_DIRの下に、下記2行を追記）※コードの配置・順序が大事
env = environ.Env() 
environ.Env.read_env(os.path.join(BASE_DIR, '.env')) 


# 1-2 【具体的実施の指示】　　　　　　　　　　　　　　　　　　　　　　　#1-2 settings.pyファイルが、「一時的な本物の情報」が入ってる.envファイル(シークレットキーやIP）をコピー。
SECRET_KEY = env('SECRET_KEY', default= '')　　
MY_IP = env('MY_IP', default='127.0.0.1') 　　　　


# 1-3 【DEBUGでの指示】　　　　　　　　　　　　　　　　　　　　　　　　 #1-3 唯一このDEBUGだけはenvファイルから「★直接本物の情報」コピーして組み込む指示。
DEBUG = env.bool('DEBUG', default=False)　　　


# 1-4 【コピーした「本物の機密情報」を保管する箱】

ALLOWED_HOSTS = [　　　　　　　　　　　　　　　　　　　　　　　　　　　# 1-4
    MY_IP,               　　　　　　　　　　　　　　　　　　　　　　　# コピーした本物【本番モード用】IPなどを保管する箱」
    'localhost',         　　　　　　　　　　　　　　　　　　　　　　　# ←内部(Django)の専用の名前(★住所名を示す)　　　
    '127.0.0.1',　　　　　　　　　　　　　　　　　　　　　　　　　　　　# ←内部(Django)の★住所番号(世界共通の【開発モード】127.0.0.1)で通信検証用。　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
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



#★ 2  WSGIで仲介（翻訳）させるための設定。　　　　　　　　　　　　　　　#2,Django玄関窓口から、Djangon内への仲介

WSGI_APPLICATION = 'todoproject.wsgi:application'


#★ 3 文字データ等の安全保管庫の住所を設定。　　　　　　　　　　　　　　　#3、Docker(コンテナ)が再構築・破壊されても、ToDoアプリ(お客さんの更新時など)の文字データ等が消えないようにするため

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
