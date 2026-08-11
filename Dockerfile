FROM debian:12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        desktop-file-utils \
        file \
        libarchive-tools \
        shellcheck \
        squashfs-tools \
        zsync \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /opt/appimagetool.AppImage \
        https://github.com/AppImage/appimagetool/releases/download/1.9.1/appimagetool-x86_64.AppImage \
    && printf '%s  %s\n' \
        ed4ce84f0d9caff66f50bcca6ff6f35aae54ce8135408b3fa33abfc3cb384eb0 \
        /opt/appimagetool.AppImage | sha256sum -c - \
    && chmod 0755 /opt/appimagetool.AppImage \
    && cd /opt \
    && ./appimagetool.AppImage --appimage-extract \
    && mv squashfs-root appimagetool \
    && rm appimagetool.AppImage

RUN curl -fsSL -o /opt/runtime-x86_64 \
        https://github.com/AppImage/type2-runtime/releases/download/20251108/runtime-x86_64 \
    && curl -fsSL -o /opt/runtime-aarch64 \
        https://github.com/AppImage/type2-runtime/releases/download/20251108/runtime-aarch64 \
    && printf '%s  %s\n' \
        2fca8b443c92510f1483a883f60061ad09b46b978b2631c807cd873a47ec260d \
        /opt/runtime-x86_64 \
        00cbdfcf917cc6c0ff6d3347d59e0ca1f7f45a6df1a428a0d6d8a78664d87444 \
        /opt/runtime-aarch64 | sha256sum -c - \
    && chmod 0644 /opt/runtime-x86_64 /opt/runtime-aarch64
