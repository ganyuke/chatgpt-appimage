# chatgpt-appimage

Unofficial AppImage builds of the official ChatGPT desktop app (with Codex) for Linux, x86_64 and aarch64, repacked from the upstream Debian package.

## Disclaimer

This project is not affiliated with or endorsed by OpenAI.
The packaged application is proprietary software, subject to OpenAI's terms of use.
This repository contains only the build scripts (MIT licensed) and unofficial repackaged builds of the official binaries.

## Install

Download the AppImage for your architecture from the [releases page](../../releases/latest), then:

```sh
chmod +x ChatGPT-*.AppImage
./ChatGPT-*.AppImage
```

To verify a download, get `SHA256SUMS` from the same release and run `sha256sum -c SHA256SUMS --ignore-missing` in the download directory.

Desktop integration (menu entry, icon) is provided by tools such as AppImageLauncher or appimaged, if you use them.
The images embed update information, so `appimageupdatetool ChatGPT-*.AppImage` fetches new releases as delta downloads.

## Build it yourself

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

## Troubleshooting

- App aborts at startup mentioning the sandbox: see the Sandbox section.
- Blank or misrendered window: try `--disable-gpu` in `codex-flags.conf`.
- Build fails with a checksum or layout error: upstream changed the deb; please open an issue.

## Credits

The launcher flag handling and Wayland behavior are ported from the AUR `openai-codex-desktop` package.

## License

The build scripts in this repository are MIT licensed (see `LICENSE`).
The ChatGPT application itself is proprietary software owned by OpenAI.
