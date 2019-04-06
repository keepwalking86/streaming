FROM alpine:3.8

#Install essential package to compile nginx & ffmpeg
RUN apk add --no-cache build-base openssl openssl-dev zlib-dev linux-headers pcre-dev ffmpeg ffmpeg-dev

WORKDIR /opt

#Create contain directories
RUN cd /var && mkdir -p vod live static hls

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
RUN adduser -h /dev/null -D -s /sbin/nologin nginx

# Build nginx with nginx-rtmp & nginx-vod
RUN cd /opt/nginx &&\
	./configure --prefix=/etc/nginx \
	--conf-path=/etc/nginx/nginx.conf \
	--sbin-path=/usr/sbin/nginx \
	--user=nginx \
	--group=nginx \
	--error-log-path=logs/error.log \
	--http-log-path=logs/access.log \
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
	--with-cc-opt="-O3" \
	--with-threads \
	--with-http_sub_module \
	--with-http_stub_status_module &&\
	make && make install

#Add nginx configuration file
ADD nginx.conf /etc/nginx/nginx.conf

#Copy stat.xsl (XML stylesheet) to view RTMP stats
RUN cp /opt/nginx-rtmp-module/stat.xsl /var/static

#Start Nginx
CMD ["nginx", "-g", "daemon off;"]

## Expose ports
EXPOSE 80 1935