#【変数の定義(箱)】
# 設計図（main.tf）で使うための『専用のラベル付きの箱』を準備するファイル


# 1.tfvarsファイルからTerraformに、Djangoの★シークレットキーを安全に読み込んで受け入れる箱（覗き見防止）→ (main.tfファイルの#10)

variable "django_secret_key" {
  description = "Djangoのシークレットキー（中身はtfvarsに書く）"
  type        = string
  sensitive   = true 
}


# 2. Djangoデバッグ設定 → (main.tfファイルの#10)
#本番環境でFalse（開発時で True設定 ）　　★例えば、本番環境でエラー時の簡素的な表示(404番など)を入れておく箱

variable "django_debug" {
  description = "デバッグモードのON/OFF"
  type        = string
  default     = "False"
}


# 3. セキュリティグループ【★例えば、自分のみ(自分のPCのネット上住所=MyIP)がEC2に繋がるための箱】→ (outputs.tfの#4で秘密情報を暗号化して、main.tfファイルの#6へ渡す)

# 自分用【裏口（22番）」の許可リスト　を入れる箱】
variable "my_ip" {
  description = "管理者のパブリックIP"
  type        = string
}


#4, 世界全員がWebサイトにアクセスできるための箱】 → (main.tfファイルの#6)
variable "allow_all" {
  description = "全員に公開するためのCIDR"
  type        = string
  default     = "0.0.0.0/0"
}


# 5. .pubファイル(EC２に設置する本物の鍵穴ファイルの場所(path)の住所を覚えさせる箱。
#【自動のSSH鍵穴】使用禁止にした。(GitHubのpushで秘密情報が流出される危険性があるため)。【★現在は、手動SSHの「鍵穴」(安全かつ使いまわせるので)に変更】

# variable "public_key_path" {
#  description = "手元の鍵穴（.pub）がある場所"
#  type        = string
#  default     = "C:/Users/GuestUser/.ssh/my-ssh-key.pub"
# }


# 6. SSM(金庫)利用時に、EC2の許可証(IAM＝バッチ)を入れる箱
# main.tf を直接いじらず、安全に設定値を変えるための箱。【★tfvars（本物の秘密情報） ➔ variables.tf（ただの箱） ➔ main.tf（使う場所）へ】
#【nameについて】variables.tfにある【iam_role_name】の名前　➔  main.tfの#7 の【${var.iam_role_name}-v3】と【aws_iam_role.ssm_role.name　iam_role_name】でnameのとこへ。

variable "iam_role_name" {
  description = "SSM用のIAMロール名"
  type        = string
  default     = "todo-ssm-role"
}

