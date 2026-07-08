#【変数の定義(箱)】
# 設計図（main.tf）」で使うための『専用のラベル付きの箱』を準備するファイル


# 1. Djangoのシークレットキーを入れる箱 → (main.tfファイルの#10)
# SSM(金庫)をあけるための、Djangoの本物の鍵を隠すための箱
# Terraformを実行したときに画面にパスワードが表示されないようになる（覗き見防止）

variable "django_secret_key" {
  description = "Djangoのシークレットキー（中身はtfvarsに書く）"
  type        = string
  sensitive   = true 
}


# 2. Djangoデバッグ設定（デフォルトはFalseで安全） → (main.tfファイルの#10)
# Djangoデバッグ設定は、SSM(金庫)に保管する。
# 今は本番モード（False）なので、エラー時の表示は簡素(404番など)にしますよという設定。を入れておく箱

variable "django_debug" {
  description = "デバッグモードのON/OFF"
  type        = string
  default     = "False"
}


# 3. セキュリティグループ情報を入れる箱 → (main.tfファイルの#6)

# 自分用【裏口（22番）」の許可リスト　を入れる箱】
variable "my_ip" {
  description = "管理者のパブリックIP"
  type        = string
}

# 全員用【表口(80番)+SSM調整の許可範囲を設定　を入れる箱】 → (main.tfファイルの#6)
variable "allow_all" {
  description = "全員に公開するためのCIDR"
  type        = string
  default     = "0.0.0.0/0"
}


# 4. .pubファイル(EC2に取り付けてる鍵穴)の場所=★手動で住所録を覚えさせておく箱。
#●自動にしたので不要なので、#4はコメントアウト済み。
# (.pub フィールド(鍵穴の場所)（パス）を定義して、Terraform に覚えさせる)
# (SSH(22番)キーはmain.tfファイルの#1)

# variable "public_key_path" {
#  description = "手元の鍵穴（.pub）がある場所"
#  type        = string
#  default     = "C:/Users/GuestUser/.ssh/my-ssh-key.pub"
# }


# 5. SSM(IAMロール＝SSM通行証の正式名)の一時的保管。
# variables.tfファイル(箱)がない場合、IPアドレスが変わるたび、main.tfファイル書き直す必要があるが。
# 変数化すれば、terraform.tfvarsファイル(秘密保管庫)から受け取り、直接main.tfファイルへ流せる(省略できる)。
# main.tfファイル　(の#7のnameのとこ)

variable "iam_role_name" {
  description = "SSM用のIAMロール名"
  type        = string
  default     = "todo-ssm-role"
}

