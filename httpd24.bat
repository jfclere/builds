set OPENSSL_VERSION=3.5.0
set BASEDIR=%CD%

rmdir /s /q httpd
git -c http.sslVerify=false clone https://gitlab.cee.redhat.com/jboss-web-server/jbcs/httpd
cd httpd
git checkout 2.4.62
cd %BASEDIR%
rmdir /s /q httpd-build
mkdir httpd-build
cd httpd-build
call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat" -arch=x64
set CFLAGS=/D "HTTPD_ROOT=\"C:/APR\"" /D "SERVER_CONFIG_FILE=\"C:/APR/conf/httpd.conf\""
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
