# chatgpt-appimage

like upstream, but the local build doesn't need Docker and is tailored to a Fedora Workstation system (specifically Fedora 44).

and also has immutable release and artifact attestation so you can trust that the only one siphoning away your Codex usage is yourself.

see [upstream](https://github.com/mbotezatu/chatgpt-appimage) for usage details. 

## verifying binary releases

you should probably check that the binaries you're downloading are from GitHub Actions and i haven't tampered with them.

you can do this with the [GitHub CLI](https://cli.github.com/):

```bash
gh attestation verify ./ChatGPT-VERSION-x86_64.AppImage \
  --repo ganyuke/chatgpt-appimage \
  --signer-workflow ganyuke/chatgpt-appimage/.github/workflows/release.yml \
  --deny-self-hosted-runners
```

you can also see the SHA-256 hash of each AppImage in the GitHub Actions log, so you can verify that way, too.

## building on your machine

if you don't trust me, then you can build on your own machine. on Fedora, you can do:

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
