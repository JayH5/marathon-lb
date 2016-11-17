#!/bin/bash
set -e

mkdir -p /usr/src

# Build openssl
OPENSSL_VERSION="1.1.0c"
OPENSSL_SHA256="fc436441a2e05752d31b4e46115eb89709a28aef96d4fe786abe92409b2fd6f5"

cd /usr/src
OPENSSL_FILENAME="openssl-$OPENSSL_VERSION"
wget "https://www.openssl.org/source/$OPENSSL_FILENAME.tar.gz"
echo "$OPENSSL_SHA256  $OPENSSL_FILENAME.tar.gz" | sha256sum -c
tar zxf "$OPENSSL_FILENAME.tar.gz"
cd "$OPENSSL_FILENAME"
perl ./Configure linux-x86_64 \
  enable-ec_nistp_64_gcc_128 \
  shared \
  -Wl,-rpath=/usr/local/ssl/lib
make depend
make
# make test
make install_sw

# Build Lua
LUA_VERSION="5.3.3"
LUA_SHA1="a0341bc3d1415b814cc738b2ec01ae56045d64ef"

cd /usr/src
LUA_FILENAME="lua-$LUA_VERSION"
wget "http://www.lua.org/ftp/$LUA_FILENAME.tar.gz"
echo "$LUA_SHA1  $LUA_FILENAME.tar.gz" | sha1sum -c
tar zxf "$LUA_FILENAME.tar.gz"
cd "$LUA_FILENAME"
make -j4 linux LUA_LIB_NAME=lua53
make -j4 install LUA_LIB_NAME=lua53

# Build HAProxy
HAPROXY_MAJOR_VERSION="1.7"
HAPROXY_VERSION="1.7-dev6"
HAPROXY_MD5="e9f338c8b5731ba0827e5f280e8bafb2"

cd /usr/src
HAPROXY_FILENAME="haproxy-$HAPROXY_VERSION"
wget "http://www.haproxy.org/download/$HAPROXY_MAJOR_VERSION/src/devel/$HAPROXY_FILENAME.tar.gz"
echo "$HAPROXY_MD5  $HAPROXY_FILENAME.tar.gz" | md5sum -c
tar zxf "$HAPROXY_FILENAME.tar.gz"
cd "$HAPROXY_FILENAME"
make -j4 \
  TARGET=linux2628 \
  CPU=x86_64 \
  USE_PCRE=1 \
  USE_PCRE_JIT=1 \
  USE_REGPARM=1 \
  USE_STATIC_PCRE=1 \
  USE_OPENSSL=1 \
  SSL_LIB=/usr/local/ssl/lib/ \
  SSL_INC=/usr/local/ssl/include/ \
  USE_LUA=1 \
  LUA_LIB=/usr/local/lib/ \
  LUA_INC=/usr/local/include/ \
  USE_ZLIB=1 \
  all \
  install-bin

# Clean up
cd /
rm -rf /usr/src/*
