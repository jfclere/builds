ECHO OFF
set NGHTTP2_VERSION=1.66.0
set MOD_H2_VERSION=2.0.32
set BASEDIR=%CD%

IF NOT EXIST C:\APR\bin\httpd.exe (
	ECHO C:\APR\bin\httpd.exe missing.
	exit /b 1
)
curl -L -o nghttp2.zip https://github.com/nghttp2/nghttp2/archive/refs/tags/v%NGHTTP2_VERSION%.zip
powershell Expand-Archive nghttp2.zip
call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat" -arch=x64
rmdir /s /q nghttp2-build
mkdir nghttp2-build
cd nghttp2-build

cmake -G "Visual Studio 17 2022" ^
-DCMAKE_INSTALL_PREFIX=C:\APR ^
%BASEDIR%/nghttp2\nghttp2-%NGHTTP2_VERSION%\

MSBuild ALL_BUILD.vcxproj -t:build -p:Configuration=Release
MSBuild INSTALL.vcxproj -t:build -p:Configuration=Release
cd %BASEDIR%

curl -L -o mod_h2.zip https://github.com/icing/mod_h2/archive/refs/tags/v%MOD_H2_VERSION%.zip
powershell Expand-Archive mod_h2.zip
call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat" -arch=x64
rmdir /s /q mod_h2-build
mkdir mod_h2-build
cd mod_h2-build

cmake -G "Visual Studio 17 2022" ^
-DCMAKE_INSTALL_PREFIX=C:\APR ^
-DAPR_LIBRARY=C:/APR/lib/libapr-1.lib ^
-DAPR_INCLUDE_DIR=C:/APR/include/ ^
-DAPACHE_INCLUDE_DIR=C:/APR/include/ ^
-DAPRUTIL_LIBRARY=C:/APR/lib/libaprutil-1.lib ^
-DAPRUTIL_INCLUDE_DIR=C:/APR/include/ ^
-DAPACHE_LIBRARY=C:/APR/lib/libhttpd.lib ^
-DPROXY_LIBRARY=C:/APR/lib/mod_proxy.lib ^
-DNGHTTP2_LIBRARIES=C:/APR/lib/nghttp2.lib ^
%BASEDIR%\mod_h2\mod_h2-%MOD_H2_VERSION%

MSBuild ALL_BUILD.vcxproj -t:build -p:Configuration=Release
rem no install just copy the files
copy  %BASEDIR%\mod_h2-build\Release\*.so C:\APR\modules\
cd %BASEDIR%
