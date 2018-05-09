set PATH=C:\Python36\Scripts\;C:\Python36\;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\ v1.0\;C:\ProgramData\chocolatey\bin;C:\Program Files\OpenSSH-Win64;C:\Program Files\Git\cmd;

choco list --local-only | findstr mono
IF %ERRORLEVEL% EQU 0 GOTO BUILD

net user Administrator /active:yes
choco install -y visualstudio2017buildtools visualstudio2017-workload-vctools visualstudio2017-workload-universal windows-sdk-8.1 mono git python curl 7zip 
choco install -y --force mono --x86
python -m pip install --upgrade pip
pip install -U setuptools
pip install -U wheel
pip install scons pywin32

:BUILD

rmdir /s /q godot
git clone https://github.com/godotengine/godot.git

cd godot
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git checkout -b 3.0 origin/3.0 || git checkout 3.0
git branch --set-upstream-to=origin/3.0 3.0
git reset --hard
git pull

cd ..

set BUILD_NAME=official
set MONO32_PREFIX=C:\Program Files (x86)/Mono
set MONO64_PREFIX=C:\Program Files\Mono
set SCONS=call scons -j8 verbose=no warnings=no progress=no
set OPTIONS=builtin_libpng=yes builtin_openssl=yes builtin_zlib=yes gdnative_wrapper=yes debug_symbols=no
set TERM=xterm 

rd /s /q binaries
md binaries
cd godot

copy ..\mono-glue\*.* modules\mono\glue

del /F /Q bin\*.*
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64 8.1
%SCONS% platform=windows %OPTIONS% tools=yes target=release_debug use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release_debug  use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release  use_lto=yes

%SCONS% platform=windows %OPTIONS% tools=yes target=release_debug module_mono_enabled=yes use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release_debug module_mono_enabled=yes use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release module_mono_enabled=yes use_lto=yes

md ..\binaries\win_amd64
copy bin\*.* ..\binaries\win_amd64

del /F /Q bin\*.*
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64_x86 8.1
%SCONS% platform=windows %OPTIONS% tools=yes target=release_debug use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release_debug  use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release  use_lto=yes

%SCONS% platform=windows %OPTIONS% tools=yes target=release_debug module_mono_enabled=yes use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release_debug module_mono_enabled=yes use_lto=yes
%SCONS% platform=windows %OPTIONS% tools=no target=release module_mono_enabled=yes use_lto=yes

md ..\binaries\win_x86
copy bin\*.* ..\binaries\win_x86

cd ..

curl -O -L https://github.com/GodotBuilder/godot-builds/releases/download/_tools/angle.7z
7z x -aoa angle.7z
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
