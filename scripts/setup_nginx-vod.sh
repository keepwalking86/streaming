#!/bin/bash
#initial
NGINX_VERSION=1.14.2
NGINX_VOD_VERSION=1.24

#Install ffmpeg
yum install epel-release -y
rpm -v --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
yum install ffmpeg ffmpeg-devel -y

#Download nginx and nginx-vod module
#curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -C /nginx --strip 1 -xz
#curl -sL https://github.com/kaltura/nginx-vod-module/archive/${VOD_MODULE_VERSION}.tar.gz | tar -C /nginx-vod-module --strip 1 -xz
# Get nginx-vod module
cd /opt
wget https://github.com/kaltura/nginx-vod-module/archive/${NGINX_VOD_VERSION}.tar.gz
tar zxf ${NGINX_VOD_VERSION}.tar.gz
mv nginx-vod-module-${NGINX_VOD_VERSION} nginx-vod-module
rm -rf ${NGINX_VOD_VERSION}.tar.gz
# Get nginx
wget http://nginx.org/download/nginx-1.14.2.tar.gz
tar zxf nginx-1.14.2.tar.gz
mv nginx-1.14.2 nginx
rm -rf nginx-1.14.2.tar.gz

#Install libs
yum -y install make gcc gcc-c++ pcre-devel zlib-devel openssl-devel
useradd -d /dev/null -c "nginx user" -s /sbin/nologin nginx
cd /opt/nginx
./configure --prefix=/etc/nginx \
	--conf-path=/etc/nginx/nginx.conf \
	--sbin-path=/usr/sbin/nginx \
	--user=nginx --group=nginx \
	--pid-path=/var/run/nginx.pid \
	--with-http_ssl_module \
	--with-http_secure_link_module \
	--add-module=../nginx-vod-module \
	--with-file-aio \
	--with-threads
make && make install

#run nginx as systemd
cat >/lib/systemd/system/nginx.service<<EOF
[Unit]
Description=nginx - high performance web server
Documentation=http://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx.conf
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s QUIT \$MAINPID

[Install]
WantedBy=multi-user.target
EOF

#system nginx
systemctl start nginx
systemctl enable nginx
