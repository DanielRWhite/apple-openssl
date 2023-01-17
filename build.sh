#!/bin/bash

# Place this script in your project under a folder called something like deps/apple
# Builds OpenSSL static/dynamic libraries + development headers for all Mac, iOS & iOS Simulator architectures
# Prerequisites: A mac with the latest XCode & iOS SDK installed
# Inspiration + Credit: https://gist.github.com/armadsen/b30f352a8d6f6c87a146

set -e

ROOT_DIR=$(pwd)
rm -rf .cache
mkdir -p .cache
cd .cache

OPENSSL_VERSION="openssl-1.1.1s"
IOS_SDK_VERSION=$(xcodebuild -version -sdk iphoneos | grep SDKVersion | cut -f2 -d ':' | tr -d '[[:space:]]')
MIN_IOS_VERSION="7.0"
MIN_OSX_VERSION="10.7"

echo "----------------------------------------"
echo "OpenSSL version: ${OPENSSL_VERSION}"
echo "iOS SDK version: ${IOS_SDK_VERSION}"
echo "iOS deployment target: ${MIN_IOS_VERSION}"
echo "OS X deployment target: ${MIN_OSX_VERSION}"
echo "----------------------------------------"

DEVELOPER=`xcode-select -print-path`
buildMac() {
	ARCH=$1

	echo "Starting build for ${OPENSSL_VERSION} (${ARCH})"
	TARGET="darwin64-arm64-cc"
	if [[ $ARCH == "x86_64" ]]; then
		TARGET="darwin64-x86_64-cc"
	fi
	
	export CC="${BUILD_TOOLS}/usr/bin/clang -mmacosx-version-min=${MIN_OSX_VERSION}"
	pushd . > /dev/null

	rm -rf "${ROOT_DIR}/libs/macos/${ARCH}"
	mkdir -p "${ROOT_DIR}/libs/macos/${ARCH}"

	if [ ! -e ${OPENSSL_VERSION}.tar.gz ]; then
		curl --silent -O https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz
	fi

	tar xfz "${OPENSSL_VERSION}.tar.gz"
	SOURCE_DIR="${ROOT_DIR}/.cache/${OPENSSL_VERSION}"

	mkdir -p "build/macos/${ARCH}"
	cd "build/macos/${ARCH}"

	$SOURCE_DIR/Configure ${TARGET} --prefix="${ROOT_DIR}/libs/macos/${ARCH}" --openssldir=. &> build.log
	
	echo "=== STARTING MAKE ===" >> build.log
	make -j8 ../ >> build.log 2>&1
	
	echo "=== STARTING MAKE INSTALL ===" >> build.log
	make install ../ >> build.log 2>&1

	cd $SOURCE_DIR/../
	rm -rf $SOURCE_DIR
}

buildIOS() {
	ARCH=$1
	PLATFORM=$2
  
	echo "Starting build for ${OPENSSL_VERSION} (${PLATFORM} ${IOS_SDK_VERSION} ${ARCH})"	
	pushd . > /dev/null

	rm -rf "${ROOT_DIR}/libs/ios/${ARCH}"
	mkdir -p "${ROOT_DIR}/libs/ios/${ARCH}"

	if [ ! -e ${OPENSSL_VERSION}.tar.gz ]; then
		curl --silent -O https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz
	fi

	tar xfz "${OPENSSL_VERSION}.tar.gz"
	SOURCE_DIR="${ROOT_DIR}/.cache/${OPENSSL_VERSION}"

	if [[ $PLATFORM == "iPhoneOS" ]]; then
		sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "${SOURCE_DIR}/crypto/ui/ui_openssl.c"
	fi

	mkdir -p "build/ios/${PLATFORM}-${ARCH}"
	cd "build/ios/${PLATFORM}-${ARCH}"
  
	export $PLATFORM
	export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
	export CROSS_SDK="${PLATFORM}${IOS_SDK_VERSION}.sdk"
	export BUILD_TOOLS="${DEVELOPER}"
	export CC="${BUILD_TOOLS}/usr/bin/gcc -fembed-bitcode -mios-version-min=${MIN_IOS_VERSION} -arch ${ARCH}"
	
	$SOURCE_DIR/Configure iphoneos-cross  --prefix="${ROOT_DIR}/libs/ios/${ARCH}" --openssldir=. &> configure.log
	sed -ie "s!^CFLAG=!CFLAG=-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -mios-version-min=${MIN_IOS_VERSION} !" "Makefile"

	echo "=== STARTING MAKE ===" >> build.log
	make -j8 ../ >> build.log 2>&1

	echo "=== STARTING MAKE INSTALL ===" >> build.log
	make install ../ >> build.log 2>&1

	cd $SOURCE_DIR/../
	rm -rf $SOURCE_DIR
}

echo ""
echo "=== Building Mac Libraries ==="
buildMac "arm64"
buildMac "x86_64"

echo ""
echo "=== Building iOS Libraries ==="
buildIOS "armv7" "iPhoneOS"
buildIOS "arm64" "iPhoneOS"

echo ""
echo "=== Building iOS Simulator Libraries ==="
buildIOS "x86_64" "iPhoneSimulator"

cd $ROOT_DIR
rm -rf .cache

echo "=== Done ==="
echo "[MacOS libraries (Apple Silicon)] Run: export OPENSSL_DIR=$(pwd)/libs/mac/arm64/"
echo "[MacOS libraries (Intel)], Run: export OPENSSL_DIR=$(pwd)/libs/mac/x86_64/"
echo "[iOS libraries (armv7)] Run: export OPENSSL_DIR=$(pwd)/libs/ios/armv7/"
echo "[iOS libraries (arm64)] Run: export OPENSSL_DIR=$(pwd)/libs/ios/arm64/"
echo "[iOS Simulator libraries (Apple Silicon Mac)] Run: export OPENSSL_DIR=$(pwd)/libs/ios/arm64/"
echo "[iOS Simulator libraries (Intel Mac)] Run: export OPENSSL_DIR=$(pwd)/libs/ios/x86_64/"

