#!/bin/bash

set -e

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "usage: $0 <version> <file version> <mono version>"
  echo "  like : $0 3.0.3.rc1 3.0.3-rc1 5.12.0.226"
  exit 1
fi

VERSION=$1
FILE_VERSION=$2
MONO_VERSION=$3

./build-godot.sh ${FILE_VERSION} ${MONO_VERSION}  mono-glue
echo "uwp windows macos ubuntu_32 ubuntu_64 android javascript" | xargs -P 2 -n 1 ./build-godot.sh ${FILE_VERSION} ${MONO_VERSION}

./build-templates.sh ${VERSION} ${FILE_VERSION}

pushd godot-mono-glue
git archive --format=tar $FILE_VERSION --prefix=godot-$FILE_VERSION/ | xz -c > ../release-$FILE_VERSION/godot-$FILE_VERSION.tar.xz
popd
sha256sum release-$FILE_VERSION/godot-$FILE_VERSION.tar.xz > release-$FILE_VERSION/godot-$FILE_VERSION.tar.xz.sha256
