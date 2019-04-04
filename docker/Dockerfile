#FROM alpine
FROM centos:7
#install essential package to compile nginx & ffmpeg
#RUN apk add --no-cache build-base openssl openssl-dev zlib-dev linux-headers pcre-dev ffmpeg ffmpeg-dev
RUN yum -y install make gcc gcc-c++ pcre-devel zlib-devel openssl-devel wget
#install ffmpeg
RUN yum -y install epel-release  &&\
	rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm &&\
	yum -y install ffmpeg ffmpeg-devel

WORKDIR /opt

#create directories
RUN mkdir /data /static

#Get nginx-vod module
RUN wget https://github.com/kaltura/nginx-vod-module/archive/1.24.tar.gz &&\
	tar zxf 1.24.tar.gz &&\
	mv nginx-vod-module-1.24 nginx-vod-module &&\
	rm -rf 1.24.tar.gz

#Get nginx-rtmp module
RUN wget https://github.com/arut/nginx-rtmp-module/archive/v1.2.1.tar.gz &&\
	tar zxf v1.2.1.tar.gz &&\
	mv nginx-rtmp-module-1.2.1 nginx-rtmp-module &&\
	rm -rf v1.2.1.tar.gz

#Get nginx
RUN wget http://nginx.org/download/nginx-1.14.2.tar.gz &&\
	tar zxf nginx-1.14.2.tar.gz &&\
	mv nginx-1.14.2 nginx &&\
	rm -rf nginx-1.14.2.tar.gz

#Create nginx user"
#RUN adduser -h /dev/null -D -s /sbin/nologin nginx #for alpine
RUN useradd -d /dev/null -c "nginx user" -s /sbin/nologin nginx #FOR CENTOS

# Build nginx with nginx-rtmp & nginx-vod
RUN cd /opt/nginx &&\
	./configure --prefix=/etc/nginx \
	--conf-path=/etc/nginx/nginx.conf \
	--sbin-path=/usr/sbin/nginx \
	--user=nginx \
	--group=nginx \
	--error-log-path=/logs/error.log \
	--http-log-path=/logs/access.log \
	--add-module=../nginx-vod-module \
	--add-module=../nginx-rtmp-module \
	--without-mail_pop3_module \
	--without-mail_imap_module \
	--without-mail_smtp_module \
	--without-http_split_clients_module \
	--without-http_uwsgi_module \
	--without-http_scgi_module \
	--with-http_ssl_module \
	--with-file-aio \
	--with-http_sub_module \
	--with-threads \
	--with-http_stub_status_module &&\
	make && make install

#Add nginx configuration files
ADD nginx.conf /etc/nginx/nginx.conf
ADD static /static

#Start Nginx
CMD ["nginx", "-g", "daemon off;"]

## Expose ports
EXPOSE 80 1935
