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

mkdir -p $build
cd $build

../configure \
	--target-os=darwin --enable-cross-compile --arch=$arch \
	--cc="$CC" --cxx="$CXX" --ar="$AR" --ranlib="$RANLIB" --pkg-config=pkg-config \
	--extra-cflags="$CFLAGS" --extra-ldflags="$LDFLAGS" \
	--enable-videotoolbox --enable-audiotoolbox --enable-mbedtls --enable-libdav1d \
	--enable-static --disable-shared --enable-pic \
	--enable-gpl --enable-version3 \
	--disable-{stripping,doc,programs,muxers,encoders,devices,filters,debug} \
	--enable-filter=aformat,aresample,anull,pan,loudnorm,dynaudnorm,acompressor,volume,yadif,bwdif

make -j$cores
make DESTDIR="$prefix_dir" install
