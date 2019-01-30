#!/bin/bash

set -e

export BUILD_NAME=official
export OPTIONS="builtin_libpng=yes builtin_openssl=yes builtin_zlib=yes gdnative_wrapper=yes debug_symbols=no"
export SCONS="scons -j2 verbose=no warnings=no progress=no"

#brew update
#brew install scons

build()
{
  rm -rf godot
  git clone https://github.com/godotengine/godot.git

  cd godot
  git checkout tags/$FILE_VERSION
  git reset --hard

  $SCONS platform=iphone arch=arm $OPTIONS tools=no target=release_debug
  $SCONS platform=iphone arch=arm $OPTIONS tools=no target=release
  $SCONS platform=iphone arch=arm64 $OPTIONS tools=no target=release_debug
  $SCONS platform=iphone arch=arm64 $OPTIONS tools=no target=release
  $SCONS platform=iphone arch=x86 $OPTIONS tools=no target=release_debug

  lipo -create bin/libgodot.iphone.opt.arm.a bin/libgodot.iphone.opt.arm64.a -output bin/libgodot.iphone.opt.fat
  lipo -create bin/libgodot.iphone.opt.debug.arm.a bin/libgodot.iphone.opt.debug.arm64.a bin/libgodot.iphone.opt.debug.x86.a -output bin/libgodot.iphone.opt.debug.fat
  cd ..
}

create_template()
{
  PACK_TMP=temp
  rm -rf $PACK_TMP
  mkdir -p templates
  rm -f templates/iphone*
  cp -r ios_xcode $PACK_TMP
  cp godot/bin/libgodot.iphone.opt.fat $PACK_TMP/libgodot.iphone.release.fat.a
  cp godot/bin/libgodot.iphone.opt.debug.fat $PACK_TMP/libgodot.iphone.debug.fat.a
  chmod +x $PACK_TMP/libgodot.iphone.*
  cd $PACK_TMP
  zip -q -9 -r ../templates/iphone.zip *
  cd ..
  rm -rf $PACK_TMP
}

pack()
{
  echo "$VERSION" > templates/version.txt
  mkdir -p packed-${FILE_VERSION}
  rm -f packed-${FILE_VERSION}/*templates.tpz
  zip -q -9 -r -D packed-${FILE_VERSION}/Godot_v${FILE_VERSION}_custom_export_templates.tpz templates
}

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "usage: $0 <version> <file version>"
  echo "  like : $0 3.0.6.stable 3.0.6-stable"
  exit 1
fi

export VERSION=$1
export FILE_VERSION=$2

#build 
create_template
pack