set PATH=C:\Python36\Scripts\;C:\Python36\;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\ v1.0\;C:\ProgramData\chocolatey\bin;C:\Program Files\OpenSSH-Win64;C:\Program Files\Git\cmd;

choco list --local-only | findstr mono
IF %ERRORLEVEL% EQU 0 GOTO BUILD

net user Administrator /active:yes
choco install -y git python curl 7zip 
choco install -y visualstudio2017buildtools --package-parameters "--add Microsoft.VisualStudio.Workload.UniversalBuildTools --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.Windows10SDK.16299.Desktop --add Microsoft.VisualStudio.Component.Windows10SDK.16299.UWP.Native --passive"
python -m pip install --upgrade pip
pip install -U setuptools
pip install -U wheel
pip install scons pywin32
net user Administrator /active:no

:BUILD

set BUILD_NAME=official
set SCONS=call scons -j8 verbose=no warnings=no progress=no
set OPTIONS=builtin_libpng=yes builtin_openssl=yes builtin_zlib=yes gdnative_wrapper=yes debug_symbols=no
set TERM=xterm 

rd /s /q binaries
md binaries

curl -O -L https://github.com/GodotBuilder/godot-builds/releases/download/_tools/angle.7z
7z x -aoa angle.7z
set ANGLE_SRC_PATH=%cd%\angle

cd godot

git clean -fx
rmdir /s /q bin

call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64 uwp 10.0.16299.0
%SCONS% platform=uwp %OPTIONS% tools=no target=release_debug
%SCONS% platform=uwp %OPTIONS% tools=no target=release

md ..\binaries\uwp_amd64
copy bin\*.* ..\binaries\uwp_amd64

git clean -fx
rmdir /s /q bin

call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64_x86 uwp 10.0.16299.0
%SCONS% platform=uwp %OPTIONS% tools=no target=release_debug
%SCONS% platform=uwp %OPTIONS% tools=no target=release

md ..\binaries\uwp_x86
copy bin\*.* ..\binaries\uwp_x86

git clean -fx
rmdir /s /q bin

call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64_arm uwp 10.0.16299.0
%SCONS% platform=uwp %OPTIONS% tools=no target=release_debug
%SCONS% platform=uwp %OPTIONS% tools=no target=release

md ..\binaries\uwp_arm
copy bin\*.* ..\binaries\uwp_arm
