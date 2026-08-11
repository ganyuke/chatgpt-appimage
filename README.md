# chatgpt-appimage

Builds an AppImage of the official ChatGPT desktop app (with Codex) by repacking the upstream Debian package from `https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/`.

## Build

Requires Docker. Everything runs inside a container.

```sh
./build.sh            # builds x86_64 and aarch64
./build.sh x86_64     # builds one arch
```

Output: `dist/ChatGPT-<version>-<arch>.AppImage`.
The version is read from the downloaded deb, so each build packs whatever upstream currently serves as latest.

## Runtime flags

The launcher reads extra Chromium flags from `${XDG_CONFIG_HOME:-~/.config}/codex-flags.conf`, one or more whitespace-separated flags, `#` comments allowed:

```
# example
--disable-gpu
```

On Wayland sessions (`XDG_SESSION_TYPE=wayland` or `WAYLAND_DISPLAY` set) the launcher adds `--ozone-platform=wayland` automatically unless an `--ozone-platform=` or `--ozone-platform-hint=` flag is already given.

## Sandbox

Inside an AppImage the Chromium SUID sandbox helper cannot be used, so the app relies on unprivileged user namespaces.
On distributions that restrict those, add `--no-sandbox` to `codex-flags.conf`.
