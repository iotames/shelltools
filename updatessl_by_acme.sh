#!/bin/bash

# 日志文件路径
LOG_FILE="/root/updatessl.log"
# 要打印的消息
MESSAGE="脚本已执行成功！"

# 证书存放路径
CERT_PATH="/root/ssl/certificates"

# 注册邮箱
EMAIL="it@site.com"
# 命令文件路径
cmdfile="/root/.acme.sh/acme.sh"

# 检查证书存放路径，不存在则创建
if [ ! -f ${CERT_PATH} ]; then
mkdir -p ${CERT_PATH}
fi

# 检查命令文件，不存在则下载
if [ ! -f ${keyfile} ]; then
curl https://get.acme.sh | sh -s email=${EMAIL}
fi

# 定义域名与网站根目录的映射关系
# 假设要新增 c.site.com 做自动续期。应分2个步骤
# 1. 打开网站的NGINX配置文件，更改原先的SSL证书文件路径。每行末尾记得加;引号。如：/usr/local/nginx/conf/vhost/c.site.com.conf
# ssl_certificate      /root/ssl/certificates/c.site.com.fullchain.cert;
# ssl_certificate_key  /root/ssl/certificates/c.site.com.key;
# 2. 在 updatessl.sh 文件下面，declare -A dmap 这一行下面，新增一行：dmap["c.site.com"]="/home/wwwroot/c.site.com/public"
# 完成以上操作后，新增的网站，每周都会检查或执行SSL证书更新。如果想立即生效。请手动执行 sh updatessl.sh
declare -A dmap
dmap["a.site.com"]="/home/wwwtest/a.site.com/public"
dmap["b.site.com"]="/home/wwwtest/b.site.com/public"


for dm in ${!dmap[@]}
do
webroot=${dmap[$dm]}
keyfile=${CERT_PATH}/${dm}.key
crtfile=${CERT_PATH}/${dm}.fullchain.cert
echo "ssl_certificate_key $keyfile"
echo "ssl_certificate $crtfile"
runargs="--install-cert -d ${dm} --key-file ${keyfile} --fullchain-file ${crtfile} -w ${webroot}"
if [ ! -f ${keyfile} ]; then
sysKeyfile="/root/.acme.sh/${dm}_ecc/${dm}.key"
sysCrtfile="/root/.acme.sh/${dm}_ecc/fullchain.cer"
  if [ -f $sysKeyfile ]; then
  echo "copy $sysKeyfile to $keyfile"
  echo "copy $sysCrtfile to $crtfile"
  cp $sysKeyfile $keyfile
  cp $sysCrtfile $crtfile
  else
  ${cmdfile} ${runargs} --issue
  fi
else
${cmdfile} ${runargs} --renew
fi
done

# 证书续期之后，一定要重载Web服务配置。如nginx,apache,uhttpd
# systemctl reload nginx.service
nginx -s reload

# 将消息追加到日志文件
echo "$(date '+%Y-%m-%d %H:%M:%S') - $MESSAGE" >> "$LOG_FILE"

#[Tue Oct 29 14:17:33 CST 2024] Your cert is in: /root/.acme.sh/b.site.com_ecc/b.site.com.cer
#[Tue Oct 29 14:17:33 CST 2024] Your cert key is in: /root/.acme.sh/b.site.com_ecc/b.site.com.key
#[Tue Oct 29 14:17:33 CST 2024] The intermediate CA cert is in: /root/.acme.sh/b.site.com_ecc/ca.cer
#[Tue Oct 29 14:17:33 CST 2024] And the full-chain cert is in: /root/.acme.sh/b.site.com_ecc/fullchain.cer