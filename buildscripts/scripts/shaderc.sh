#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf local include libs
	exit 0
else
	exit 255
fi

builddir=$PWD

abi=armeabi-v7a
[[ "$ndk_triple" == "aarch64"* ]] && abi=arm64-v8a
[[ "$ndk_triple" == "x86_64"* ]] && abi=x86_64
[[ "$ndk_triple" == "i686"* ]] && abi=x86

# build using the NDK's scripts, but keep object files in our build dir
ndk_shaderc="$(dirname "$(which ndk-build)")/sources/third_party/shaderc"
cd "$ndk_shaderc"
ndk-build -j$cores \
	NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk \
	APP_PLATFORM=android-26 APP_STL=c++_shared APP_ABI=$abi \
	NDK_APP_OUT="$builddir" NDK_APP_LIBS_OUT="$builddir/libs" \
	libshaderc_combined

cd "$builddir"
cp -r "$ndk_shaderc/libshaderc/include"/* "$prefix_dir/include"
cp libs/*/$abi/libshaderc.a "$prefix_dir/lib/libshaderc_combined.a"

# create a pkgconfig file that libplacebo can find via dependency('shaderc')
mkdir -p "$prefix_dir"/lib/pkgconfig
cat >"$prefix_dir"/lib/pkgconfig/shaderc.pc <<END
Name: shaderc
Description: SPIR-V shader compiler
Version: 2024.1
Libs: -L${prefix_dir}/lib -lshaderc_combined -lc++
Cflags: -I${prefix_dir}/include
END