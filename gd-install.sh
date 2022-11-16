#!/bin/bash
#复制下面点允许
#termux-setup-storage
#打开热点车机连接到手机
#然后
#再复制下面等待即可
echo "更新镜像源中....."
sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
apk -U upgrade
apk add android-tools wget
#软件安装结束开始执行
cd ~/A2
termux_home=`pwd`
echo $termux_home
gddir="$termux_home/automap"
mkdir $gddir
cd $gddir
ls
clear
carip=$1
# if [ ! $carip ]; then
#   echo "请开启手机热点车机连接至热点再重新执行"
#   exit
# else
#   echo "获取到车机IP"
# fi
echo "车机IP为:$carip"
echo "连接车机中....如卡住请确认车机ip正确并车机工程模式其他菜单中已开启TCP/IP"
export ANDROID_ADB_SERVER_PORT=12888
adb connect $carip
echo "获取root权限"
adb root
echo "等待车机连接,如卡住请确认车机ip正确并车机工程模式其他菜单中已开启TCP/IP"
adb wait-for-device
echo "挂载system为读写"
adb remount
echo "等待车机连接,如卡住请确认车机ip正确并车机工程模式其他菜单中已开启TCP/IP"
adb wait-for-device
adb connect $carip
echo "获取root权限"
adb root
echo "等待车机连接,如卡住请确认车机ip正确并车机工程模式其他菜单中已开启TCP/IP"
adb wait-for-device
echo "挂载system为读写"
adb remount
echo "等待车机连接,如卡住请确认车机ip正确并车机工程模式其他菜单中已开启TCP/IP"
adb wait-for-device
echo "开始备份"
bakfile_check="$gddir/amap_backup.tar"
echo "开始校验本地备份是否完整"
du -sh $bakfile_check
check=0
suma=`du -sh $bakfile_check |awk '{print $1}'`
[ "$suma" == "163M" ]&&echo "本地备份校验成功"||check=1
[ "$check" == "1" ]&&echo "本地备份校验失败将执行清理操作!!!"||echo "ok"
[ "$check" == "1" ]&&rm -rf $bakfile_check ||echo "ok"
if [  -f "$bakfile_check"  ]; then
     echo "原车高德备份已存在"
     echo "请确认备份文件大小是否正常,163M左右"
     du -sh $bakfile_check
else
     echo "备份文件不存在，开始备份..."
     adb shell "rm -rf /data/local/tmp/*"
     adb shell "cd /system/app/AutoMap/ && tar -cvpf /data/local/tmp/amap_backup.tar *"
     adb shell "find /system/app/AutoMap/ -type f -print0|xargs -0 md5sum >/data/local/tmp/amap_backup.tar.md5"
     adb shell chmod 777 /data/local/tmp/amap_backup.tar /data/local/tmp/amap_backup.tar.md5
     echo "备份完成,执行传输至本地"
     adb pull /data/local/tmp/amap_backup.tar $gddir/
     adb pull /data/local/tmp/amap_backup.tar.md5 $gddir/
     echo "备份传输至手机完成"
     pwd
     ls $gddir/
     echo "开始校验本地备份是否完整"
     du -sh $bakfile_check
     check=0
     suma=`du -sh $bakfile_check |awk '{print $1}'`
     [ "$suma" == "163M" ]&&echo "本地备份校验成功"||check=1
     [ "$check" == "1" ]&&echo "本地备份校验失败将执行清理操作并拉取网络备份!!!"||echo "ok"
     [ "$check" == "1" ]&&rm -rf $bakfile_check ||echo "ok"
     [ "$check" == "1" ]&&wget -O automap.zip "http://magisk.proyy.com:5201/d/lanzou/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97%E6%9C%80%E6%96%B0%E8%BD%A6%E6%9C%BA%E5%AE%89%E8%A3%85%E7%AC%AC%E4%B8%89%E6%96%B9apk/%E9%AB%98%E5%BE%B7%E8%BD%A6%E6%9C%BA%E7%89%88/%E5%8E%9F%E8%BD%A6%E5%A4%87%E4%BB%BD/automap.zip" ||echo "ok"
     [ "$check" == "1" ]&&unzip -d $gddir automap.zip ||echo "ok"
     echo "请确认备份文件大小是否正常,163M左右"
     du -sh $bakfile_check
fi
printf "请选择升级还是回退(1升级/2回退): "
read num

case $num in
    1)
        echo "你选择了升级高德版本"
        filename="amap.tar"
        cp $termux_home/amap.tar $gddir/
        cp $termux_home/amap.tar.md5 $gddir/
        cp $termux_home/check.sh $gddir/
        ;;
    2)
        echo "你选择了回退到高德原厂版本"
        filename="amap_backup.tar"
        ;;
    *)
        echo "error"
esac
echo "删除原车高德地图"
adb shell "rm -rf /system/app/AutoMap/*"
echo "释放system分区空间"
adb shell "killall com.autonavi.amapauto 2>/dev/null"
adb shell "killall com.autonavi.amapauto:push 2>dev/null"
adb shell "killall com.autonavi.amapauto:locationservice 2>dev/null"
echo "上传替换高德包"
adb push $filename /data/local/tmp/
adb push $filename.md5 /data/local/tmp/
adb push check.sh /data/local/tmp/
adb shell chmod 777 /data/local/tmp/check.sh
echo "执行替换操作"
adb shell "tar -xvpf /data/local/tmp/$filename -C /system/app/AutoMap/"
echo "校验文件完整性"
adb shell "/data/local/tmp/check.sh $filename"
echo "修复文件权限"
adb shell "chown -R root:root /system/app/AutoMap/"
adb shell "chmod -R 755 /system/app/AutoMap/"
adb shell "chmod -R 644 /system/app/AutoMap/AutoMap.apk"
adb shell "chmod -R 644 /system/app/AutoMap/lib/arm/*"
echo "开始检测当前版本"
adb shell settings put global policy_control immersive.full=com.autonavi.amapauto
du -sh $filename
check=0
suma=`du -sh $filename |awk '{print $1}'`
[ "$suma" == "192M" ]&&echo "检测完成:为全屏版本"||check=1
[ "$check" == "1" ]&&echo "检测完成:为快捷键版本"||echo "ok"
[ "$check" == "1" ]&&adb shell settings put global policy_control null||echo "ok"
echo "操作完成, 车机将在10秒后重启, 如果你不希望重启, 请在10秒内关闭此窗口！"
sleep 10
echo "开始执行车机重启,恭喜安装完成,退出termux即可"
adb shell reboot
echo "执行车机重启完成！"