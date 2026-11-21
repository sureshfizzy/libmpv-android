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

for patch in ../../patches/mpv/*.patch; do
	[ -f "$patch" ] || continue
	git apply -R --check "$patch" >/dev/null 2>&1 && continue
	git apply "$patch"
done

meson setup $build --cross-file "$prefix_dir"/crossfile.txt \
	--default-library static -Dlibmpv=true -Dcplayer=false -Dtests=false -Dmanpage-build=disabled \
	-Dlua=enabled -Diconv=enabled -Dgl=enabled -Dios-gl=disabled -Dvideotoolbox-gl=disabled -Davfoundation=disabled \
	-Daudiounit=enabled -Dcoreaudio=disabled -Dvulkan=enabled -Dvideotoolbox-pl=enabled -Dswift-build=disabled

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install
