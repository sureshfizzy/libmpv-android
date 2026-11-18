#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	make clean
	exit 0
else
	exit 255
fi

$0 clean

sed -i "" "s/system(\([^)]*\))/(-1)/g" src/loslib.c

make CC="$CC" AR="$AR rc" RANLIB="$RANLIB" MYCFLAGS="$CFLAGS" \
	PLAT=macosx LUA_T= LUAC_T= -j$cores

make INSTALL_TOP="$prefix_dir" INSTALL_EXEC=true TO_BIN= install

mkdir -p $prefix_dir/lib/pkgconfig
make pc >$prefix_dir/lib/pkgconfig/lua.pc
cat >>$prefix_dir/lib/pkgconfig/lua.pc <<'PC'
Name: Lua
Description:
Version: ${version}
Libs: -L${libdir} -llua
Cflags: -I${includedir}
PC
