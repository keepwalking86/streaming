FROM alpine:3.8

ENV NGINX_VERSION=1.14.2
ENV NGINX_RTMP_VERSION=1.2.1
ENV NGINX_VOD_VERSION=1.24
ENV FFMPEG_VERSION=4.1

# Install essential package to compile nginx
RUN apk add --no-cache build-base openssl openssl-dev zlib-dev linux-headers pcre-dev

WORKDIR /opt

# Install dependencies packages for ffmpeg
RUN apk add --no-cache coreutils freetype-dev lame-dev libogg-dev libass libass-dev libvpx-dev libvorbis-dev \
	libwebp-dev libtheora-dev opus-dev rtmpdump-dev x264-dev x265-dev yasm
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk add --update fdk-aac-dev

# Get FFmpeg source
RUN wget http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz &&\
	tar zxf ffmpeg-${FFMPEG_VERSION}.tar.gz &&\
	mv ffmpeg-${FFMPEG_VERSION} ffmpeg &&\
	rm ffmpeg-${FFMPEG_VERSION}.tar.gz

# Compile ffmpeg
RUN cd /opt/ffmpeg &&\
	./configure --prefix=/usr/local \
	--enable-version3 \
	--enable-gpl \
	--enable-nonfree \
	--enable-small \
	--enable-libmp3lame \
	--enable-libx264 \
	--enable-libx265 \
	--enable-libvpx \
	--enable-libtheora \
	--enable-libvorbis \
	--enable-libopus \
	--enable-libfdk-aac \
	--enable-libass \
	--enable-libwebp \
	--enable-librtmp \
	--enable-postproc \
	--enable-avresample \
	--enable-libfreetype \
	--enable-openssl \
	--disable-debug \
	--disable-doc \
	--disable-ffplay \
	--extra-libs="-lpthread -lm" &&\
	make && make install && make distclean

# Create contain directories
RUN cd /var && mkdir -p vod live static hls

# Get nginx-vod module
RUN wget https://github.com/kaltura/nginx-vod-module/archive/${NGINX_VOD_VERSION}.tar.gz &&\
	tar zxf ${NGINX_VOD_VERSION}.tar.gz &&\
	mv nginx-vod-module-${NGINX_VOD_VERSION} nginx-vod-module &&\
	rm -rf ${NGINX_VOD_VERSION}.tar.gz

# Get nginx-rtmp module
RUN wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_VERSION}.tar.gz &&\
	tar zxf v${NGINX_RTMP_VERSION}.tar.gz &&\
	mv nginx-rtmp-module-${NGINX_RTMP_VERSION} nginx-rtmp-module &&\
	rm -rf v${NGINX_RTMP_VERSION}.tar.gz

# Get nginx
RUN wget http://nginx.org/download/nginx-1.14.2.tar.gz &&\
	tar zxf nginx-1.14.2.tar.gz &&\
	mv nginx-1.14.2 nginx &&\
	rm -rf nginx-1.14.2.tar.gz

# Create nginx user"
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

# Add nginx configuration file
ADD nginx.conf /etc/nginx/nginx.conf

# Copy stat.xsl (XML stylesheet) to view RTMP stats
RUN cp /opt/nginx-rtmp-module/stat.xsl /var/static

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

# Expose ports
EXPOSE 80 1935