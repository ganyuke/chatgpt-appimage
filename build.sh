#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
cd "$repo_root" || exit 1

if [ "$#" -eq 0 ]; then
    set -- x86_64 aarch64
fi

host_root=$repo_root/build/.host
mkdir -p \
    "$host_root/home" \
    "$host_root/cache" \
    "$host_root/config" \
    "$host_root/data" \
    "$host_root/state" \
    "$host_root/tmp" \
    "$repo_root/dist"

export HOME="$host_root/home"
export XDG_CACHE_HOME="$host_root/cache"
export XDG_CONFIG_HOME="$host_root/config"
export XDG_DATA_HOME="$host_root/data"
export XDG_STATE_HOME="$host_root/state"
export TMPDIR="$host_root/tmp"

sh ./scripts/check-host-deps.sh
shellcheck AppRun build.sh scripts/check-host-deps.sh scripts/prepare-tools.sh scripts/build-appimage.sh

for arch do
    sh ./scripts/prepare-tools.sh "$arch"
    sh ./scripts/build-appimage.sh "$arch"
done
