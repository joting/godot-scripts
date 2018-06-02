#!/bin/bash

set -e

if [ -z $1 ]; then
  echo "Usage: $0 <mono version"
  exit 1
fi

MONO_VERSION=$1

sudo rpm --import "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
sudo curl https://download.mono-project.com/repo/centos7-stable.repo | sudo tee /etc/yum.repos.d/mono-centos7-stable.repo

sudo dnf -y install gcc gcc-c++ scons cmake mingw32-gcc mingw32-gcc-c++ mingw64-gcc mingw64-gcc-c++ mingw64-winpthreads-static mingw32-winpthreads-static msbuild

export BUILD_NAME=official
export OPTIONS="builtin_libpng=yes builtin_openssl=yes builtin_zlib=yes gdnative_wrapper=yes debug_symbols=no"
export SCONS="scons -j8 verbose=no warnings=no progress=no"
export TERM=xterm
export MONO64_PREFIX=${HOME}/dependencies/mono-${MONO_VERSION}-64
export MONO32_PREFIX=${HOME}/dependencies/mono-${MONO_VERSION}-32

if [ ! -e ${MONO64_PREFIX} ]; then
  mkdir -p ${HOME}/dependencies
  mkdir -p ${HOME}/src
  mkdir -p ${HOME}/Downloads
  wget -c https://download.mono-project.com/sources/mono/mono-${MONO_VERSION}.tar.bz2 -O ${HOME}/Downloads/mono-${MONO_VERSION}.tar.bz2
  cd ${HOME}/src
  rm -rf mono-${MONO_VERSION}
  tar xf ${HOME}/Downloads/mono-${MONO_VERSION}.tar.bz2
  cd mono-${MONO_VERSION}
  ./configure --prefix=${MONO64_PREFIX} --disable-boehm
  make -j 8
  make install
  make distclean
  ./configure --prefix=${MONO64_PREFIX} --host=x86_64-w64-mingw32 --disable-boehm
  make -j 8 || /bin/true
  make install -i
fi

if [ ! -e ${MONO32_PREFIX} ]; then
  mkdir -p ${HOME}/dependencies
  mkdir -p ${HOME}/src
  mkdir -p ${HOME}/Downloads
  wget -c https://download.mono-project.com/sources/mono/mono-${MONO_VERSION}.tar.bz2 -O ${HOME}/Downloads/mono-${MONO_VERSION}.tar.bz2
  cd ${HOME}/src
  rm -rf mono-${MONO_VERSION}
  tar xf ${HOME}/Downloads/mono-${MONO_VERSION}.tar.bz2
  cd mono-${MONO_VERSION}
  ./configure --prefix=${MONO32_PREFIX} --disable-boehm
  make -j 8
  make install
  make distclean
  ./configure --prefix=${MONO32_PREFIX} --host=i686-w64-mingw32 --disable-boehm
  make -j 8 || /bin/true
  make install -i
fi
  

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

$SCONS platform=windows bits=32 $options tools=yes target=release_debug use_static_cpp=yes use_lto=yes
$SCONS platform=windows bits=32 $options tools=no target=release_debug use_static_cpp=yes use_lto=yes
$SCONS platform=windows bits=32 $options tools=no target=release use_static_cpp=yes use_lto=yes

$SCONS platform=windows bits=32 $options tools=yes target=release_debug use_static_cpp=yes module_mono_enabled=yes mono_static=yes use_lto=yes
$SCONS platform=windows bits=32 $options tools=no target=release_debug use_static_cpp=yes module_mono_enabled=yes mono_static=yes use_lto=yes
$SCONS platform=windows bits=32 $options tools=no target=release use_static_cpp=yes module_mono_enabled=yes mono_static=yes use_lto=yes

$SCONS platform=windows bits=64 $options tools=yes target=release_debug use_static_cpp=yes use_lto=yes
$SCONS platform=windows bits=64 $options tools=no target=release_debug use_static_cpp=yes use_lto=yes
$SCONS platform=windows bits=64 $options tools=no target=release use_static_cpp=yes use_lto=yes

$SCONS platform=windows bits=64 $options tools=yes target=release_debug use_static_cpp=yes module_mono_enabled=yes mono_static=yes use_lto=yes
$SCONS platform=windows bits=64 $options tools=no target=release_debug use_static_cpp=yes module_mono_enabled=yes mono_static=yes use_lto=yes
$SCONS platform=windows bits=64 $options tools=no target=release use_static_cpp=yes module_mono_enabled=yes mono_static=yes use_lto=yes
