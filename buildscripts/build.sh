#!/bin/bash -e

cd "$( dirname "${BASH_SOURCE[0]}" )"
. ./include/depinfo.sh

cleanbuild=0
nodeps=0
target=mpv
targets=(ios-arm64 sim-arm64 sim-x86_64)

getdeps () {
	varname="dep_${1//-/_}[*]"
	echo ${!varname}
}

build () {
	if [ ! -d deps/$1 ]; then
		printf >&2 '\e[1;31m%s\e[m\n' "Target $1 not found"
		return 1
	fi
	if [ $nodeps -eq 0 ]; then
		for dep in $(getdeps $1); do
			build $dep
		done
	fi
	printf >&2 '\e[1;34m%s\e[m\n' "Building $1 ($ios_target)..."
	pushd deps/$1
	BUILDSCRIPT=../../scripts/$1.sh
	[ $cleanbuild -eq 1 ] && $BUILDSCRIPT clean
	$BUILDSCRIPT build
	popd
}

usage () {
	printf '%s\n' \
		"Usage: build.sh [options] [dependency]" \
		"Builds the specified dependency (default: $target) for iOS" \
		"-n                Do not build dependencies" \
		"--clean           Clean build dirs before compiling" \
		"--target <target> ios-arm64, sim-arm64 or sim-x86_64 (default: all)"
	exit 0
}

while [ $# -gt 0 ]; do
	case "$1" in
		--clean) cleanbuild=1 ;;
		-n|--no-deps) nodeps=1 ;;
		--target) shift; targets=("$1") ;;
		-h|--help) usage ;;
		*) target=$1 ;;
	esac
	shift
done

for t in meson ninja pkg-config autoconf automake libtool nasm xcrun; do
	command -v $t >/dev/null || { echo >&2 "Missing '$t'"; exit 1; }
done

for ios_target in "${targets[@]}"; do
	export ios_target
	build $target
done

[ "$target" == "mpv" ] && ./package.sh

exit 0
