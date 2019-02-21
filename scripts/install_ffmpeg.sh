#!/bin/bash
#KeepWalking86
#Scripting for installing FFmpeg on CentOS/Ubuntu-16.04+

# Check root account
if [ $UID -ne 0 ] ; then
        echo "Please, run this script as root account!"
        exit 1
fi

# Directory to contain FFmpeg sources 
mkdir ~/ffmpeg_sources

# Check OS and install essential package to compile
if [ -f /etc/debian_version ] ; then
        apt-get update -qq
        apt-get -y install autoconf automake build-essential cmake git-core libass-dev \
        libfreetype6-dev libsdl2-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev \
        libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo wget zlib1g-dev
	#Install NASM
	wget -O nasm_2.14.deb http://ftp.br.debian.org/debian/pool/main/n/nasm/nasm_2.14-1_amd64.deb
	dpkg --install nasm_2.14.deb
        #Install YASM
        apt-get -y install yasm
        #libx264
        apt-get -y install libx264-dev
        #libx265
        apt-get -y install libx265-dev libnuma-dev
        #libvpx
        apt-get -y install libvpx-dev
        #libfdk-aac
        apt-get -y install libfdk-aac-dev
        #libmp3lame
        apt-get -y install libmp3lame-dev
        #libopus
        apt-get -y install libopus-dev       

else
	if [ -f /etc/redhat-release ] ; then
		yum -y install autoconf automake bzip2 bzip2-devel cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel
		#Install NASM
		wget -O nasm-2.13.rpm http://download-ib01.fedoraproject.org/pub/fedora/linux/updates/27/x86_64/Packages/n/nasm-2.13.02-1.fc27.x86_64.rpm
		rpm -ivh nasm-2.13.rpm
                # YASM
                cd ~/ffmpeg_sources
                curl -O -L http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
                tar xzvf yasm-1.3.0.tar.gz
                cd yasm-1.3.0
                ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
                make
                make install

                # libx264
                cd ~/ffmpeg_sources
                git clone --depth 1 http://git.videolan.org/git/x264
                cd x264
                PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
                make
                make install

                # libx265
                cd ~/ffmpeg_sources
                hg clone https://bitbucket.org/multicoreware/x265
                cd ~/ffmpeg_sources/x265/build/linux
                cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
                make
                make install

                # libfdk_aac
                cd ~/ffmpeg_sources
                git clone --depth 1 https://github.com/mstorsjo/fdk-aac
                cd fdk-aac
                autoreconf -fiv
                ./configure --prefix="$HOME/ffmpeg_build" --disable-shared
                make
                make install

                # libmp3lame
                cd ~/ffmpeg_sources
                curl -O -L https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
                tar xzvf lame-3.100.tar.gz
                cd lame-3.100
                ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --disable-shared --enable-nasm
                make
                make install

                # libopus
                cd ~/ffmpeg_sources
                curl -O -L https://archive.mozilla.org/pub/opus/opus-1.3.tar.gz
                tar xzvf opus-1.3.tar.gz
                cd opus-1.3
                ./configure --prefix="$HOME/ffmpeg_build" --disable-shared
                make
                make install

                # libvpx
                cd ~/ffmpeg_sources
                git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
                cd libvpx
                ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
                make
                make install
	else
		echo "Distro hasn't been supported by this script"
	        exit 1
	fi
fi

# Install FFmpeg
echo "Installing FFmpeg"
sleep 3
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
ln -s /root/bin/ffmpeg /usr/bin/ffmpeg