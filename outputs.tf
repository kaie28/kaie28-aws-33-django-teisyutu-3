# 画面出力の定義設定

#1　EC2のIPアドレス（ネット上の住所）を、作業画面（ターミナル）に自動で表示。
output "public_ip" {
  value       = aws_instance.kaie28.public_ip
  description = "EC2のパブリックIPアドレスです"
}


#2 EC2のIPアドレスを使って、Todoアプリにブラウザからアクセスするための接続先URL（http://〜/）を画面に自動で作って表示。
output "todo_app_url" {
  value       = "http://${aws_instance.kaie28.public_ip}/"
  description = "TodoアプリのURLです"
}


#3　Djangoで作った『管理画面』へ直接アクセスするため【※E2のURLを自動で作って画面に表示してくれる】
#デプロイ完了後にそのURLをコピーしてブラウザに貼り付ければ管理画面に行ける設定。

output "admin_url" {
  value       = "http://${aws_instance.kaie28.public_ip}/admin/"
  description = "Django管理画面のURLです"
}



#4 22番接続に使うためのカギ（秘密鍵）を画面に出力する設定。※【確認】main.tfファイルの#8-5 と同じ名前　
#.pemファイルキーの★自動版なのでコメントアウトで使用不可にする（★現在は手動での .pemファイルを使用中）　　　　#4、★自動版の.pemキーファイルは更新時にGitHab経由で秘密情報が流出する危険性がある。

#output "private_key" {　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　# SSH接続に必要なカギのデータそのものを画面に出せる。
#  value     = tls_private_key.ssm-key-kaie28.private_key_pem　　　　　　　　　　　　　　　　　　　　　　　# 本番・開発でも、必ず true にする。秘密情報を目隠し出来る。
#  sensitive = true　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
#}
