#!/bin/sh

# run in centos. Commits on Aug 26, 2015

mkdir tbhome

echo 'create UTF-8,zh-CN，tbhome/i18n'
# echo -e '#LANG="en_US.UTF-8"\n#SYSFONT="latarcyrheb-sun16"\nLANG="zh_CN.UTF-8"\nSUPPORTED="zh_CN.UTF-8:zh_CN:zh:en_US.UTF-8:en_US:en"\nSYSFONT="latarcyrheb-sun16"'>>tbhome/i18n

echo '#LANG="en_US.UTF-8"
#SYSFONT="latarcyrheb-sun16"
LANG="zh_CN.UTF-8"
SUPPORTED="zh_CN.UTF-8:zh_CN:zh:en_US.UTF-8:en_US:en"
SYSFONT="latarcyrheb-sun16"' > tbhome/i18n

mv /etc/sysconfig/i18n /etc/sysconfig/i18n.bk

echo 'backup /etc/sysconfig/i18n => i18n.bk'
cp tbhome/i18n /etc/sysconfig/i18n
echo 'copy tbhome/i18n to /etc/sysconfig/i18n'

echo 'Relogin to change language UTF-8 zh-CN
重新登录后中文系统生效'

mv /usr/share/locale/zh_CN/LC_MESSAGES/wget.mo /usr/share/locale/zh_CN/LC_MESSAGES/wget.mo.bk1

echo '/usr/share/locale/zh_CN/LC_MESSAGES/wget.mo => wget.mo.bk1
解决wget下载命令的进度条问题'

echo 'mkdir tbhome
create tbhome/i18n
mv /etc/sysconfig/i18n /etc/sysconfig/i18n.bk
cp tbhome/i18n /etc/sysconfig/i18n
mv /usr/share/locale/zh_CN/LC_MESSAGES/wget.mo /usr/share/locale/zh_CN/LC_MESSAGES/wget.mo.bk1'>tbhome/log