#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
    printf 'usage: %s x86_64|aarch64\n' "$0" >&2
    exit 1
fi

target_arch=$1
case $target_arch in
    x86_64)
        runtime_sha256=2fca8b443c92510f1483a883f60061ad09b46b978b2631c807cd873a47ec260d
        ;;
    aarch64)
        runtime_sha256=00cbdfcf917cc6c0ff6d3347d59e0ca1f7f45a6df1a428a0d6d8a78664d87444
        ;;
    *)
        printf 'unsupported target arch: %s\n' "$target_arch" >&2
        exit 1
        ;;
esac

case $(uname -m) in
    x86_64|amd64)
        host_arch=x86_64
        appimagetool_sha256=ed4ce84f0d9caff66f50bcca6ff6f35aae54ce8135408b3fa33abfc3cb384eb0
        ;;
    aarch64|arm64)
        host_arch=aarch64
        appimagetool_sha256=f0837e7448a0c1e4e650a93bb3e85802546e60654ef287576f46c71c126a9158
        ;;
    *)
        printf 'unsupported host arch: %s\n' "$(uname -m)" >&2
        exit 1
        ;;
esac

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root" || exit 1

appimagetool_version=1.9.1
runtime_version=20251108
host_root=$repo_root/build/.host
download_dir=$host_root/downloads
tools_dir=$host_root/tools
mkdir -p "$download_dir" "$tools_dir"

appimagetool_asset=$download_dir/appimagetool-$appimagetool_version-$host_arch.AppImage
runtime_asset=$download_dir/runtime-$runtime_version-$target_arch
appimagetool_dir=$tools_dir/appimagetool-$appimagetool_version-$host_arch

download_verified() {
    url=$1
    destination=$2
    checksum=$3

    if [ -f "$destination" ]; then
        if printf '%s  %s\n' "$checksum" "$destination" | sha256sum -c - >/dev/null 2>&1; then
            return 0
        fi
        printf 'cached file failed checksum, refreshing: %s\n' "$destination" >&2
        rm -f "$destination"
    fi

    partial=$destination.part
    rm -f "$partial"
    curl -fL --retry 3 --retry-delay 1 -o "$partial" "$url"
    printf '%s  %s\n' "$checksum" "$partial" | sha256sum -c -
    mv "$partial" "$destination"
}

download_verified \
    "https://github.com/AppImage/appimagetool/releases/download/$appimagetool_version/appimagetool-$host_arch.AppImage" \
    "$appimagetool_asset" \
    "$appimagetool_sha256"
chmod 0755 "$appimagetool_asset"

download_verified \
    "https://github.com/AppImage/type2-runtime/releases/download/$runtime_version/runtime-$target_arch" \
    "$runtime_asset" \
    "$runtime_sha256"
chmod 0644 "$runtime_asset"

if [ ! -x "$appimagetool_dir/AppRun" ]; then
    extract_dir=$host_root/extract-appimagetool-$host_arch
    rm -rf "$extract_dir" "$appimagetool_dir"
    mkdir -p "$extract_dir"
    (
        cd "$extract_dir" || exit 1
        "$appimagetool_asset" --appimage-extract >/dev/null
    )
    mv "$extract_dir/squashfs-root" "$appimagetool_dir"
    rmdir "$extract_dir"
fi
