#!/bin/bash -e

cd "$( dirname "${BASH_SOURCE[0]}" )"
OUT=$PWD/out
NAME=libmpv-ios
rm -rf "$OUT"
mkdir -p "$OUT/device" "$OUT/simulator" "$OUT/tmp"

for t in $(ls prefix); do
	libtool -static -o "$OUT/tmp/$t.a" prefix/$t/lib/*.a
done

args=()
sims=()
for t in $(ls prefix); do
	case $t in
		ios-*) cp "$OUT/tmp/$t.a" "$OUT/device/$NAME.a"; args+=(-library "$OUT/device/$NAME.a" -headers prefix/$t/include/mpv) ;;
		sim-*) sims+=("$OUT/tmp/$t.a"); simprefix=prefix/$t ;;
	esac
done

if [ ${#sims[@]} -gt 0 ]; then
	lipo -create "${sims[@]}" -output "$OUT/simulator/$NAME.a"
	args+=(-library "$OUT/simulator/$NAME.a" -headers $simprefix/include/mpv)
fi

xcodebuild -create-xcframework "${args[@]}" -output "$OUT/$NAME.xcframework"
rm -rf "$OUT/tmp"
