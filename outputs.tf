# 画面出力の定義設定

#1
output "public_ip" {
  value       = aws_instance.kaie28.public_ip
  description = "EC2のパブリックIPアドレスです"
}

#2
output "todo_app_url" {
  value       = "http://${aws_instance.kaie28.public_ip}/"
  description = "TodoアプリのURLです"
}

#3
output "admin_url" {
  value       = "http://${aws_instance.kaie28.public_ip}/admin/"
  description = "Django管理画面のURLです"
}

#4 22番接続に使うためのカギ（秘密鍵）を画面に出力する設定
 #【●確認】main.tfファイルの#8-5 と同じ名前か？確認(→　●sshキーについて)



