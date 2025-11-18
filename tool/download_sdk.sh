#!/bin/bash -e

v_platform=android-36
# https://developer.android.google.cn/studio?hl=zh-cn#command-tools
v_sdk=13114758_latest
# https://developer.android.google.cn/ndk/downloads/?hl=zh-cn
v_ndk=29.0.14206865
# https://developer.android.google.cn/tools/releases/platform-tools?hl=zh-cn
v_sdk_build_tools=36.1.0
v_cmake=3.31.6
v_min_sdk=24

[ -z "$TRAVIS" ] && TRAVIS=0 # skip steps not required for CI?
[ -z "$WGET" ] && WGET=wget # possibility of calling wget differently

os=linux

if [ "$os" == "linux" ]; then
	if [ $TRAVIS -eq 0 ]; then
		hash yum &>/dev/null && {
			sudo yum install autoconf pkgconfig libtool ninja-build unzip \
			python3-pip python3-setuptools unzip wget;
			sudo pip3 install meson; }
		apt-get -v &>/dev/null && {
		    sudo apt-get update;
			sudo apt-get install -y autoconf pkg-config libtool ninja-build nasm unzip libgtest-dev autopoint gperf gettext \
			python3-pip python3-setuptools unzip;
			sudo pip3 install meson; }
	fi

	if ! javac -version &>/dev/null; then
		echo "Error: missing Java Development Kit."
		hash yum &>/dev/null && \
			echo "Install it using e.g. sudo yum install java-latest-openjdk-devel"
		apt-get -v &>/dev/null && \
			echo "Install it using e.g. sudo apt-get install default-jre-headless"
		exit 255
	fi

	os_ndk="linux"
fi

mkdir -p sdk && cd sdk

# Android SDK
if [ ! -d "android-sdk-${os}" ]; then
	$WGET "https://dl.google.com/android/repository/commandlinetools-${os}-${v_sdk}.zip"
	mkdir "android-sdk-${os}"
	unzip -q -d "android-sdk-${os}" "commandlinetools-${os}-${v_sdk}.zip"
	rm "commandlinetools-${os}-${v_sdk}.zip"
fi
sdkmanager () {
	local exe="./android-sdk-$os/cmdline-tools/latest/bin/sdkmanager"
	[ -x "$exe" ] || exe="./android-sdk-$os/cmdline-tools/bin/sdkmanager"
	"$exe" --sdk_root="${ANDROID_HOME}" "$@"
}
echo y | sdkmanager \
	"platforms;${v_platform}" \
	"build-tools;${v_sdk_build_tools}" \
	"ndk;${v_ndk}" \
	"cmake;${v_cmake}"

# gas-preprocessor
mkdir -p bin
$WGET "https://github.com/FFmpeg/gas-preprocessor/raw/master/gas-preprocessor.pl" \
	-O bin/gas-preprocessor.pl
chmod +x bin/gas-preprocessor.pl

cd ..

export ANDROID_HOME="$DIR/sdk/android-sdk-$os"
export ANDROID_NDK=$ANDROID_HOME/ndk/${v_ndk}/