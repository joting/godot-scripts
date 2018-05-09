#!/bin/bash

set -e

if [ ! -e /etc/apt/sources.list.d/mono-official-stable.list ]; then
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
  sudo apt-get install -y apt-transport-https
  echo "deb https://download.mono-project.com/repo/ubuntu trusty/snapshots/5.10.1.47 main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
fi

if [ ! -e  /etc/apt/sources.list.d/ubuntu-toolchain-r-test-trusty.list ]; then
  sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
fi

sudo apt-get update -qq
sudo apt-get install -y gcc-8 g++-8 libx11-dev libxcursor-dev libxrandr-dev libasound2-dev libpulse-dev libfreetype6-dev libgl1-mesa-dev libglu1-mesa-dev libxi-dev libxinerama-dev git scons mono-complete msbuild
sudo apt-get remove -y yasm

export BUILD_NAME=official
export OPTIONS="builtin_libpng=yes builtin_openssl=yes builtin_zlib=yes gdnative_wrapper=yes debug_symbols=no"
export SCONS="scons -j8 verbose=no warnings=no progress=no"
export CC="gcc-8"
export CXX="g++-8"
export TERM=xterm
export MONO64_PREFIX=/usr/
export MONO32_PREFIX=/usr/

rm -rf godot
git clone https://github.com/godotengine/godot.git

cd godot
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git checkout -b 3.0 origin/3.0
git branch --set-upstream-to=origin/3.0 3.0
git reset --hard
git pull

cp ../mono-glue/* modules/mono/glue

$SCONS platform=x11 CC=$CC CXX=$CXX $OPTIONS tools=yes target=release_debug use_static_cpp=yes 
$SCONS platform=x11 CC=$CC CXX=$CXX $OPTIONS tools=no target=release_debug use_static_cpp=yes 
$SCONS platform=x11 CC=$CC CXX=$CXX $OPTIONS tools=no target=release use_static_cpp=yes 

$SCONS platform=x11 CC=$CC CXX=$CXX $OPTIONS tools=yes target=release_debug use_static_cpp=yes module_mono_enabled=yes mono_static=yes 
$SCONS platform=x11 CC=$CC CXX=$CXX $OPTIONS tools=no target=release_debug use_static_cpp=yes module_mono_enabled=yes mono_static=yes 
$SCONS platform=x11 CC=$CC CXX=$CXX $OPTIONS tools=no target=release use_static_cpp=yes module_mono_enabled=yes mono_static=yes 
