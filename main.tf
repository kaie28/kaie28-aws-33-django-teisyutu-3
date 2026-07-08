#インフラの設計図（リソース設定)

# 1. 

#1-A,プロバイダー設定
provider "aws" {
  region = "ap-northeast-1"  #←★東京リージョン
}

#1-B, amiを最新を自動で探せるようにする。
#名前の指定を確実にヒットする形に変更
data "aws_ami" "recent_amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"] 
  }    # ↑「al2023-ami-」で始まって「x86_64」で終わるものを探す
}

#1-C, (SSH22番の自分用) →#8へ(EC2にその部品を取り付ける)
#(Terraform（プログラム）がその場で全自動で鍵と鍵穴を同時に作る)

#.pem（カギ)ファイルを作る。
resource "tls_private_key" "keygen" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#.pub（鍵穴→#8へ）ファイルを作る。
resource "aws_key_pair" "ssm-key-kaie28" {
  key_name   = "my-ssh-key-v4"
  public_key = tls_private_key.keygen.public_key_openssh
}

#作った鍵を裏で保管する。
output "private_key" {
  value     = tls_private_key.keygen.private_key_pem
  sensitive = true
}


# 2. ネットワーク (VPC＝箱)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "todo-vpc" }
}

# 3. インターネット接続 (IGW)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "todo-igw" }
}

# 4. サブネット(区画/道路)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id 
  cidr_block              = "10.0.1.0/24"   
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"       #←★東京リージョン/SSMが確実に即時起動するcゾーン
  tags                    = { Name = "todo-subnet" }
}

# 5-1. ルートテーブル (サブネットの案内板/道案内)
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# 5-2, サブネット（区画/道路）と、ルートテーブル（案内板）を結びつける。
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

# 6. Securty Group (EC2サーバーを外枠から守る)
#(SSH22番とHTTP80番を、自分のIPからのみ許可)
resource "aws_security_group" "sg" {
  name   = "ssh-only-sg-v3"
  vpc_id = aws_vpc.main.id 

  #6-1 自分用で外からサーバーへ（22番裏口+80番内装Djangoへ）*設定
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"] # 変数(terraform.tfvarsファイルへ)
  }
  
  #6-2 お客さん用の外からサーバーへ（80番表口+SSM裏口）*設定
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allow_all] # 全員に公開
  }

  #6-3 EC2サーバーから外へ出る**ための設定
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
} 


# 7. SSM (ブラウザ接続,お客さん用) の権限設定
#～警察官（EC2）がバッジ（許可証）をもらうまで」のステップ～

#7-A,【(身分証明書の発行)】
resource "aws_iam_role" "ssm_role" {
  name = "${var.iam_role_name}-v3"       #←variables.tfファイルの#6のname
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}


#7-B,【(許可証を渡す)】
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"   #←SSM許可証
}

# 7-C.【(バッジを付けるためのホルダー)】
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "todo-ssm-profile-v3" 
  role = aws_iam_role.ssm_role.name
}


# 8. EC2インスタンス (Nginxのみ自動インストール)
# EC2インスタンス作成時に、このプロファイルを指定する
#(すると、サーバーが生まれた瞬間に、Webサーバーに代わり即戦力で動ける。)

resource "aws_instance" "kaie28" {
  ami                  = data.aws_ami.recent_amazon_linux_2023.id
  instance_type        = "t3.micro"    # OSタイプ 

  #8-1 パブリックIP(変動するので)を強制的に割り当てる
  associate_public_ip_address = true
  
  #8-2 EC2に#4のパブリックサブネットを所属させる
  subnet_id            = aws_subnet.public.id

  #8-3 SSM許可証をAWSサーバーとつなぐ
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name   
  

  #8-4 EC2サーバー（kaie28）の周りに、セキュリティグループのフェンスをガチッと取り囲むよう
  vpc_security_group_ids = [aws_security_group.sg.id]
  
  #8-5 EC2サーバー（kaie28）の外枠に、鍵穴（ssm-key-kaie28）を取り付ける。
  #.pem（22番カギ#8)ファイルは自分で持つ
  key_name = aws_key_pair.ssm-key-kaie28.key_name


  #9追加（outputs.tfファイル)
  # TerraformはAMI(=os)のズレを無視できる（EC2再作成防止）。
  #（→AMI(=OS)が更新されても、EC2が再作成されないように無視する設定)
  #(注意)ただし、OSタイプなど（例えば  t2.micro に書き換える時など）で、削除される可能性があるので注意する。

  lifecycle {
    ignore_changes = [
      ami,                 #←★4つ
      subnet_id,
      vpc_security_group_ids,
      associate_public_ip_address
    ]
  }            

  tags = { Name = "kaie28" }
}


# 10. 変数化(AWSサーバー外部にあるSSM(金庫))に、Djangoが動く時に必要になる機密情報(シークレットキーや通行証、デバック設定など)を保管する)

resource "aws_ssm_parameter" "django_secret_key" {
  name  = "/django-v3/SECRET_KEY" 
  type  = "SecureString"
  value = var.django_secret_key
}

resource "aws_ssm_parameter" "django_debug" {
  name  = "/django-v3/DEBUG"      
  type  = "String"
  value = var.django_debug
}

#11

