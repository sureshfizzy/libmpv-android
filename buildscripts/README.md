# Building libmpv for iOS

Experimental and untested. Builds mpv and its dependencies as static libraries and packages them into `out/libmpv-ios.xcframework`.

## Requirements

Xcode and:

```shell
brew install meson ninja pkg-config autoconf automake libtool nasm
```

## Download dependencies

```shell
./download.sh
```

## Build

```shell
./build.sh
./build.sh --target ios-arm64
```

Targets: `ios-arm64` (device), `sim-arm64`, `sim-x86_64` (simulator). The minimum iOS version defaults to 15.0 and can be set with `IOS_MIN`.

Run `build.sh` with `--clean` to clean the build directories before building.
