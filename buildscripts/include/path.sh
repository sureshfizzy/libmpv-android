#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

IOS_MIN=${IOS_MIN:-15.0}
cores=${cores:-$(sysctl -n hw.ncpu)}

case "$ios_target" in
	ios-arm64)  sdk=iphoneos;        arch=arm64;  minflag="-miphoneos-version-min=$IOS_MIN"; subsystem=ios ;;
	sim-arm64)  sdk=iphonesimulator; arch=arm64;  minflag="-mios-simulator-version-min=$IOS_MIN"; subsystem=ios-simulator ;;
	sim-x86_64) sdk=iphonesimulator; arch=x86_64; minflag="-mios-simulator-version-min=$IOS_MIN"; subsystem=ios-simulator ;;
	*) echo >&2 "ios_target must be ios-arm64, sim-arm64 or sim-x86_64"; exit 1 ;;
esac

sysroot=$(xcrun --sdk $sdk --show-sdk-path)
export prefix_dir="$DIR/prefix/$ios_target"
export ios_suffix="-$ios_target"
mkdir -p "$prefix_dir/lib/pkgconfig" "$prefix_dir/include"
[ -e "$prefix_dir/usr" ] || ln -s . "$prefix_dir/usr"
[ -e "$prefix_dir/local" ] || ln -s . "$prefix_dir/local"

export CC="$(xcrun --sdk $sdk -f clang)"
export CXX="$(xcrun --sdk $sdk -f clang++)"
export AR="$(xcrun --sdk $sdk -f ar)"
export RANLIB="$(xcrun --sdk $sdk -f ranlib)"
export CFLAGS="-arch $arch -isysroot $sysroot $minflag -fPIC -I$prefix_dir/include"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-arch $arch -isysroot $sysroot $minflag -L$prefix_dir/lib"

export PKG_CONFIG_SYSROOT_DIR="$prefix_dir"
export PKG_CONFIG_LIBDIR="$prefix_dir/lib/pkgconfig"
unset PKG_CONFIG_PATH

args="'-arch','$arch','-isysroot','$sysroot','$minflag'"
cat >"$prefix_dir/crossfile.txt" <<CROSS
[built-in options]
buildtype = 'release'
prefix = '/usr/local'
default_library = 'static'
wrap_mode = 'nodownload'
c_args = [$args,'-I$prefix_dir/include']
cpp_args = [$args,'-I$prefix_dir/include']
objc_args = [$args,'-I$prefix_dir/include']
objcpp_args = [$args,'-I$prefix_dir/include']
c_link_args = [$args,'-L$prefix_dir/lib']
cpp_link_args = [$args,'-L$prefix_dir/lib']
objc_link_args = [$args,'-L$prefix_dir/lib']
objcpp_link_args = [$args,'-L$prefix_dir/lib']
[binaries]
c = '$CC'
cpp = '$CXX'
objc = '$CC'
objcpp = '$CXX'
ar = '$AR'
strip = '$(xcrun --sdk $sdk -f strip)'
pkg-config = 'pkg-config'
[host_machine]
system = 'darwin'
subsystem = '$subsystem'
cpu_family = '$arch'
cpu = '$arch'
endian = 'little'
CROSS
