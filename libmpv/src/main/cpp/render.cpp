#include <jni.h>
#include <dlfcn.h>

#include <android/native_window.h>
#include <android/native_window_jni.h>
#include <mpv/client.h>

#include "jni_utils.h"
#include "log.h"
#include "globals.h"

typedef int (*pfn_ANativeWindow_setBuffersDataSpace)(ANativeWindow*, int);
static pfn_ANativeWindow_setBuffersDataSpace fn_setBuffersDataSpace = nullptr;
static bool fn_resolved = false;

static void resolve_setBuffersDataSpace() {
    if (fn_resolved) return;
    fn_resolved = true;
    fn_setBuffersDataSpace = (pfn_ANativeWindow_setBuffersDataSpace)
        dlsym(RTLD_DEFAULT, "ANativeWindow_setBuffersDataSpace");
}

extern "C" {
    jni_func(void, nativeAttachSurface, jlong instance, jobject surface);
    jni_func(void, nativeDetachSurface, jlong instance);
    jni_func(void, nativeSetSurfaceDataSpace, jlong instance, jint dataSpace);
}

jni_func(void, nativeAttachSurface, jlong instance, jobject surface) {
    auto mpv_instance = reinterpret_cast<MPVInstance*>(instance);

    mpv_instance->surface = env->NewGlobalRef(surface);
    if (!mpv_instance->surface) {
        die(env, "invalid surface provided");
        return;
    }

    int64_t wid = reinterpret_cast<intptr_t>(mpv_instance->surface);
    int result = mpv_set_option(mpv_instance->mpv, "wid", MPV_FORMAT_INT64, &wid);
    if (result < 0)
        ALOGE("mpv_set_option(wid) returned error %s", mpv_error_string(result));
}

jni_func(void, nativeDetachSurface, jlong instance) {
    auto mpv_instance = reinterpret_cast<MPVInstance*>(instance);
    int64_t wid = 0;
    int result = mpv_set_option(mpv_instance->mpv, "wid", MPV_FORMAT_INT64, &wid);
    if (result < 0)
        ALOGE("mpv_set_option(wid) returned error %s", mpv_error_string(result));

    env->DeleteGlobalRef(mpv_instance->surface);
    mpv_instance->surface = nullptr;
}

jni_func(void, nativeSetSurfaceDataSpace, jlong instance, jint dataSpace) {
    auto mpv_instance = reinterpret_cast<MPVInstance*>(instance);
    if (!mpv_instance->surface)
        return;

    resolve_setBuffersDataSpace();
    if (!fn_setBuffersDataSpace)
        return;

    ANativeWindow *window = ANativeWindow_fromSurface(env, mpv_instance->surface);
    if (window) {
        fn_setBuffersDataSpace(window, dataSpace);
        ANativeWindow_release(window);
    }
}
