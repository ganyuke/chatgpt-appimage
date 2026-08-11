#!/bin/sh
set -eu

cd -- "$(dirname -- "$0")" || exit 1

if [ "$#" -eq 0 ]; then
    set -- x86_64 aarch64
fi

docker build -t chatgpt-appimage-builder .

for arch do
    docker run --rm \
        --user "$(id -u):$(id -g)" \
        -e HOME=/tmp \
        -e GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-}" \
        -v "$PWD":/work \
        -w /work \
        chatgpt-appimage-builder \
        sh /work/scripts/build-appimage.sh "$arch"
done
