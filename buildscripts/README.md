# Building libmpv for iOS

Builds mpv and its dependencies as static libraries and packages them into `out/libmpv-ios.xcframework`.

## Requirements

Xcode (selected with `xcode-select`) and:

```shell
brew install meson ninja cmake pkg-config autoconf automake libtool nasm
pip3 install jinja2 jsonschema
```

## Download dependencies

```shell
./include/download-deps.sh
```

## Build

```shell
./build.sh
./build.sh --target ios-arm64
```

Targets: `ios-arm64` (device), `sim-arm64`, `sim-x86_64` (simulator). The minimum iOS version defaults to 15.0 and can be set with `IOS_MIN`.

Run `build.sh` with `--clean` to clean the build directories before building.

## Rendering

mpv is built with Vulkan through MoltenVK and an `iosvk` context (`patches/mpv`). Pass a `CAMetalLayer` pointer as `--wid` and use `vo=gpu-next`, `gpu-context=iosvk`.
