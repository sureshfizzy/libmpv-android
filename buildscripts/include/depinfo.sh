#!/bin/bash -e

v_lua=5.2.4
v_libunibreak=7_0
v_libass=0.17.5
v_harfbuzz=14.4.0
v_fribidi=1.0.16
v_freetype=2-14-3
v_mbedtls=3.6.7
v_libplacebo=7.360.1
v_dav1d=1.5.4
v_ffmpeg=9.0.1
v_mpv=0.41.0

dep_mbedtls=()
dep_dav1d=()
dep_ffmpeg=(mbedtls dav1d)
dep_freetype2=()
dep_fribidi=()
dep_harfbuzz=()
dep_libunibreak=()
dep_libass=(freetype fribidi harfbuzz libunibreak)
dep_lua=()
dep_libplacebo=()
dep_mpv=(ffmpeg libass lua libplacebo)
