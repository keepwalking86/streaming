# Streaming Media với Nginx và nginx-rtmp module

# Table of contents

- [1. Giới thiệu nginx-rtmp](#about)
- [2. Cài đặt Nginx với module nginx-rtmp](#install-nginx-rtmp)
- [3. VOD qua RTMP](#vod-rtmp)
  - [3.1. Cấu hình Nginx](#nginx-rtmp)
  - [3.2. Sử dụng Video Player để chạy video](#vlc-player)
- [4. VOD qua HLS](#install-libx264)
  - [4.1 Cài đặt Ffmpeg](#install-ffmpeg)
  - [4.2 Convert tệp vod.mp4 sang HLS](#mp4-to-hls)
  - [4.3 Cấu hình nginx](#nginx-hls)
  - [4.4 Phát video trên web browser với videojs](#videojs)
- [5. Cấu hình Live Streaming](#live-streaming)
- [6. HLS encryption in the rtmp module](#hls-encryption)
- [7. Một số trang tham khảo](#reference)

=============================================================================

# Content

## <a name="about">1. Về  nginx-rtmp module</a>

Nginx-rtmp là module mở rộng, mà kết hợp với Nginx để cho phép xây dựng máy chủ streaming media.

Một số tính năng mà nginx-rtmp hỗ trợ:

- RTMP/HLS/MPEG-DASH live streaming

- RTMP Video on demand FLV/MP4, phát từ local file hoặc qua HTTP

- Stream relay support for distributed streaming: push & pull models

- Ghi streams vào nhiều tệp FLV

- Hỗ trợ H264/AAC

- Transcode trực tuyến với FFmpeg

- HTTP callbacks (publish/play/record/update etc)

- Module điều khiển HTTP để recording audio/video and dropping clients

- Kỹ thuật buffer tiên tiến để giữ cho bộ nhớ được cấp ở mức thấp nhất mà streaming vẫn nhanh.

- Kết hợp được với các ứng dụng như Wirecast, FMS, Wowza, JWPlayer, FlowPlayer, StrobeMediaPlayback, ffmpeg, avconv, rtmpdump, flvstreamer, ..

- Thống kê stream với định dạng XML/XSL

- Linux/FreeBSD/MacOS/Windows

## <a name="install-nginx-rtmp">2. Cài đặt Nginx với module nginx-rtmp</a>

**Step1**: Download & unpack  latest stable nginx & nginx-rtmp version

```
cd /opt
sudo git clone git://github.com/arut/nginx-rtmp-module.git
sudo wget http://nginx.org/download/nginx-1.14.1.tar.gz
sudo tar xzf nginx-1.14.1.tar.gz
mv nginx-1.14.1 nginx
```

**Step2**: Build nginx với nginx-rtmp

```
sudo ./configure --prefix=/etc/nginx \
--pid-path=/var/run/nginx.pid \
--conf-path=/etc/nginx/nginx.conf \
--sbin-path=/usr/sbin/nginx \
--user=nginx \
--group=nginx \
--with-file-aio \
--with-http_ssl_module \
--add-module=nginx-rtmp-module
sudo make
sudo make install
```

**Step3**: Run Nginx với systemd

- Create tệp /lib/systemd/system/nginx.service với nội dung sau:

```
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
```

- Start Nginx service

```
systemctl enable nginx.service
systemctl start nginx.service
```

## <a name="vod-rtmp">3. VOD qua RTMP</a>

Chúng ta sẽ cấu hình để cho phép các video player xem video qua giao thức RTMP.

### <a name="nginx-rtmp">3.1 Cấu hình Nginx</a>

**Step1**: Tạo tệp tin cấu hình nginx với nội dung sau:

```
user  nginx;
worker_processes  1;
pid        /run/nginx.pid;
user nginx;

events {
    worker_connections  1024;
}
rtmp {
    server {
        listen 1935;
        chunk_size 4000;
        # video on demand for mp4 files
        application vod {
            play /var/mp4s;
        }
    }
}

http {
    access_log /var/log/nginx/access-streaming.log;
    error_log /var/log/nginx/error-streaming.log;
    server {
        listen      80;
        root /var/www/html;
        # RTMP statistics in XML
        location /stat {
            # Copy stat.xsl put to root directory
            rtmp_stat all;
            rtmp_stat_stylesheet stat.xsl;
        }
    }
}
```

Thông tin cấu hình tệp cấu như sau:

Khối rtmp { }

- listen port với 1935 (port default)

- application với đường dẫn ảo là **vod**

- Đường dẫn thư mục chứa các tệp video để phát là "/var/mp4s".

Khi đó muốn sử dụng chúng ta truy cập kiểu như "rtmp://192.168.10.113:1935/vod/video-name.mp4"

**Step2**: Tạo thư mục chứa và copy tệp tin video

```
mkdir /var/mp4s
cd /var/mp4s
```

Chúng ta download hoặc copy một tin video vào thư mục /var/mp4s

### <a name="vlc-player">3.2. Sử dụng Video Player để chạy video</a>

Chúng ta có thể sử dụng một trình phát video có hỗ trợ giao thức rtmp để phát.

Ở đây, chúng ta có thể sử dụng [VLC player](https://www.videolan.org/vlc/#download)

Mở player VLC → Nhấn Media → Chọn "Open Network Stream ..". Sau đó vào thông tin đường dẫn tệp video vod với **rtmp://192.168.10.113:1935/vod/vod.mp4**

<p align="center"> 
<img src="../images/vlc-rtmp.png" />
</p>

Cuối cùng nhấn Play để phát video.

<p align="center"> 
<img src="../images/vlc-play.png" />
</p>

## <a name="vod-hls">4. VOD qua HLS</a>

Chúng ta sẽ cấu hình để cho phép video player phát video qua giao thức HLS (Apple HTTP Live Streaming).

### <a name="install-ffmpeg"4.1 Cài đặt Ffmpeg</a>

Sử dụng script [Installing FFmpeg on Linux](../scritps/install_ffmpeg.sh)

Nếu chỉ sử dụng một thư viện có sẵn thì cài đặt đơn giản như sau trên CentOS

`yum install ffmpeg ffmpeg-devel ffmpeg-libpostproc`

Trong phần [Giới thiệu FFmpeg](../docs/About-FFmpeg.md), cũng đã giới thiệu và cách sử dụng cơ bản FFmpeg.

### <a name="mp4-to-hls>4.2 Convert tệp vod.mp4 sang HLS</a>

Trước khi convert, chúng ta thực hiện copy/download tệp tin video lên server (ví dụ tệp tin là vod.mp4)

Sử dụng lệnh ffmpeg để convert vod.mp4 sang định dạng HLS (Apache HTTP Live Stream)

`ffmpeg -i video.mp4 -profile:v baseline -level 3.0 -s 720x400 -start_number 0 -hls_time 10 -hls_list_size 0 -f hls /tmp/index.m3u8`

Trong đó:

- vod.mp4 là tệp video đầu vào cần convert

- index.m3u8 là tệp tin master đầu ra của HLS playlist

- và một số tham số tùy chọn cho độ phân giải, thời gian phân đoạn, ..

### <a name="nginx-hls">4.3 Cấu hình nginx</a>

Ở đây, Chúng ta sẽ cấu hình nginx làm web server, đồng thời cấu hình làm media server.

```
user nginx;
worker_processes  1;
error_log  logs/rtmp_error.log debug;
pid        /var/run/nginx.pid;
events {
    worker_connections  1024;
}
http {
    #serve the player for HLS
    server {
        listen       80;
        root /var/www/html;
        server_name  localhost;
        location /hls {
            # CORS setup
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Expose-Headers' 'Content-Length';
            # Allow CORS preflight requests
            if ($request_method = 'OPTIONS') {
                add_header 'Access-Control-Allow-Origin' '*';
                add_header 'Access-Control-Max-Age' 1728000;
                add_header 'Content-Type' 'text/plain charset=UTF-8';
                add_header 'Content-Length' 0;
                return 204;
            }
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
            add_header Cache-Control no-cache;
            alias /tmp;
        }
    }
}
```

- Listen với port default 80

- URL của web server sẽ là http://192.168.10.113/; với root directory là /var/www/html

- URL của stream server sẽ là http://192.168.10.113/hls

- Playlist của stream là tệp tin m3u8, với các segment là tệp ts

- Đường dẫn thư mục chứa các playlist là /tmp

### <a name="videojs">4.4 Phát video trên web browser với videojs</a>

Chúng ta có thể phát video trên web browser, mà sử dụng flash player như Flowplayer hay Jwplayer. Trong trường  hợp này, tôi sẽ giới thiệu sử dụng videojs player cho phát video trên web browser.

Link về videojs: [https://github.com/videojs/http-streaming](https://github.com/videojs/http-streaming)

Trên Nginx web server, chúng ta sẽ tạo tệp tin index.html với nội dung sau vào root directory:


```
<!DOCTYPE html>
<html>
<head>
<meta charset=utf-8 />
<title>Videojs-HLS embed</title>
  
  <!--

  Uses the latest versions of video.js and videojs-http-streaming.

  To use specific versions, please change the URLs to the form:

  <link href="https://unpkg.com/video.js@6.7.1/dist/video-js.css" rel="stylesheet">
  <script src="https://unpkg.com/video.js@6.7.1/dist/video.js"></script>
  <script src="https://unpkg.com/@videojs/http-streaming@0.9.0/dist/videojs-http-streaming.js"></script>

  -->

  <link href="https://unpkg.com/video.js/dist/video-js.css" rel="stylesheet">
<style>
.center {
    margin-left: auto;
    margin-right: auto;
    display: block
}
</style>
</head>
<body>
<!--  <h1>Video.js Example Embed</h1> -->

  <video-js id="my_video_1" class="vjs-default-skin center" controls preload="auto" width="720" height="400" poster="../images/bbb-poster.jpg">
    <source src="http://192.168.10.113/hls/index.m3u8" type="application/x-mpegURL">
  </video-js>

  <script src="https://unpkg.com/video.js/dist/video.js"></script>
  <script src="https://unpkg.com/@videojs/http-streaming/dist/videojs-http-streaming.js"></script>

  <script>
    var player = videojs('my_video_1');
  </script>

</body>
</html>
```

Trong tệp index.html chúng ta sẽ vào đường dẫn chứa tệp tin playlist mà đã convert ở Step2. Khi đó vào thông tin đường dẫn URL ở đây là http://192.168.10.113/hls/index.m3u8

Cuối cùng duyệt http://192.168.10.113/index.html và xem kết quả

<p align="center"> 
<img src="../images/bbb-video.png" />
</p>

Chúng ta thấy videojs cho khung nhìn tuyệt đẹp.

## <a name="live-streaming">5. Cấu hình Live Streaming</a>

Updating ...

## <a name="hls-encryption">6. HLS encryption in the rtmp module</a>

Updating ...

## <a name="reference">7. Một số trang tham khảo</a>

- https://github.com/arut/nginx-rtmp-module

- https://github.com/videojs/http-streaming

