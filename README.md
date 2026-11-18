# libmpv for iOS

An iOS port of [libmpv-android](https://github.com/jarnedemeulemeester/libmpv-android). Builds [mpv](https://mpv.io) and its dependencies as static libraries and packages them as `libmpv-ios.xcframework`.

## Building from source

Take a look at [README.md](buildscripts/README.md) inside the `buildscripts` directory.

## Acknowledgements

- [Jarne Demeulemeester](https://github.com/jarnedemeulemeester) for the original [libmpv-android](https://github.com/jarnedemeulemeester/libmpv-android) project, whose build scripts this port is based on.
- The [mpv-android](https://github.com/mpv-android/mpv-android) team for the foundation that project is built on.
- The [mpv](https://github.com/mpv-player/mpv) developers.
- The projects built into the library: [FFmpeg](https://ffmpeg.org), [libass](https://github.com/libass/libass), [libplacebo](https://code.videolan.org/videolan/libplacebo), [dav1d](https://code.videolan.org/videolan/dav1d), [Mbed TLS](https://github.com/Mbed-TLS/mbedtls), [FreeType](https://freetype.org), [HarfBuzz](https://github.com/harfbuzz/harfbuzz), [FriBidi](https://github.com/fribidi/fribidi), [libunibreak](https://github.com/adah1972/libunibreak) and [Lua](https://www.lua.org).

## License

The build scripts are MIT licensed. See [LICENSE](LICENSE) for details.

The built library links FFmpeg and mpv with GPL enabled, so the resulting binaries are subject to the licenses of those components.
