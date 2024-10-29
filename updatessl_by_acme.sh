#!/bin/bash

# 日志文件路径
LOG_FILE="/root/updatessl.log"
# 要打印的消息
MESSAGE="脚本已执行成功！"
CERT_PATH="/root/ssl/certificates"
EMAIL="it@santic.cn"
cmdfile="/root/.acme.sh/acme.sh"

if [ ! -f ${CERT_PATH} ]; then
mkdir -p ${CERT_PATH}
fi

if [ ! -f ${keyfile} ]; then
curl https://get.acme.sh | sh -s email=${EMAIL}
fi

declare -A dmap
dmap["a.site.com"]="/home/wwwtest/a.site.com/public"
dmap["b.site.com"]="/home/wwwtest/b.site.com/public"


#[Tue Oct 29 14:17:33 CST 2024] Your cert is in: /root/.acme.sh/b.site.com_ecc/b.site.com.cer
#[Tue Oct 29 14:17:33 CST 2024] Your cert key is in: /root/.acme.sh/b.site.com_ecc/b.site.com.key
#[Tue Oct 29 14:17:33 CST 2024] The intermediate CA cert is in: /root/.acme.sh/b.site.com_ecc/ca.cer
#[Tue Oct 29 14:17:33 CST 2024] And the full-chain cert is in: /root/.acme.sh/b.site.com_ecc/fullchain.cer


for dm in ${!dmap[@]}
do
webroot=${dmap[$dm]}
keyfile=${CERT_PATH}/${dm}.key
crtfile=${CERT_PATH}/${dm}.fullchain.cert
echo $keyfile
echo $crtfile
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