#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

build=_build$ios_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf $build
	exit 0
else
	exit 255
fi

unset CC CXX CFLAGS CXXFLAGS LDFLAGS

cmake -S . -B $build -G Ninja \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_SYSTEM_NAME=iOS \
	-DCMAKE_OSX_SYSROOT=$sdk \
	-DCMAKE_OSX_ARCHITECTURES=$arch \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=$IOS_MIN \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DSHADERC_SKIP_TESTS=ON \
	-DSHADERC_SKIP_EXAMPLES=ON \
	-DSHADERC_SKIP_COPYRIGHT_CHECK=ON \
	-DSHADERC_ENABLE_SHARED_CRT=OFF \
	-DSPIRV_SKIP_EXECUTABLES=ON \
	-DSPIRV_SKIP_TESTS=ON \
	-DENABLE_GLSLANG_BINARIES=OFF \
	-DBUILD_TESTING=OFF

ninja -C $build -j$cores shaderc_combined

cp -r libshaderc/include/shaderc "$prefix_dir/include"
cp $build/libshaderc/libshaderc_combined.a "$prefix_dir/lib"

cat >"$prefix_dir"/lib/pkgconfig/shaderc.pc <<END
Name: shaderc
Description: SPIR-V shader compiler
Version: $v_shaderc
Libs: -L$prefix_dir/lib -lshaderc_combined -lc++
Cflags: -I$prefix_dir/include
END
