#!/bin/bash
# KeepWalking86
# Scripting for installing nginx-rtmp for VOD and Live Stream

# Check OS and install essential package to compile nginx
if [ -f /etc/debian_version ] ; then
	sudo apt-get install build-essential libpcre3 libpcre3-dev libssl-dev
else
	if [ -f /etc/redhat-release ] ; then
		sudo yum -y install make gcc gcc-c++ pcre-devel zlib-devel openssl-devel
	else
		echo "Distro hasn't been supported by this script"
	        exit 1
	fi
fi

# Download & unpack latest stable nginx & nginx-rtmp version
cd /opt
sudo git clone git://github.com/arut/nginx-rtmp-module.git
sudo wget http://nginx.org/download/nginx-1.14.1.tar.gz
sudo tar xzf nginx-1.14.1.tar.gz
mv nginx-1.14.1 nginx
cd nginx

# Build nginx with nginx-rtmp
sudo ./configure --with-http_ssl_module --add-module=../nginx-rtmp-module
sudo make
sudo make install

# Run Nginx with systemd
#Create nginx.service file
cat >/lib/systemd/system/nginx.service<<EOF
[Unit]
Description=nginx - high performance web server
Documentation=http://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx.conf
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID

[Install]
WantedBy=multi-user.target
EOF

#Start Nginx service
systemctl enable nginx.service
systemctl start nginx.service
