#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
    printf 'usage: %s x86_64|aarch64\n' "$0" >&2
    exit 1
fi

arch=$1
case $arch in
    x86_64)
        deb_arch=amd64
        elf_arch=x86-64
        ;;
    aarch64)
        deb_arch=arm64
        elf_arch=aarch64
        ;;
    *)
        printf 'unsupported arch: %s\n' "$arch" >&2
        exit 1
        ;;
esac

shellcheck /work/AppRun /work/build.sh /work/scripts/build-appimage.sh

work=/work/build/$arch
appdir=$work/AppDir
rm -rf "$work"
mkdir -p "$appdir" "$work/control" /work/dist

curl -fL -o "$work/chatgpt.deb" \
    "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_${deb_arch}.deb"

bsdtar -xOf "$work/chatgpt.deb" 'control.tar*' |
    bsdtar -xf - -C "$work/control"
version=$(sed -n 's/^Version:[[:space:]]*//p' "$work/control/control")
if [ -z "$version" ]; then
    printf 'no Version field in deb control file\n' >&2
    exit 1
fi

bsdtar -xOf "$work/chatgpt.deb" 'data.tar*' |
    bsdtar --no-same-owner -xf - -C "$appdir"

rm -rf "${appdir:?}/usr/share/doc" "${appdir:?}/usr/bin"

set -- "$appdir"/usr/share/applications/*.desktop
if [ "$#" -ne 1 ] || [ ! -e "$1" ]; then
    printf 'expected exactly one desktop file, found %s\n' "$#" >&2
    exit 1
fi
desktop_name=$(basename "$1")
sed 's|^Exec=[^ ]*|Exec=chatgpt|' "$1" > "$appdir/$desktop_name"
desktop-file-validate "$appdir/$desktop_name"

icon_name=$(sed -n 's/^Icon=//p' "$appdir/$desktop_name")
if [ -z "$icon_name" ]; then
    printf 'no Icon field in desktop file\n' >&2
    exit 1
fi
icon=''
if [ -d "$appdir/usr/share/icons" ]; then
    icon=$(find "$appdir/usr/share/icons" -name "$icon_name.png" | sort -V | tail -n 1)
fi
if [ -z "$icon" ] && [ -d "$appdir/usr/share/pixmaps" ]; then
    icon=$(find "$appdir/usr/share/pixmaps" -name "$icon_name.png" | sort -V | tail -n 1)
fi
if [ -z "$icon" ]; then
    printf 'no icon named %s.png found in deb payload\n' "$icon_name" >&2
    exit 1
fi
cp "$icon" "$appdir/$icon_name.png"
cp "$icon" "$appdir/.DirIcon"

bin=$appdir/usr/lib/chatgpt/ChatGPT
if [ ! -x "$bin" ]; then
    printf 'ChatGPT binary missing or not executable\n' >&2
    exit 1
fi
case $(file -b "$bin") in
    *"$elf_arch"*) ;;
    *)
        printf 'ELF arch mismatch: expected %s\n' "$elf_arch" >&2
        exit 1
        ;;
esac

install -m 0755 /work/AppRun "$appdir/AppRun"

out=/work/dist/ChatGPT-$version-$arch.AppImage
rm -f "$out" "$out.zsync"
set -- --runtime-file "/opt/runtime-$arch" "$appdir" "$out"
if [ -n "${GITHUB_REPOSITORY:-}" ]; then
    owner=${GITHUB_REPOSITORY%%/*}
    repo=${GITHUB_REPOSITORY#*/}
    set -- -u "gh-releases-zsync|$owner|$repo|latest|ChatGPT-*-$arch.AppImage.zsync" "$@"
fi
(cd /work/dist && ARCH=$arch /opt/appimagetool/AppRun "$@")

offset=$(wc -c < "/opt/runtime-$arch")
listing=$(unsquashfs -offset "$offset" -l "$out")
printf '%s\n' "$listing" | grep -q 'usr/lib/chatgpt/ChatGPT$'
printf '%s\n' "$listing" | grep -q 'squashfs-root/AppRun$'
printf '%s\n' "$listing" | grep -q '/\.DirIcon$'

if [ -n "${GITHUB_REPOSITORY:-}" ] && [ ! -f "$out.zsync" ]; then
    printf 'expected %s.zsync but appimagetool did not produce it\n' "$out" >&2
    exit 1
fi

printf 'built %s\n' "$out"
