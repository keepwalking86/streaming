# Docker for nginx rtmp & vod modules for video streaming

**Step1: Build docker images**

>docker build -t keepwalking/nginx-stream .

**Step2: Running container**

>docker run --name nginx-stream -d -p 8080:80 -p 1935:1935 keepwalking/nginx-stream

**Step3: Get video mp4 to vod contain directory**

```
docker exec -it nginx-stream /bin/sh
cd /var/vod
wget https://github.com/keepwalking86/streaming/raw/master/video/bbb.mp4
```

**Step4: Creating web server**

>docker run --name nginx -d -p 80:80 nginx

**Step5: Add vod.html to Root Directory**

```
docker exec -it nginx bash
cd /usr/share/nginx/html && apt-get update && apt-get install wget -y
wget https://raw.githubusercontent.com/keepwalking86/streaming/master/web/index.html -O vod.html
```

**Step6: Replace source src in vod.html**

Edit vod.html and replace source src with the following url:

>http://localhost:8080/vod/bbb.mp4/index.m3u8

**Step7: Playing video via following url**

>http://localhost/vod.html

**Step8: Live streaming**

Using a software on mobile to live streaming (ex: Larix Broadcaster)

>rtmp://your-ip-docker-host:1935/trancoder/$STREAM_NAME

ex:

>rtmp://192.168.10.86:1935/trancoder/stream

**Step9: Add live.html to web server root directory**

```
docker exec -it nginx bash
wget https://raw.githubusercontent.com/keepwalking86/streaming/master/web/index.html -O /usr/share/nginx/html/live.html
```

**Step6: Replace source src in live.html**

Edit index.html and replace source src with the following url:

>http://localhost/live/$stream.m3u8

**Step10: Access live streaming via web browser**

>http://localhost/live.html
