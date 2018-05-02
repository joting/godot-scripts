#!/bin/bash
set -e

export OPTIONS="builtin_libpng=yes builtin_openssl=yes builtin_zlib=yes gdnative_wrapper=yes debug_symbols=no"
export SSHOPTS="-i /home/hp/.ssh/id_rsa "
export GODOT_VERSION=$2

function mono-glue {
  rm -rf godot-mono-glue
  git clone https://github.com/godotengine/godot.git godot-mono-glue

  cd godot-mono-glue
  git checkout -b 3.0 origin/3.0 || git checkout 3.0
  git branch --set-upstream-to=origin/3.0 3.0
  git reset --hard
  git pull
  
  TERM=xterm /usr/bin/scons platform=x11 bits=64 -j16 ${OPTIONS} target=release_debug tools=yes module_mono_enabled=yes mono_glue=no CXXFLAGS="-I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include/ -Wno-parentheses"
  bin/godot.x11.opt.tools.64.mono --generate-mono-glue modules/mono/glue

  cd ..
  rm -rf mono-glue
  mkdir mono-glue
  cp godot-mono-glue/modules/mono/glue/cs_compressed.gen.h godot/modules/mono/glue/mono_glue.gen.cpp mono-glue
}

function ubuntu_32 {
  echo "booting ubuntu 32 "
#  mkdir -p godot-ubuntu-32
#  sudo virsh start godot-ubuntu14.04-32 || /bin/true
#
#  while ! tcping -t 1 192.168.112.183 22 :>/dev/null; do
#    sleep 1
#  done
#
#  sleep 30s
#
#  scp $SSHOPTS build-godot-ubuntu-32.sh user@192.168.112.183:~/build-godot.sh
#  scp $SSHOPTS -r mono-glue user@192.168.112.183:~/
#  ssh $SSHOPTS user@192.168.112.183 bash build-godot.sh
#  scp $SSHOPTS user@192.168.112.183:~/godot/bin/* godot-ubuntu-32
#  ssh $SSHOPTS user@192.168.112.183 sudo shutdown -h now || /bin/true

  mkdir -p templates
  rm linux_x11_32*

  cp godot-ubuntu-32/godot.x11.opt.debug.32 templates/linux_x11_32_debug
  cp godot-ubuntu-32/godot.x11.opt.32 templates/linux_x11_32_release
}

function ubuntu_64 {
  echo "booting ubuntu 64 "
#  mkdir -p godot-ubuntu-64
#  sudo virsh start godot-ubuntu14.04-64 || /bin/true
#
#  while ! tcping -t 1 192.168.112.195 22 &>/dev/null; do
#    sleep 1
#  done
#
#  sleep 30s
#
#  scp $SSHOPTS build-godot-ubuntu-64.sh user@192.168.112.195:~/build-godot.sh
#  scp $SSHOPTS -r mono-glue user@192.168.112.195:~/
#  ssh $SSHOPTS user@192.168.112.195 bash build-godot.sh
#  scp $SSHOPTS user@192.168.112.195:~/godot/bin/* godot-ubuntu-64
#  ssh $SSHOPTS user@192.168.112.195 sudo shutdown -h now || /bin/true

  mkdir -p templates
  rm linux_x11_64*

  cp godot-ubuntu-64/godot.x11.opt.debug.64 templates/linux_x11_64_debug
  cp godot-ubuntu-64/godot.x11.opt.64 templates/linux_x11_64_release
} 

function windows {
  echo "booting windows "
  mkdir -p godot-windows
  #sudo virsh start win10 || /bin/true
#
#  while ! tcping -t 1 192.168.112.158 22 &>/dev/null; do
#    sleep 1
#  done
#
#  sleep 30s
#
#  scp $SSHOPTS checkout-godot-windows.sh build-godot-windows.bat hp@192.168.112.158:
#  scp $SSHOPTS -r mono-glue hp@192.168.112.158:
#
#  ssh $SSHOPTS hp@192.168.112.158 build-godot-windows.bat
#  scp $SSHOPTS -r hp@192.168.112.158:binaries/* godot-windows
#  ssh $SSHOPTS hp@192.168.112.158 "shutdown /s /t 0" || /bin/true

  mkdir -p templates 
  rm -f templates/uwp*
  rm -f templates/windows*

  rm -rf angle*
  wget -c https://github.com/GodotBuilder/godot-builds/releases/download/_tools/angle.7z
  7z x angle.7z

  rm -rf uwp_template_*
  
  for arch in ARM Win32 x64; do
    cp -r godot-mono-glue/misc/dist/uwp_template uwp_template_${arch}

    cp angle/winrt/10/src/Release_${arch}/libEGL.dll \
       angle/winrt/10/src/Release_${arch}/libGLESv2.dll \
       uwp_template_${arch}/
    cp -r uwp_template_${arch} uwp_template_${arch}_debug
  done

  # ARM
  cp godot-windows/uwp_arm/godot.uwp.opt.32.arm.exe uwp_template_ARM/godot.uwp.exe
  cp godot-windows/uwp_arm/godot.uwp.opt.debug.32.arm.exe uwp_template_ARM_debug/godot.uwp.exe
  cd uwp_template_ARM && zip -q -9 -r ../templates/uwp_arm_release.zip * && cd ..
  cd uwp_template_ARM_debug && zip -q -9 -r ../templates/uwp_arm_debug.zip * && cd ..

  # Win32
  cp godot-windows/uwp_x86/godot.uwp.opt.32.x86.exe uwp_template_Win32/godot.uwp.exe
  cp godot-windows/uwp_x86/godot.uwp.opt.debug.32.x86.exe uwp_template_Win32_debug/godot.uwp.exe
  cd uwp_template_Win32 && zip -q -9 -r ../templates/uwp_x86_release.zip * && cd ..
  cd uwp_template_Win32_debug && zip -q -9 -r ../templates/uwp_x86_debug.zip * && cd ..

  cp godot-windows/win_x86/godot.windows.opt.debug.32.exe templates/windows_32_debug.exe
  cp godot-windows/win_x86/godot.windows.opt.32.exe templates/windows_32_release.exe

  # x64
  cp godot-windows/uwp_amd64/godot.uwp.opt.64.x64.exe uwp_template_x64/godot.uwp.exe
  cp godot-windows/uwp_amd64/godot.uwp.opt.debug.64.x64.exe uwp_template_x64_debug/godot.uwp.exe
  cd uwp_template_x64 && zip -q -9 -r ../templates/uwp_x64_release.zip * && cd ..
  cd uwp_template_x64_debug && zip -q -9 -r ../templates/uwp_x64_debug.zip * && cd ..

  cp godot-windows/win_amd64/godot.windows.opt.debug.64.exe templates/windows_64_debug.exe
  cp godot-windows/win_amd64/godot.windows.opt.64.exe templates/windows_64_release.exe

  rm -rf uwp_template_*

  mkdir -p release-${GODOT_VERSION}
  rm -f release-${GODOT_VERSION}/*win*zip

  cp godot-windows/win_amd64/godot.windows.opt.tools.64.exe Godot_v${GODOT_VERSION}_win64.exe
  zip -q -9 Godot_v${GODOT_VERSION}_win64.exe.zip Godot_v${GODOT_VERSION}_win64.exe
  mv Godot_v${GODOT_VERSION}_win64.exe.zip release-${GODOT_VERSION}
  rm Godot_v${GODOT_VERSION}_win64.exe

  cp godot-windows/win_x86/godot.windows.opt.tools.32.exe Godot_v${GODOT_VERSION}_win32.exe
  zip -q -9 Godot_v${GODOT_VERSION}_win32.exe.zip Godot_v${GODOT_VERSION}_win32.exe
  mv Godot_v${GODOT_VERSION}_win32.exe.zip release-${GODOT_VERSION}
  rm Godot_v${GODOT_VERSION}_win32.exe
} 

function macos {
  echo "booting macosx"
  mkdir -p godot-macosx
#  sudo bash /media/disk2/hp/macosx/OSX-KVM/godot.sh || /bin/true
#
#  while ! tcping -t 1 192.168.112.137 22 &>/dev/null; do
#    sleep 1
#  done
# 
#  sleep 30s
#  
#  scp $SSHOPTS build-godot-macosx.sh hp@192.168.112.137:~/build-godot.sh
#  scp $SSHOPTS -r mono-glue hp@192.168.112.137:~/
#  ssh $SSHOPTS hp@192.168.112.137 bash build-godot.sh
#  scp $SSHOPTS hp@192.168.112.137:~/godot/bin/* godot-macosx
#  ssh $SSHOPTS hp@192.168.112.137 sudo shutdown -h now || /bin/true

  mkdir -p templates
  rm -f templates/osx*
  rm -f templates/iphone*

  rm -rf osx_template
  mkdir -p osx_template
  cd osx_template

  cp -r ../godot-mono-glue/misc/dist/osx_template.app .
  mkdir osx_template.app/Contents/MacOS

  cp ../godot-macosx/godot.osx.opt.fat osx_template.app/Contents/MacOS/godot_osx_release.fat
  cp ../godot-macosx/godot.osx.opt.debug.fat osx_template.app/Contents/MacOS/godot_osx_debug.fat
  chmod +x osx_template.app/Contents/MacOS/godot_osx*
  zip -q -9 -r osx.zip osx_template.app
  cd ..
  
  mv osx_template/osx.zip templates
  rm -rf osx_template

  cp -r godot-mono-glue/misc/dist/ios_xcode ios_xcode
  cp godot-macosx/libgodot.iphone.opt.fat ios_xcode/libgodot.iphone.release.fat.a
  cp godot-macosx//libgodot.iphone.opt.debug.fat ios_xcode/libgodot.iphone.debug.fat.a
  chmod +x ios_xcode/libgodot.iphone.*
  cd ios_xcode
  zip -q -9 -r ../templates/iphone.zip *
  cd ..
  rm -rf ios_xcode
}

function android {
  export ANDROID_HOME=/home/hp/Apps/android/sdk/
  export ANDROID_NDK_ROOT=/home/hp/Apps/android/android-ndk-r16b
  export SCONS="/usr/bin/scons -j8 verbose=no warnings=no progress=no"
  export OPTIONS="builtin_libpng=yes builtin_openssl=yes builtin_zlib=yes gdnative_wrapper=yes debug_symbols=no"
#
#  rm -rf godot-android
#  git clone https://github.com/godotengine/godot.git godot-android
#
#  cd godot-android
#  git checkout -b 3.0 origin/3.0 || git checkout 3.0
#  git branch --set-upstream-to=origin/3.0 3.0
#  git reset --hard
#  git pull
#
#  $SCONS platform=android target=release_debug tools=no ${OPTIONS} android_arch=armv7
#  $SCONS platform=android target=release_debug tools=no ${OPTIONS} android_arch=arm64v8
#  $SCONS platform=android target=release_debug tools=no ${OPTIONS} android_arch=x86
#
#  $SCONS platform=android target=release tools=no ${OPTIONS} android_arch=armv7
#  $SCONS platform=android target=release tools=no ${OPTIONS} android_arch=arm64v8
#  $SCONS platform=android target=release tools=no ${OPTIONS} android_arch=x86
#
#  cd platform/android/java
#  ./gradlew build
#  cd ../../../

  mkdir -p templates
  rm -f templates/android*

  cp godot-android/bin/android_debug.apk templates
  cp godot-android/bin/android_release.apk templates
}

function javascript {
#  export EMSCRIPTEN_ROOT="/home/hp/Apps/emsdk-portable/emscripten/1.37.34"
#  export SCONS="/usr/bin/scons -j8 verbose=no warnings=no progress=no"
#  export OPTIONS="builtin_libpng=yes builtin_openssl=yes builtin_zlib=yes gdnative_wrapper=yes debug_symbols=no"
#
#  rm -rf godot-javascript
#  git clone https://github.com/godotengine/godot.git godot-javascript
#
#  cd godot-javascript
#  git checkout -b 3.0 origin/3.0 || git checkout 3.0
#  git branch --set-upstream-to=origin/3.0 3.0
#  git reset --hard
#  git pull
#
#  $SCONS platform=javascript target=release_debug tools=no ${OPTIONS}
#  $SCONS platform=javascript target=release tools=no ${OPTIONS}
#  cd ..

  mkdir -p templates
  rm -f templates/webassembly*

  cp godot-javascript/bin/godot.javascript.opt.zip templates/webassembly_release.zip
  cp godot-javascript/bin/godot.javascript.opt.debug.zip templates/webassembly_debug.zip
}


$1
