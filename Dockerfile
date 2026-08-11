FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        desktop-file-utils \
        file \
        libarchive-tools \
        shellcheck \
        squashfs-tools \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /opt/appimagetool.AppImage \
        https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage \
    && chmod 0755 /opt/appimagetool.AppImage \
    && cd /opt \
    && ./appimagetool.AppImage --appimage-extract \
    && mv squashfs-root appimagetool \
    && rm appimagetool.AppImage

RUN curl -fsSL -o /opt/runtime-x86_64 \
        https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-x86_64 \
    && curl -fsSL -o /opt/runtime-aarch64 \
        https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-aarch64 \
    && chmod 0644 /opt/runtime-x86_64 /opt/runtime-aarch64
