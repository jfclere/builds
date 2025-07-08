set OPENSSL_VERSION=3.5.0
set BASEDIR=%CD%

curl -L -o httpd24.tar.gz https://dist.apache.org/repos/dist/dev/httpd/httpd-2.4.64-rc2.tar.gz
tar xzvf httpd24.tar.gz
call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat" -arch=x64
rmdir /s /q httpd-build
mkdir httpd-build
cd httpd-build
cmake -G "Visual Studio 17 2022" ^
-DAPR_INCLUDE_DIR=C:/APR/include ^
-DAPR_LIBRARIES=C:/APR/lib/libapr-1.lib;C:/APR/lib/libaprapp-1.lib;C:/APR/lib/apr_ldap-1.lib;C:/APR/lib/libaprutil-1.lib ^
-DCMAKE_INSTALL_PREFIX=C:/APR ^
-DPCRE_CFLAGS=-DHAVE_PCRE2 ^
-DCMAKE_LIBRARY_PATH_FLAG="C:/OPENSSL/bin" ^
-DOPENSSL_LIBRARIES="C:/OPENSSL/lib/libssl.lib;C:/OPENSSL/lib/libcrypto.lib" ^
-DOPENSSL_INCLUDE_DIR="C:/OPENSSL/include" ^
%BASEDIR%\httpd-2.4.64

MSBuild libhttpd.vcxproj -t:build -p:Configuration=Release
MSBuild httpd.vcxproj -t:build -p:Configuration=Release
MSBuild INSTALL.vcxproj -t:build -p:Configuration=Release
cd %BASEDIR%
