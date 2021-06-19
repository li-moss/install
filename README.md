# install

#   strongSwan ipsec ikev1 ikev2 VPN
#   MacOS, iOS, Android
#
#   1. 镜像拷贝 raspberry pi 系统 *.img 文件
#   2. 在根目录下创建 ssh 文件（不含后缀名）
#   3. ssh pi@raspberrypi.local 登录(默认密码: raspberry)
#   4. 更改密码：passwd -> Enter -> current password(raspberry) -> new password -> Enter -> new password -> Enter
#   5. sudo -i
#   6. apt-get update && apt-get upgrade -y
#   7. apt update && apt install git -y
#   8. git clone https://github.com/li-moss/install.git
#   9. cd install
#  10. chmod +x install.sh 
#  11. ./install.sh Access_Key Access_secret PSK PASSWORD USERNAME //(阿里云账号AccessKey 和 AccessSecret)
