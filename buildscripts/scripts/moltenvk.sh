#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf Package
	exit 0
else
	exit 255
fi

export DEVELOPER_DIR="$(xcode-select -p)"

[ -d External/Vulkan-Headers ] || ./fetchDependencies --ios --iossim

if [ "$sdk" == "iphoneos" ]; then
	[ -d Package/Release/MoltenVK/static/MoltenVK.xcframework/ios-arm64 ] || make ios
	slice=ios-arm64
else
	[ -d Package/Release/MoltenVK/static/MoltenVK.xcframework/ios-arm64_x86_64-simulator ] || make iossim
	slice=ios-arm64_x86_64-simulator
fi

mvk_lib=Package/Release/MoltenVK/static/MoltenVK.xcframework/$slice/libMoltenVK.a
if [ "$(lipo -archs $mvk_lib | wc -w)" -gt 1 ]; then
	lipo $mvk_lib -thin $arch -output "$prefix_dir/lib/libMoltenVK.a"
else
	cp $mvk_lib "$prefix_dir/lib"
fi
cp -r External/Vulkan-Headers/include/vulkan "$prefix_dir/include"
cp -r External/Vulkan-Headers/include/vk_video "$prefix_dir/include"
cp -r MoltenVK/include/MoltenVK "$prefix_dir/include"

vkver=$(sed -n 's/^#define VK_HEADER_VERSION \([0-9]*\)$/\1/p' External/Vulkan-Headers/include/vulkan/vulkan_core.h)

cat >"$prefix_dir"/lib/pkgconfig/vulkan.pc <<END
Name: vulkan
Description: Vulkan via MoltenVK
Version: 1.4.$vkver
Libs: -L$prefix_dir/lib -lMoltenVK -lc++ -framework Metal -framework IOSurface -framework QuartzCore -framework UIKit -framework Foundation -framework CoreGraphics
Cflags: -I$prefix_dir/include
END
