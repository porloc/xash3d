#!/bin/bash

# Build custom SDL2

cd $TRAVIS_BUILD_DIR/SDL2-2.0.6
CC="ccache gcc -msse2 -march=i686 -m32 -ggdb -O2" ./configure --disable-dependency-tracking --enable-audio --enable-video --enable-events --disable-render --enable-joystick --disable-haptic --disable-power --enable-threads --enable-timers --enable-loadso --enable-video-opengl --enable-x11-shared --enable-video-x11 --enable-video-x11-xrandr --enable-video-x11-scrnsaver --enable-video-x11-xinput --disable-video-x11-xshape --disable-video-x11-xdbe --disable-libudev --disable-dbus --disable-ibus --enable-sdl-dlopen --disable-video-opengles --disable-cpuinfo --disable-assembly --disable-atomic --enable-alsa
make -j2
mkdir -p $TRAVIS_BUILD_DIR/sdl2-linux
make install DESTDIR=$TRAVIS_BUILD_DIR/sdl2-linux

# Build engine

cd $TRAVIS_BUILD_DIR
mkdir -p build && cd build/
CC="ccache gcc" CXX="ccache g++" CFLAGS="-m32" CXXFLAGS="-m32" cmake -DCMAKE_PREFIX_PATH=$TRAVIS_BUILD_DIR/sdl2-linux/usr/local -DXASH_STATIC=ON -DXASH_DLL_LOADER=ON -DXASH_VGUI=yes -DMAINUI_USE_STB=yes -DHL_SDK_DIR=$TRAVIS_BUILD_DIR/vgui-dev -DXASH_AUTODETECT_SSE_BUILD=OFF ../
make -j2
cp engine/xash mainui/libxashmenu.so vgui_support/libvgui_support.so vgui_support/vgui.so .
cp $TRAVIS_BUILD_DIR/sdl2-linux/usr/local/lib/$(readlink $TRAVIS_BUILD_DIR/sdl2-linux/usr/local/lib/libSDL2-2.0.so.0) libSDL2-2.0.so.0
7z a -t7z $TRAVIS_BUILD_DIR/xash3d-linux.7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on xash libSDL2-2.0.so.0 libvgui_support.so vgui.so libxashmenu.so