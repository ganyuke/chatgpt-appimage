# chatgpt-appimage

like upstream, but everything is self-contained and you can build everything locally on a Fedora 44 system.

to build an image yourself on Fedora, you can do:

```bash
git clone https://github.com/ganyuke/chatgpt-appimage
cd chatgpt-appimage
sudo dnf install bsdtar curl desktop-file-utils file ShellCheck squashfs-tools zsync
./build.sh
```

if you hate installing dependencies on your main system like I do, then you can use Toolbox, which should be already installed on your Fedora Workstation system:

```bash
toolbox create
toolbox enter
toolbox enter fedora-toolbox-44
```

...and then the commands above.

The finished AppImage should appear in the `dist/` folder.
