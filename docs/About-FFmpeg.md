# About FFmpeg

# Table of contents

- [1. Giới thiệu về FFmpeg](#about)
- [2. Cài đặt FFmpeg từ source trên Linux](#install)
  - [2.1. Gói cài đặt yêu cầu](#install-dependencies)
  - [2.2. Cài đặt NASM](#install-nasm)
  - [2.3. Cài đặt yams](#install-yams)
  - [2.4. Cài đặt thư viện libx264](#install-libx264)
  - [2.5. Cài đặt thư viện libx265](#install-libx265)
  - [2.6. Cài đặt thư viện libfdk_aac](#install-libfdk-aac)
  - [2.7. Cài đặt thư viện libmp3lame](#install-libmp3lame)
  - [2.8. Cài đặt thư viện libopus](#install-libopus)
  - [2.9. Cài đặt thư viện libvpx](#install-libvpx)
  - [2.10. Cài đặt FFmpeg](#install-ffmpeg)
- [3. Sử dụng ffmpeg cơ bản](#use-ffmpeg)

=============================================================================

# Content

## <a name="about">1. Giới thiệu về FFmpeg</a>

FFmpeg là phần mềm miễn phí, gồm tập các thư viện và chương trình cho việc xử lý audio, video như ghi, chuyển đổi và stream. Cụ thể công việc xử lý ở đây của FFmpeg có thể gồm: encode, decode, transcode, mux, demux, record, stream, filter, và chạy một số tệp tin media. FFmpeg có thể hỗ trợ trên nhiều nền tảng OS như: Linux, Windows, MacOS, ...

Một số công cụ FFmpeg

- ffmpeg: Một công cụ dòng lệnh dùng để chuyển đổi định dạng các tệp tin đa phương tiện

- ffplay: Một trình media đơn giản dựa trên các thư viện SDL và Ffmpeg

- ffprobe: Công cụ phân tích luồng đa phương tiện

## <a name="install">2. Cài đặt FFmpeg từ source trên Linux</a>

### <a name="install-dependencies">2.1. Gói cài đặt yêu cầu</a>

Cài đặt một số package và thư viện cần thiết cho biên dịch

**Trên CentOS**

`yum install autoconf automake bzip2 bzip2-devel cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel`

**Trên Ubuntu**

```
apt-get update -qq
apt-get -y install autoconf automake build-essential cmake git-core libass-dev \
libfreetype6-dev libsdl2-dev libtool libva-dev libvdpau-dev libvorbis-dev \
libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo wget zlib1g-dev
```

- Tạo thư mục chứa source code

`mkdir ~/ffmpeg_sources`

Ở đây, chúng ta sẽ sử dụng tài khoản root cho cài đặt, vì vậy thư mục chứa source code là /root/ffmpeg_sources

### <a name="install-nasm">2.2. Cài đặt NASM</a>

Với Ffmpeg, chúng ta cần nhiều thư viện mở rộng khác nhau cho convert video và audio, và một số thư viện này được biên dịch bởi trình biên dịch “Nasm”.
Nasm có thể có sẵn trong base repo, vì vậy có thể cài đặt bằng qua công cụ như yum hay apt. Nhưng một số package và libraries cần nasm phiên bản mới hơn (yêu cầu nasm >=2.13), vì vậy chúng ta sẽ cài đặt như sau:

:( buồn thay là trang chính download nasm die http://www.nasm.us/. Vì vậy mà chúng ta sẽ tìm package nasm ở trang khác. Ở đây tôi tìm được gói rpm từ [https://pkgs.org/](https://pkgs.org/)

**Trên CentOS**

```
wget http://download-ib01.fedoraproject.org/pub/fedora/linux/updates/27/x86_64/Packages/n/nasm-2.13.02-1.fc27.x86_64.rpm

rpm -ivh nasm-2.13.02-1.fc27.x86_64.rpm
```

>#nasm -v
NASM version 2.13.02 compiled on Jan  2 2018

**Trên Ubuntu**

```
wget -0 nasm_2.14.deb http://ftp.br.debian.org/debian/pool/main/n/nasm/nasm_2.14-1_amd64.deb
dpkg --install nasm_2.14.deb
```

## <a name="install-yams">2.3 Cài đặt yams</a>

yams cũng được sử dụng để biên dịch một số thư viện mở rộng cho FFmpeg.

**Trên CentOS**

```
cd ~/ffmpeg_sources
curl -O -L http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar xzvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
make install
```

**Trên Ubuntu**

`apt-get install yasm`

### <a name="install-libx264">2.4 Cài đặt thư viện libx264</a>

Thư viện libx264 được sử dụng để mã hóa video H.264

```
cd ~/ffmpeg_sources
git clone --depth 1 http://git.videolan.org/git/x264
cd x264
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
make
make install
```

### <a name="install-libx265">2.5 Cài đặt thư viện libx265</a>

Thư viện libx265 được sử dụng để mã hóa video H.265/HEVC

```
cd ~/ffmpeg_sources
hg clone https://bitbucket.org/multicoreware/x265
cd ~/ffmpeg_sources/x265/build/linux
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
make
make install
```

### <a name="install-libfdk-aac">2.6 Cài đặt thư viện libfdk_aac</a>

Thư viện libfdk_aac được sử dụng để mã hóa audio AAC.

```
cd ~/ffmpeg_sources
git clone --depth 1 https://github.com/mstorsjo/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
```

### <a name="install-libmp3lame">2.7 Cài đặt thư viện libmp3lame</a>

Thư viện libmp3lame được sử dụng để mã hóa audio MP3.

```
cd ~/ffmpeg_sources
curl -O -L https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
tar xzvf lame-3.100.tar.gz
cd lame-3.100
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --disable-shared --enable-nasm
make
make install
```

### <a name="install-libopus">2.8 Cài đặt thư viện libopus</a>

Thư viện libopus cho mã hóa và giải mã audio Opus.

```
cd ~/ffmpeg_sources
curl -O -L https://archive.mozilla.org/pub/opus/opus-1.3.tar.gz
tar xzvf opus-1.3.tar.gz
cd opus-1.3
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
```

### <a name="install-libvpx">2.9 Cài đặt thư viện libvpx</a>

Thư viện libvpx được sử dụng cho mã hóa và giải mã video VP8/VP9

```
cd ~/ffmpeg_sources
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
make
make install
```

### <a name="install-ffmpeg">2.10 Cài đặt FFmpeg</a>

Sau khi đã cài đặt các thư viện cần thiết cho mã hóa và giải mã audio và video, chúng ta thực hiện cài đặt FFmpeg từ source. Tùy thuộc vào nhu cầu mà chúng thực hiện cài đặt và add thư viện mở rộng trong quá trình thực hiện cài đặt Ffmpeg.

- Thực hiện download và cài đặt FFmpeg như sau:

```
cd ~/ffmpeg_sources
curl -O -L https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --extra-libs=-lpthread \
  --extra-libs=-lm \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-libfdk_aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree
make
make install
hash -r
```

- Kiểm tra cài đặt ffmpeg

>#ffmpeg
ffmpeg version N-93115-g84e7aff Copyright (c) 2000-2019 the FFmpeg developers
  built with gcc 4.8.5 (GCC) 20150623 (Red Hat 4.8.5-36)
  configuration: --prefix=/root/ffmpeg_build --pkg-config-flags=--static --extra-cflags=-I/root/ffmpeg_build/include --extra-ldflags=-L/root/ffmpeg_build/lib --extra-libs=-lpthread --extra-libs=-lm --bindir=/root/bin --enable-gpl --enable-libfdk_aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvpx --enable-libx264 --enable-libx265 --enable-nonfree
  libavutil      56. 26.100 / 56. 26.100
  libavcodec     58. 47.100 / 58. 47.100
  libavformat    58. 26.101 / 58. 26.101
  libavdevice    58.  6.101 / 58.  6.101
  libavfilter     7. 48.100 /  7. 48.100
  libswscale      5.  4.100 /  5.  4.100
  libswresample   3.  4.100 /  3.  4.100
  libpostproc    55.  4.100 / 55.  4.100
Hyper fast Audio and Video encoder
usage: ffmpeg [options] [[infile options] -i infile]... {[outfile options] outfile}...
Use -h to get full help or, even better, run 'man ffmpeg'

- Chạy ffmpeg như lệnh ffmpeg

`ln -s /root/bin/ffmpeg /usr/bin/ffmpeg`

## <a name="use-ffmpeg">3. Sử dụng ffmpeg cơ bản</a>

Cú pháp lệnh ffmpeg như sau:

`ffmpeg [global_options] {[input_file_options] -i input_url} {[output_file_options] output_url} …`

- Lấy thông tin tệp audio/video

`ffmpeg -i file_name`

ví dụ:

`ffmpeg -i video.mp4  -hide_banner`
>Input #0, mov,mp4,m4a,3gp,3g2,mj2, from 'video.mp4':
  Metadata:
    major_brand     : isom
    minor_version   : 512
    compatible_brands: isomiso2avc1mp41
    encoder         : Lavf57.83.100
  Duration: 00:03:49.96, start: 0.000000, bitrate: 797 kb/s
    Stream #0:0(und): Video: h264 (High) (avc1 / 0x31637661), yuv420p(tv, bt709), 640x360 [SAR 1:1 DAR 16:9], 694 kb/s, 24 fps, 24 tbr, 12288 tbn, 48 tbc (default)
    Metadata:
      handler_name    : VideoHandler
    Stream #0:1(und): Audio: aac (LC) (mp4a / 0x6134706D), 44100 Hz, stereo, fltp, 96 kb/s (default)
    Metadata:
      handler_name    : ZA Media Handler by Zalo Group

- Chuyển đổi định dạng audio/video

ffmpeg cho phép chuyển đổi định dạng video/audio sang định dạng khác, hoặc chuyển video thành audio một cách nhanh chóng.

Ví dụ chuyển tệp mp4 sang avi

`ffmpeg -i video.mp4 video.avi`

Sử dụng tùy chọn tham số `-qscale 0` nếu muốn giữ nguyên chất lượng video sau khi convert

`ffmpeg -i input.webm -qscale 0 output.mp4`

- Chuyển đổi tệp video sang audio

ví dụ:

`ffmpeg -i input.mp4 -vn -ab 320 output.mp3`

Có nhiều tham số để có thể sử dụng trong quá trình transcode, ví dụ như:

`ffmpeg -i input.mp4 -vn -ar 44100 -ac 2 -ab 320 -f mp3 output.mp3`

- Chuyển đổi media sang HLS (Apple HTTP Live Streaming)

Ví dụ:

`ffmpeg -i video.mp4 -c:v h264 -flags +cgop -g 30 -hls_time 1 index.m3u8`

Khi đó ffmpeg sẽ convert tệp video.mp4 sang một danh sách (playlist), mà phân đoạn thành nhiều tệp. Tên tệp output chỉ định tên tệp playlist (hay tệp .m3u8). Với mỗi phân đoạn trong quá trình convert sẽ thành một tệp, với số tuần tự và có đuôi mở rộng là .ts
Một số tham số kết hợp trong quá trình convert tệp video sang định dạng HLS tham khảo thêm tại: [https://www.ffmpeg.org/ffmpeg-formats.html#hls-1](https://www.ffmpeg.org/ffmpeg-formats.html#hls-1)

- Thay đổi độ phân giải video

`ffmpeg -i input.mp4 -s 1280x720 -c:a copy output.mp4`

- Gỡ audio từ tệp media

`ffmpeg -i input.mp4 -an output.mp4`

- Gỡ video từ tệp media

`ffmpeg -i input.mp4 -vn output.mp3`

…

Tham khảo thêm tại:
[https://trac.ffmpeg.org/wiki/CompilationGuide/Centos](https://trac.ffmpeg.org/wiki/CompilationGuide/Centos)
[https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu](https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu)
[https://techouse.co.in/ffmpeg-installation-in-linux/techouse/](https://techouse.co.in/ffmpeg-installation-in-linux/techouse/)
