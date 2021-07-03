# @Author: Li Yuan Rong
# @Date:   2021-06-19 08:41:50
# @Last Modified by:   Li Yuan Rong
# @Last Modified time: 2021-07-03 07:10:21
#!/bin/sh

##################################################################################
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
#   8. git clone https://github.com/li-moss/install.git /home/pi/project
#   9. cd /home/pi/project
#  10. chmod +x install.sh 
#  11. ./install.sh Access_Key Access_secret PSK PASSWORD USERNAME //(阿里云账号AccessKey 和 AccessSecret)
##################################################################################

#apt-get update && apt-get upgrade -y

PSK=$3
PASSWD=$4
USERNAME=$5

echo "========== install ddns-aliyun =========="

Access_Key=$1
Access_secret=$2

#apt update && apt install git -y
cd /home/pi
git clone https://github.com/dingguotu/ddns-aliyun.git

cat <<EOF >/home/pi/ddns-aliyun/conf.json
{
    "access_key": "$Access_Key",
    "access_secret": "$Access_secret",
    "domains": [
        {
            "name": "homemoss.com",
            "sub_domains": ["110ave"]
        }
    ]
}
EOF

crontab <<EOF
*/20 * * * * sudo python3 /home/pi/ddns-aliyun/ddns.py >/dev/null 2>&1
@reboot sleep 30 && sudo python3 /home/pi/project/proxy.py
EOF

cd ~/

echo "========== install strongswan and configuration =========="

apt-get install strongswan libcharon-extra-plugins libstrongswan-extra-plugins dnsmasq python3-flask python3-pip -y
apt install dnsutils -y
pip3 install -U flask-cors
pip3 install requests

##### 设置静态ip地址 ####
echo "interface eth0" | tee -a /etc/dhcpcd.conf
echo "static ip_address=192.168.1.200/24" | tee -a /etc/dhcpcd.conf
echo "static ip6_address=fd51:42f8:caae:d92e::ff/64" | tee -a /etc/dhcpcd.conf
echo "static routers=192.168.1.254" | tee -a /etc/dhcpcd.conf
echo "static domain_name_servers=192.168.1.254 8.8.8.8 fd51:42f8:caae:d92e::1" | tee -a /etc/dhcpcd.conf

#### 设置ip包转发 ####
echo "net.ipv4.ip_forward = 1" | tee -a /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_redirects = 0" | tee -a /etc/sysctl.conf
echo "net.ipv4.conf.all.send_redirects = 0" | tee -a /etc/sysctl.conf

iptables --table nat --append POSTROUTING --jump MASQUERADE
for vpn in /proc/sys/net/ipv4/conf/*; do echo 0 > $vpn/accept_redirects; echo 0 > $vpn/send_redirects; done
sysctl -p

######### 编辑 /etc/rc.local ############################################
sed -i '/exit 0/ i\for vpn in /proc/sys/net/ipv4/conf/*; do echo 0 > $vpn/accept_redirects; echo 0 > $vpn/send_redirects; done\
iptables --table nat --append POSTROUTING --jump MASQUERADE\
sudo python /root/install/udpSvr.py &' /etc/rc.local

######  nano /etc/ipsec.conf   ############################

cp /etc/ipsec.conf /etc/ipsec.conf.bak

###### 编辑 /etc/ipsec.secrets  ####################

echo ": PSK $PSK" | tee -a /etc/ipsec.secrets
echo "$USERNAME : XAUTH \"$PASSWD\"" | tee -a /etc/ipsec.secrets
echo "$USERNAME : EAP \"$PASSWD\"" | tee -a /etc/ipsec.secrets

cat <<EOF>/etc/ipsec.conf
# ipsec.conf - strongSwan IPsec configuration file
# basic configuration

config setup
    uniqueids=no

conn %default
    ikelifetime=60m
    keylife=20m
    rekeymargin=3m
    keyingtries=1

    #As of Android 9 Pie & iOS
    ike=aes256-sha512-prfsha512-modp1024,aes256-sha384-prfsha384-modp1024,aes256-sha256-prfsha256-modp1024,aes256-sha1-modp1024,aes128-sha1-modp1024,3des-sha1-modp1024!
    esp=aes256-sha512,aes256-sha384,aes256-sha256,aes256-sha256,aes256-sha1,3des-sha1!

    #conn IPsec-Xauth-PSK
    #left=192.168.1.200
    left=%any
    leftid=@110ave.homemoss.com
    leftsubnet=0.0.0.0/0
    leftfirewall=yes
    right=%any
    rightid=%any
    rightsourceip=10.3.0.5/26
    #rightauth2=xauth
    #rightdns=\$1
    rightdns=127.0.0.1,8.8.8.8,8.8.4.4
    type=tunnel
    auto=add

conn ikev1-Xauth-PSK
    authby=psk
    keyexchange=ikev1
    rightauth2=xauth

conn ikev2-PSK
    authby=psk
    keyexchange=ikev2

conn ikev2-EAP
    keyexchange=ikev2
    rightauth=eap-mschapv2

include /var/lib/strongswan/ipsec.conf.inc
EOF

echo "installing end"

reboot

exit 0

################################################

# Linux命令行
# https://blog.csdn.net/BLUE__YEAH/article/details/78183383?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-3.control&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-3.control

# https://www.strongswan.org/testing/testresults/ikev2/forecast/
# https://www.fontenay-ronan.fr/ipsec-xauth-vpn-server-on-raspberry-pi-behind-a-nat/
# https://www.howtoforge.com/tutorial/strongswan-based-ipsec-vpn-using-certificates-and-pre-shared-key-on-ubuntu-16-04/
# https://blog.csdn.net/sway913/article/details/105651649
# https://frankindev.com/2020/01/09/setup-ikev2-server-with-strongswan/