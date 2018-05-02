#!/bin/bash

set -e

export BUILD_NAME=official
export OPTIONS="builtin_libpng=yes builtin_openssl=yes builtin_zlib=yes gdnative_wrapper=yes debug_symbols=no"
export SCONS="scons -j8 verbose=no warnings=no progress=no"

export MONO32_PREFIX=/Library/Frameworks/Mono.framework/Versions/5.8.1/
export MONO64_PREFIX=/Library/Frameworks/Mono.framework/Versions/5.8.1/

export PATH=/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Frameworks/Mono.framework/Versions/Current/Commands

brew update
brew install scons

rm -rf godot
git clone https://github.com/godotengine/godot.git

cd godot
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git checkout -b 3.0 origin/3.0 || git checkout 3.0
git branch --set-upstream-to=origin/3.0 3.0
git reset --hard
git pull

cp ../mono-glue/* modules/mono/glue

$SCONS platform=osx bits=fat $OPTIONS tools=yes target=release_debug use_static_cpp=yes use_lto=yes
$SCONS platform=osx bits=fat $OPTIONS tools=no target=release_debug use_static_cpp=yes use_lto=yes
$SCONS platform=osx bits=fat $OPTIONS tools=no target=release use_static_cpp=yes use_lto=yes

$SCONS platform=osx bits=fat $OPTIONS tools=yes target=release_debug use_static_cpp=yes module_mono_enabled=yes mono_static=yes use_lto=yes
$SCONS platform=osx bits=fat $OPTIONS tools=no target=release_debug use_static_cpp=yes module_mono_enabled=yes mono_static=yes use_lto=yes
$SCONS platform=osx bits=fat $OPTIONS tools=no target=release use_static_cpp=yes module_mono_enabled=yes mono_static=yes use_lto=yes

$SCONS platform=iphone arch=arm $OPTIONS tools=no target=release_debug use_lto=yes
$SCONS platform=iphone arch=arm $OPTIONS tools=no target=release use_lto=yes
$SCONS platform=iphone arch=arm64 $OPTIONS tools=no target=release_debug use_lto=yes
$SCONS platform=iphone arch=arm64 $OPTIONS tools=no target=release use_lto=yes
$SCONS platform=iphone arch=x86 $OPTIONS tools=no target=release_debug use_lto=yes
$SCONS platform=iphone arch=x86 $OPTIONS tools=no target=release use_lto=yes

lipo -create bin/libgodot.iphone.opt.arm.a bin/libgodot.iphone.opt.arm64.a bin/libgodot.iphone.opt.x86.a -output bin/libgodot.iphone.opt.fat
lipo -create bin/libgodot.iphone.opt.debug.arm.a bin/libgodot.iphone.opt.debug.arm64.a bin/libgodot.iphone.opt.debug.x86.a -output bin/libgodot.iphone.opt.debug.fat
