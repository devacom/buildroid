# buildroid
This Script is created to help no developer for making some binaries targeting Android devices.
The supported source code are listed below:

OpenSSL

Curl

LibUSB

OSCam

nghttp2

This tool has configured to make cross compiling using this variable.
TOOLCHAIN=/android-toolchain
CROSS_SYSROOT=$TOOLCHAIN/sysroot
PATH=$TOOLCHAIN/bin:$PATH

That mean the installed binary or lib will be found in /android-toolchain/sysroot

This projet under developing and more feature maybe add in the future.
