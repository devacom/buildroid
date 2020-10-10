#!/usr/bin/bash
# Buildroid alpha
# This Script is created to help no developer for making some binaries targeting Android devices.
# Created by @devacom

echo "Note:"
echo "Android toolchain is needed to be installed on your machine."
echo "If this is the first time to use this script or you want to change the targeted android choose y"
read -p "Do you want to set your android toolchan? [y/n] " response
   case "$response" in
     [yY][eE][sS]|[yY]) 
     read -p "Please enter your NDK toolchain location: " fpath
     cd $fpath/build/tools
     # ex: /home/username/android-ndk-r14b/
     export TOOLCHAIN=/android-toolchain
     read -p "Please enter your api level (ex: for lollipop 5.0 – 5.1.1 api is 21 and 22): " apilevel
     sudo ./make_standalone_toolchain.py --arch arm --api $apilevel --install-dir /android-toolchain --force
     ;;
     *)
     echo "Installation is aborted by user, nothing is done".
     ;;
   esac


dir=$(pwd -P)
HEIGHT=12
WIDTH=50
CHOICE_HEIGHT=6
BACKTITLE="Android ARM Cross Compilation Tool"
TITLE="Menu"
MENU="Choose one of the following options:"
OPTIONS=(1 "OpenSSL"
         2 "nghttp2"
         3 "Curl"
         4 "libusb"
         5 "OSCam")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

basetoolchain () {
export TOOLCHAIN=/android-toolchain
export CROSS_SYSROOT=$TOOLCHAIN/sysroot
export PATH=$TOOLCHAIN/bin:$PATH
export TOOL=arm-linux-androideabi
export CC=$TOOLCHAIN/bin/${TOOL}-gcc
export CXX=$TOOLCHAIN/bin/${TOOL}-g++
export LINK=${CXX}
export LD=$TOOLCHAIN/bin/${TOOL}-ld
export AR=$TOOLCHAIN/bin/${TOOL}-ar
export RANLIB=$TOOLCHAIN/bin/${TOOL}-ranlib
export STRIP=$TOOLCHAIN/bin/${TOOL}-strip
export ARCH_FLAGS="-mthumb"
}

case $CHOICE in
     1)
     # build openssl
     echo "OpenSSL Android Build Tool"
     read -p "Please set source code location: " fpath
     cd $fpath
     echo "configuring OpenSSL for ARM android..."
     basetoolchain
     export ARCH_LINK=
     export CFLAGS="${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64"
     export CXXFLAGS="${CFLAGS} -frtti -fexceptions"
     export LDFLAGS="${ARCH_LINK}"
     export ARCH_FLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
     export CFLAGS="${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64"
     export ARCH_LINK="-march=armv7-a -Wl,--fix-cortex-a8"
     export LDFLAGS="${ARCH_LINK}"
     
     ./Configure android-arm \
     --prefix=$TOOLCHAIN/sysroot/usr/local \
     --with-zlib-include=$TOOLCHAIN/sysroot/usr/include \
     --with-zlib-lib=$TOOLCHAIN/sysroot/usr/lib \
     zlib \
     no-asm \
     no-shared \
     no-unit-test
     
     make
     make install
        ;;
#---------------------------------------------
     2)
     # build nghhtp2	
     
     read -p "Please set source code location: " fpath
     cd $fpath
     basetoolchain
     export CPPFLAGS="-fPIE -I$TOOLCHAIN/sysroot/usr/include"
     export LDFLAGS="-fPIE -pie -I$TOOLCHAIN/sysroot/usr/lib"
     export PKG_CONFIG_LIBDIR=$TOOLCHAIN/lib/pkgconfig
     autoreconf -i
     ./configure --enable-lib-only \
     --host=arm-linux-androideabi \
     --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
     --disable-shared \
     --prefix="$TOOLCHAIN/sysroot/usr/local"
     make
     sudo make install
        ;;
#---------------------------------------------
     3)
     # build curl
     echo "Curl Android Build Tool"
     read -p "Please set source code location: " fpath
     cd $fpath
     echo "configuring Curl for android..."
     basetoolchain
     export CFLAGS="-fPIE fPIC"
     export LDFLAGS="-pie"
     ./configure --prefix=$TOOLCHAIN/sysroot/usr/local \
     --with-sysroot=$TOOLCHAIN/sysroot \
     --host=arm-linux-androideabi \
     --with-ssl=$TOOLCHAIN/sysroot/usr/local \
     --with-nghttp2=$TOOLCHAIN/sysroot/usr/local \
     --enable-static \
     --enable-threaded-resolver \
     --disable-dict \
     --disable-gopher \
     --disable-ldap --disable-ldaps \
     --disable-manual \
     --disable-pop3 --disable-smtp --disable-imap \
     --disable-rtsp \
     --disable-shared \
     --disable-smb \
     --disable-telnet \
     --disable-verbose
     
     sudo make install
     
        ;;
#-----------------------------------------------
      4)
      echo "libusb Android Build Tool"
      read -p "Please set source code location: " fpath
      cd $fpath
      echo "configuring libusb for android..."
      basetoolchain
      #export CFLAGS="-fPIE -fPIC"
      export CFLAGS="-fPIE fPIC"
      export LDFLAGS="-pie"
      ./configure --prefix=$TOOLCHAIN/sysroot/usr/local \
      --host=arm-linux-androideabi \
      --enable-shared=no
      make 
      sudo make install
        ;;
#--------------------------------------
      5)
      echo "OSCam Android Build Tool"
      read -p "Please set source code location: " fpath
        cd $fpath
        echo "Creating oscam.."
        ./config.sh --gui
        read -p "do you want to add libusb support? [y/n] " response
        case "$response" in
          [yY][eE][sS]|[yY]) 
          make static EXTRA_FLAGS="-pie" LIB_RT= LIB_PTHREAD= USE_LIBUSB=1 CROSS=/android-toolchain/bin/arm-linux-androideabi-
          ;;
          *)
          make static EXTRA_FLAGS="-pie" LIB_RT= LIB_PTHREAD= CROSS=/android-toolchain/bin/arm-linux-androideabi-
          ;;
        esac
        echo "done."
      ;;       
esac
