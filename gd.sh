#!/bin/bash
#pkg install wget -y
#echo "开始下载升级包...服务器带宽小比较慢见谅"
echo "更新镜像源中....."
sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
apk -U upgrade
apk add unzip
echo "更新脚本中........."
# exit
#rm -rf 安卓版升级高德.zip
#wget https://magisk.proyy.com/tmp/安卓版升级高德.zip
ls
clear
echo "开始拉取高德灰度版6.5-全屏版本"
gdApk="Auto_V650.601392_release_signed.apk"
cd
rm -rf A1
mkdir A1
cd A1
rm -rf  $gdApk
curl -o $gdApk https://mapdownload.autonavi.com/apps/auto/manual/V650/$gdApk
check=0
md5a=`md5sum $gdApk |awk '{print $1}'`
[ "$md5a" == "72d077c5e6c47f7b6ef410ca4c88aeab" ]&&echo "校验成功下载完成"||check=1
[ "$check" == "1" ]&&echo "下载失败请联系管理员!:$md5a"||echo "ok"
[ "$check" == "1" ]&&exit 0||echo "ok"
echo "开始解包"
unzip -o $gdApk
echo "解包完成..."
echo "开始打包必要文件"
rm -rf automap
mkdir -p automap/lib
mv lib/armeabi-v7a automap/lib/arm
cp $gdApk automap/AutoMap.apk
mkdir ~/A2
rm -rf ~/A2/amap.tar
rm -rf ~/A2/check.sh
rm -rf ~/A2/check.sh.*
cd automap/ && tar -cvpf ~/A2/amap.tar *
find ./ -type f -print0|xargs -0 md5sum >~/A2/amap.tar.md5
#sed -i 's/.\/lib\/arm/\/system\/app\/AutoMap\/lib\/arm/' ~/A2/amap.tar.md5
sed -i 's/.\//\/system\/app\/AutoMap\//' ~/A2/amap.tar.md5
cd ~/A2/
curl -o check.sh https://magisk.proyy.com/tmp/check.sh
rm -rf ~/A1
pwd
echo "打包完成"
md5sum amap.tar
du -sh amap.tar
check=0
suma=`du -sh amap.tar |awk '{print $1}'`
[ "$suma" == "191.1M" ]&&echo "校验成功"||check=1
[ "$check" == "1" ]&&echo "打包校验失败,请重新跑安装脚本!!!"||echo "ok"
[ "$check" == "1" ]&&exit 0||echo "ok"
echo "一定要打开热点、车机连接并在工程模式开启tcpip，升级将在30秒后开始"
for i in {1..5}
do
    clear
    echo "一定要打开热点、车机连接并在工程模式开启tcpip，升级将在30秒后开始"
    echo "一定要打开热点、车机连接并在工程模式开启tcp/ip，升级将在30秒后开始"
    echo "一定要打开热点、车机连接并在工程模式开启tcp/ip，升级将在30秒后开始"
    echo "一定要打开热点、车机连接并在工程模式开启tcp/ip，升级将在30秒后开始"
    echo "一定要打开热点、车机连接并在工程模式开启tcp/ip，升级将在30秒后开始"
    echo "已等待$i秒....."
    pwd
    ls
    du -sh amap.tar
    echo "上面的大小应该是192M如果有问题请重新跑！"
    echo " "
    sleep 1
done
echo "开始升级，如有提示请按提示操作"
rm -rf gd-install.sh
curl -o gd-install.sh  https://magisk.proyy.com/tmp/gd-install.sh
echo " "
echo "请手动复制下面的命令粘贴再回车执行"
echo " "
echo "        bash ~/A2/gd-install.sh"
echo " "
echo " "
echo " "
#echo "1111"
#curl https://magisk.proyy.com/tmp/gd-install.sh|bash
