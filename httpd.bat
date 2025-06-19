set OPENSSL_VERSION=3.5.0
set APR_VERSION=1.7.6
set APR_UTIL_VERSION=1.6.3
rem set EXPAT_VERSION=2.5.0 hardcoded for the moment...
set LIBXML2_VERSION=
set NASM_VERSION=2.16.03
set BASEDIR=%CD%

goto next
curl -o nasm.zip https://www.nasm.us/pub/nasm/releasebuilds/%NASM_VERSION%/win64/nasm-%NASM_VERSION%-win64.zip
powershell Expand-Archive nasm.zip -DestinationPath .

curl -L -o perl.msi https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54021_64bit_UCRT/strawberry-perl-5.40.2.1-64bit.msi
msiexec.exe /i perl.msi

curl -L -o openssl.zip https://github.com/openssl/openssl/archive/refs/tags/openssl-%OPENSSL_VERSION%.zip
powershell Expand-Archive openssl.zip -DestinationPath .

set PATH=%PATH%;%CD%\nasm-%NASM_VERSION%
call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat" -arch=x64
cd openssl-openssl-%OPENSSL_VERSION%
C:\strawberry\perl\bin\perl Configure no-shared VC-WIN64A --prefix=C:\OPENSSL
nmake
nmake install
rem ab.c needs it.
copy ms\applink.c c:\OPENSSL\include\openssl
cd %BASEDIR%

curl -L -o apr.zip https://github.com/apache/apr/archive/refs/tags/%APR_VERSION%.zip
powershell Expand-Archive apr.zip
cd apr\apr-%APR_VERSION%
powershell %BASEDIR%\apr.hw.ps1
nmake -f Makefile.win ARCH="x64 Release" buildall PREFIX=C:\APR
nmake -f Makefile.win ARCH="x64 Release" install PREFIX=C:\APR
cd apr\apr-%APR_VERSION%
mkdir C:\APR\include\arch\win32
copy include\arch\win32\*.h c:\APR\include\arch\win32
copy include\arch\*.h c:\APR\include\arch

rem curl -L -o expat.zip https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-win32bin-2.5.0.zip
rem powershell Expand-Archive expat.zip -DestinationPath expat

curl -L -o expat.tar.gz https://github.com/libexpat/libexpat/archive/refs/tags/R_2_5_0.tar.gz
tar xvf expat.tar.gz
rmdir /s /q expat-build
mkdir expat-build
cd expat-build
cmake -G "Visual Studio 17 2022" ^
-DCMAKE_INSTALL_PREFIX=C:\APR ^
%BASEDIR%\libexpat-R_2_5_0\expat

MSBuild INSTALL.vcxproj -t:build -p:Configuration=Release
cd %BASEDIR%

curl -L -o apr-util.zip https://github.com/apache/apr-util/archive/refs/tags/%APR_UTIL_VERSION%.zip
powershell Expand-Archive apr-util.zip

rmdir /s /q apr-util-build
mkdir apr-util-build
cd apr-util-build
cmake -G "Visual Studio 17 2022" ^
-DCMAKE_INSTALL_PREFIX=C:\APR ^
-DEXPAT_INCLUDE_DIR=C:/APR/include ^
-DEXPAT_LIBRARY=C:/APR/lib/libexpat.lib ^
-DAPR_INCLUDE_DIR=C:/APR/include/ ^
-DAPR_LIBRARIES=C:/APR/lib/libapr-1.lib;C:/APR/lib/libaprapp-1.lib ^
%BASEDIR%\apr-util\apr-util-%APR_UTIL_VERSION%

MSBuild INSTALL.vcxproj -t:build -p:Configuration=Release
cd %BASEDIR%

curl -L -o pcre.zip https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/pcre2-10.42.zip
powershell Expand-Archive pcre.zip -DestinationPath .
rmdir /s /q pcre-build
mkdir pcre-build
cd pcre-build
cmake -G "Visual Studio 17 2022" ^
-DBUILD_SHARED_LIBS=ON ^
-DBUILD_STATIC_LIBS=OFF ^
-DPCRE_NEWLINE=ANYCRLF ^
-DPCRE_SUPPORT_JIT=ON ^
-DPCRE_SUPPORT_PCREGREP_JIT=ON ^
-DPCRE_SUPPORT_UTF=ON ^
-DPCRE_SUPPORT_UNICODE_PROPERTIES=ON ^
-DPCRE_SUPPORT_BSR_ANYCRLF=ON ^
-DCMAKE_INSTALL_ALWAYS=1 ^
-DINSTALL_MSVC_PDB=ON ^
-DCMAKE_INSTALL_PREFIX=C:\APR ^
%BASEDIR%/pcre2-10.42

MSBuild INSTALL.vcxproj -t:build -p:Configuration=Release

git clone https://github.com/apache/httpd.git
:next
call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat" -arch=x64
rmdir /s /q httpd-build
mkdir httpd-build
cd httpd-build
call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat" -arch=x64
cmake -G "Visual Studio 17 2022" ^
-DAPR_INCLUDE_DIR=C:/APR/include ^
-DAPR_LIBRARIES=C:/APR/lib/libapr-1.lib;C:/APR/lib/libaprapp-1.lib;C:/APR/lib/apr_ldap-1.lib;C:/APR/lib/libaprutil-1.lib ^
-DCMAKE_INSTALL_PREFIX=C:/APR ^
-DPCRE_CFLAGS=-DHAVE_PCRE2 ^
-DCMAKE_LIBRARY_PATH_FLAG="C:/OPENSSL/bin" ^
-DOPENSSL_LIBRARIES="C:/OPENSSL/lib/libssl.lib;C:/OPENSSL/lib/libcrypto.lib" ^
-DOPENSSL_INCLUDE_DIR="C:/OPENSSL/include" ^
%BASEDIR%\httpd

MSBuild libhttpd.vcxproj -t:build -p:Configuration=Release
MSBuild httpd.vcxproj -t:build -p:Configuration=Release
MSBuild INSTALL.vcxproj -t:build -p:Configuration=Release
cd %BASEDIR%
