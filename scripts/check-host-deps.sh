#!/bin/sh
set -eu

missing=''
for command_name in \
    bsdtar \
    curl \
    desktop-file-validate \
    file \
    shellcheck \
    sha256sum \
    unsquashfs \
    zsyncmake
do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        missing="$missing $command_name"
    fi
done

if [ -n "$missing" ]; then
    printf 'missing required host commands:%s\n' "$missing" >&2
    cat >&2 <<'EOF_PACKAGES'

Fedora/RHEL-family package names:
  bsdtar curl desktop-file-utils file ShellCheck squashfs-tools zsync

On Fedora, install them with:
  sudo dnf install bsdtar curl desktop-file-utils file ShellCheck squashfs-tools zsync

The build itself does not install packages or write build state outside this repository.
EOF_PACKAGES
    exit 1
fi
