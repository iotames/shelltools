#/bin/bash

# 80端口被docker占用，先停止
/usr/local/bin/docker-compose -f /root/docker/docker-compose.yml stop

# 内建80端口的web服务器执行证书申请或续期
# runargs1="--accept-tos --email=xxxx@qq.com --domains=abc.com,www.abc.com --http --path=/root/docker/services/nginx/ssl/ --http.webroot=/path/to/webroot"
runargs1="--accept-tos --email=xxxx@qq.com --domains=abc.com,www.abc.com --http --path=/root/docker/services/nginx/ssl/"
runargs2="--accept-tos --email=xxxx@qq.com --domains=b.abc.com --http --path=/root/docker/services/nginx/ssl/" 

# OBTAIN A CERTIFICATE 首次运行时执行证书申请命令
# /root/apps/lego ${runargs1} run
# /root/apps/lego ${runargs2} run

# RENEW A CERTIFICATE 申请证书后，把证书续期加入定时任务
 /root/apps/lego ${runargs1} renew
 /root/apps/lego ${runargs1} renew

# 重新启动docker
/usr/local/bin/docker-compose -f /root/docker/docker-compose.yml up -d

# 证书续期之后，一定要重载Web服务配置。如nginx,apache,uhttpd
# systemctl reload nginx.service
docker exec -t nginx /bin/bash "/www/aftersslrenew.sh"

# 每周日凌晨1点10分执行该脚本
# echo "10 1 * * 0 /home/root/apps/lego.sh >> /home/root/apps/lego.output 2>&1" >>  /var/spool/cron/crontabs/root

# server {
#     listen       80;
#     listen    443 ssl;
#     ssl_certificate /ssl/certificates/abc.com.crt;
#     ssl_certificate_key /ssl/certificates/abc.com.key;
# }


# https://go-acme.github.io/lego/usage/cli/renew-a-certificate/index.html