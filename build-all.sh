#!/bin/bash
VERSION=$1
FILE_VERSION=$2

# ./build-godot.sh mono-glue
echo "windows macos ubuntu_32 ubuntu_64 android javascript" | xargs -P2 -n1 -I{} ./build-godot.sh {} $2

echo "$1" > templates/version.txt

mkdir -p release-$2
rm -f release-$2/*templates.tpz
zip -q -9 -r release-$1/Godot_v$2_export_templates.tpz templates

