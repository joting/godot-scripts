"C:\Program Files\Git\bin\bash.exe" checkout-godot-windows.sh
set BUILD_NAME=official
set MONO32_PREFIX=C:\Program Files (x86)/Mono
set MONO64_PREFIX=C:\Program Files\Mono
set SCONS=python ../scons/scons.py -j8 verbose=no warnings=no progress=no
set OPTIONS=builtin_libpng=yes builtin_openssl=yes builtin_zlib=yes gdnative_wrapper=yes debug_symbols=no
set TERM=xterm 

rd /s /q binaries
md binaries
cd godot

copy ..\mono-glue\*.* modules\mono\glue

del /F /Q bin\*.*
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64
%SCONS% platform=windows %OPTIONS% tools=yes target=release_debug use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release_debug  use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release  use_lto=yes

%SCONS% platform=windows %OPTIONS% tools=yes target=release_debug module_mono_enabled=yes mono_static=yes use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release_debug module_mono_enabled=yes mono_static=yes use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release module_mono_enabled=yes mono_static=yes use_lto=yes

md ..\binaries\win_amd64
copy bin\*.* ..\binaries\win_amd64

del /F /Q bin\*.*
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64_x86
%SCONS% platform=windows %OPTIONS% tools=yes target=release_debug use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release_debug  use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release  use_lto=yes

%SCONS% platform=windows %OPTIONS% tools=yes target=release_debug module_mono_enabled=yes mono_static=yes use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release_debug module_mono_enabled=yes mono_static=yes use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release module_mono_enabled=yes mono_static=yes use_lto=yes

md ..\binaries\win_x86
copy bin\*.* ..\binaries\win_x86

cd ..

curl\curl.exe -O -L https://github.com/GodotBuilder/godot-builds/releases/download/_tools/angle.7z
"c:\Program Files\7-Zip\7z.exe" x -aoa angle.7z
set ANGLE_SRC_PATH=%cd%\angle

cd godot

del /F /Q bin\*.*
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64 uwp
%SCONS% platform=uwp %OPTIONS% tools=no target=release_debug use_lto=yes
%SCONS% platform=uwp %OPTIONS% tools=no target=release use_lto=yes

md ..\binaries\uwp_amd64
copy bin\*.* ..\binaries\uwp_amd64

del /F /Q bin\*.*
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64_x86 uwp
%SCONS% platform=uwp %OPTIONS% tools=no target=release_debug use_lto=yes
%SCONS% platform=uwp %OPTIONS% tools=no target=release use_lto=yes

md ..\binaries\uwp_x86
copy bin\*.* ..\binaries\uwp_x86

del /F /Q bin\*.*
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64_arm uwp
%SCONS% platform=uwp %OPTIONS% tools=no target=release_debug use_lto=yes
%SCONS% platform=uwp %OPTIONS% tools=no target=release use_lto=yes

md ..\binaries\uwp_arm
copy bin\*.* ..\binaries\uwp_arm
