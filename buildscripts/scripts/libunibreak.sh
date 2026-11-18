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

[ -f configure ] || ./autogen.sh

mkdir -p $build
cd $build

../configure \
	--host=${arch/arm64/aarch64}-apple-darwin --with-pic \
	--enable-static --disable-shared

make -j$cores
make DESTDIR="$prefix_dir" install
