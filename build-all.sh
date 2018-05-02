#!/bin/bash

if [ -z "$1" ]; then
  echo "usage: $0 <version> <file version>"
  echo "  like : $0 3.0.3.rc1 3.0.3-rc1"
  exit 1
fi

if [ -z "$2" ]; then
  echo "usage: $0 <version> <file version>"
  echo "  like : $0 3.0.3.rc1 3.0.3-rc1"
  exit 1
fi

VERSION=$1
FILE_VERSION=$2

./build-godot.sh mono-glue
echo "windows macos ubuntu_32 ubuntu_64 android javascript" | xargs -P 2 -n 1 ./build-godot.sh ${FILE_VERSION}

echo "$VERSION" > templates/version.txt

mkdir -p release-${FILE_VERSION}
rm -f release-${FILE_VERSION}/*templates.tpz
zip -q -9 -r release-${FILE_VERSION}/Godot_v${FILE_VERSION}_export_templates.tpz templates

mkdir -p mono/release-${FILE_VERSION}
rm -f mono/release-${FILE_VERSION}/*templates.tpz
cd mono
echo "$VERSION".mono > templates/version.txt
zip -q -9 -r release-${FILE_VERSION}/Godot_v${FILE_VERSION}_mono_export_templates.tpz templates
cd ..
