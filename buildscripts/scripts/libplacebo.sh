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

meson setup $build --cross-file "$prefix_dir"/crossfile.txt \
	-Dvulkan=disabled -Dopengl=enabled -Dgl-proc-addr=enabled -Dshaderc=disabled -Dglslang=disabled -Ddemos=false -Dtests=false

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install
