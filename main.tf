#インフラの設計図（リソース設定)

# ★1【プロバイダー設定、ami最新の検索】 

# 1-1,プロバイダー設定
provider "aws" {
  region = "ap-northeast-1"  　　　       　　  　　　　　　　　　　　　　      　　　　　　　　　　　　　　    　# 1-1　東京リージョン
}


# 1-2, amiの最新を常に自動で探す。
data "aws_ami" "recent_amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]             　　　　　　　　　　　　　     　　　　　　　　　　　　　　    　# 1-2 「al2023-ami-」で始まって「x86_64」で終わるものを探す。
  }    
}


# ★2【自動でSSH作成(★現在は全ての機能中止)】→ main.tf#8へ(EC2にその部品を取り付ける)】

# 2-1 【Terraform(工場)が、自動でpem（カギ)と.pub(鍵穴)を作る。】　　　　　　　　　　　　　　　　　　　　　　　　　　#2-1は機能中止にした。【自動でゼロから「SSHの鍵や鍵穴」を製造】
#resource "tls_private_key" "keygen" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}


#2-2 自動で　pub「鍵穴」【(public_key)＝★公開鍵　→main.tf#8へ）をEC2に取り付ける】                         　　　#2-2は機能中止にした。【自動でSSHの「鍵穴」をAWSに設置】
#resource "aws_key_pair" "ssm-key-kaie28" {
#  key_name   = "my-ssh-key-v4"
#  public_key = tls_private_key.keygen.public_key_openssh
#}


# 2-3 自動で.pem「鍵」【(private_key）＝★秘密鍵】を裏で保管する。　　　　　　　　　　　　　　　　　　　　　　　　　　#2-3は機能中止にした。【自動でSSHの「鍵」を目隠しながら画面表示させる】
#output "private_key" {
# value     = tls_private_key.keygen.private_key_pem
#  sensitive = true　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　        #★開発でも本番でも「true 」設定は必須（秘密鍵が目隠しになるため)※.tfstateファイルに本物の秘密鍵を保管する。
#}　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　

# ★3. 【ネットワーク (VPC＝セキュリティ無関係の、ただの大箱)】
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "todo-vpc" }
}


# ★4. 【インターネット接続 (IGW)】※VPCの外枠にいて、誰でも通れるフリーな自動ドア。
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "todo-igw" }
}


# ★5.【サブネット～ルートテーブル】

# 5-1,パブリックサブネット(ネットと直通してる区画/道路）※2つのサーバー【WEB(Nginx)＋Djangoの区画範囲内】　　　　　　　#5-1【補足】逆にネットに通らないのはプライべートサブネット
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id 
  cidr_block              = "10.0.1.0/24"   
  map_public_ip_on_launch = true                                          
  availability_zone       = "ap-northeast-1c"       　　　　　   　　　　　　　　　　　　　　　　　　　　　　　　　　　# 東京リージョン/SSMが確実に即時起動するcゾーン
  tags                    = { Name = "todo-subnet" }
}


# 5-2. ルートテーブル (サブネットの案内板/道案内。※矢印のこと)
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# 5-3, サブネット（区画/道路）と、ルートテーブル（案内板）を結ぶ。
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}



# ★6.【Securty Group】

#6-1 空の外枠（盾の名前ssh-only-sg-v3）を、VPC(aws_vpc.main)中に設置。
resource "aws_security_group" "sg" {
  name   = "ssh-only-sg-v3"
  vpc_id = aws_vpc.main.id 


#6-2 自分のみ専用。外からサーバーへのみ(※EC2にSSH22番のみ通す設定)　　　　　　　　　　  #6-2  自分のみ専用
  ingress {                                                                          # 【MyIPでの流れ】tfvars（本物のIP）→　variables.tf(自分のPCのネット上住所=MyIP)のみをただの空箱に入れて　→　main.tfのEC2に繋げる。
    from_port   = 22                                                                 #【手動SSHでの流れ】tfvars（本物の.pemキー） ➔ variables.tf(.pemキーのただの入れ物) ➔ main.tfの#6へ 　で鍵の名前を渡す。
    to_port     = 22                                                                 #　※【補足】自動SSHは中止した(★更新などで、GitHab経由にて秘密情報が流出する危険性があるため。★outputs.tf「鍵」#4と、★variables.tf「鍵穴」#5は全て中止済み)
    cidr_blocks = ["${var.my_ip}/32"] 　　　　　　　　　　　　　　　　　　　　　　　　　
  }　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　

  #6-3 客に全員専用。外からサーバーへのみ（80番表口）　# 全員に公開
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allow_all] 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　# 6-3 客さん全員を受け入れる。
  }


  #6-4 制限なしで外部へ公開専用。EC2サーバーから外へ出る。
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　# 6-4 制限なしで100%許可にて外部公開
  }
} 


# ★7. 【SSMの権限】～警察官（EC2）がバッジ（許可証）をもらうまでのステップ～

#7-1,【(SSM身分証明書の作成)】※空のSSM身分許可証を発行
resource "aws_iam_role" "ssm_role" {                                                  #7-1
  name = "${var.iam_role_name}-v3"       　　　　　　　　　　　　　　　　　　　　　　 　　　 # 空の身分証（IAMロール）の名前({var.iam_role_name}-v3)。　※variables.tfファイルの#6のname　へ
  assume_role_policy = jsonencode({                                
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　# AssumeRoleは、EC2が身分証明書をもつことを許可する
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }                                 　　　# Principalは、EC2が使うための身分証だと指定する
    }]
  })
}


#7-2,【(EC2にSSM許可を与えるまで)】※EC2がSSM権限も持てるようにする                         #7-2
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name　　　　　　　　　　　　　　　　　　　　　　　　　　　# role は、この身分証（aws_iam_role.ssm_role）を指定するの意味
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"   　　　　　　　　　　# policy (ルール本)。 policy_arnSSM (ルール本の住所) 。　※身分証（ロール）に合体させる
}


# 7-3.【(SSM権限バッジ付きのホルダ作成まで)】※EC2にSSM権限バッジをつける
resource "aws_iam_instance_profile" "ssm_profile" {                                     #7-3
  name = "todo-ssm-profile-v3" 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　# todo-ssm-profile-v3という名前の身分証を入れる袋(instance_profile)
  role = aws_iam_role.ssm_role.name                                                   　　　# roleは、身分証そのもの（ロール＝ssm_role）
}


# ★8. 【EC2インスタンス 】

# 8-1  OSについて                                                                         # 8-1
resource "aws_instance" "kaie28" {　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　 # Terraform内のみで使用するEC2のあだ名(識別用)に　kaie28　と名付ける。
  ami                  = data.aws_ami.recent_amazon_linux_2023.id　　　　　　　　　　　　　　 # サーバーの中に入れるOSデータ(Amazon Linux 2023)
  instance_type        = "t3.micro"   　　　　　　　　　　　　　　　　　　　　　　　　　　　　　 # t3.micro　は、CPUやメモリなどの「マシンのスペック（サイズ）(無料版) 


# 8-2 パブリックIP(変動するので)を強制的に割り当てる　　　　　　　　　　　　　　　　　　　　　   # 8-2 ★VPCは広い部屋、サブネットはその中の狭い区画、パブリックIPはサブネットのみ使用可の住所。※SSMはパブリックIP無関係に利用可。
  associate_public_ip_address = true　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　  # 本番モードでは false【プライベートサブネットでパブリックIPを完全に隠す(※安全対策)】、★代わりにSSMで命令＋Dockerでデプロイ。
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　# 開発モードでは true 【パブリックサブネット経由でPCから直接繋げる】　★EC2のIPアドレスを使ってブラウザから直接Djangoを画面に表示。


# 8-3 EC2をどのサブネットに配置させるかの指定　　　　　　　　　　　　　　　　　　　　　　　　　　# 8-3
  subnet_id            = aws_subnet.public.id　　　　　　　　　　　　　　　　　　　　　　　　　　# 本番モード（DockerやSSMの使用でデプロイなど）では、aws_subnet.private.id（プライベートサブネット）でEC2を守る。
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　# 開発モードでは、aws_subnet.public.id（パブリックサブネット）でEC2を使用する。



#8-4 EC2にSSM許可証(ssm_profileという名前の社員証)をつける、AWSサーバーと繋げる。　　　　　　　　　　　　　　   　　　　　　　　　　　　　　　　　　　　　　　　
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name                        # 8-4 本番モード（false）時に、EC2がSSM経由でDockerを動かせるようにする。



#8-5 EC2（kaie28）を、セキュリティグループで絞る (※許可した通信以外をすべて弾く)　　　          # 8-5　許可したもの以外はEC2に入れない設定にする。　　　　　　　　　　　　　　　　　
  vpc_security_group_ids = [aws_security_group.sg.id]


#8-6 手動の【SSH鍵穴(ssm-key-kaie28)】を、EC2（kaie28）に取り付ける。　　　　　　　　　　　     #8-6  もしも、SSMが壊れた際の【手動SSH】を準備。　★EC2に「手動の鍵穴」を設置する（ ※.pemファイル「手動の鍵」は自分で持つ）。
resource "aws_instance" "kaie28" {
key_name = "ssm-key-kaie28"


#9、TerraformがAMI(=os)のズレを無視できる（★EC2再作成の防止）                                              
  　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
lifecycle {
    ignore_changes = [
      ami, 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　#9、★4つの項目
      subnet_id,
      vpc_security_group_ids,
      associate_public_ip_address
    ]
  }

  tags = { Name = "kaie28" }
}


# 10. 本番デプロイの際、SSM(外部安全な金庫)に機密情報(シークレットキーや通行証、デバック設定など)を保管。

# 10-1 シークレットキー
resource "aws_ssm_parameter" "django_secret_key" { 
  name  = "/django-v3/SECRET_KEY"
  type  = "SecureString" 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　# SecureString 暗号化ありの保存する設定
  value = var.django_secret_key
}

# 10-2 デバッグ
resource "aws_ssm_parameter" "django_debug" {
  name  = "/django-v3/DEBUG"      
  type  = "String" 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　# String 暗号化なしの通常文字列で保存する設定
  value = var.django_debug
}




