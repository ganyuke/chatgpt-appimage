# Agent instructions for this repo

## Shell scripts

- POSIX `sh` only. `#!/bin/sh`, no `[[`, no arrays, no `local`, no process substitution, no `==` in `test`.
- `printf`, never `echo`. Heredocs for multi-line text.
- Must pass `shellcheck`.
- Do not add `# shellcheck disable` directives. Restructure the code so ShellCheck passes without suppressions.

## Style

- No emojis in committed files.
- Use Conventional Commits with an imperative summary, for example `fix: harden certificate setup`.

## Build and test

- The primary build path is the RPM-compatible host build in `./build.sh`.
- Never install host packages automatically. Report missing dependencies instead.
- All downloaded tools, build state, caches, temporary files, and artifacts created by project scripts must remain inside the repository tree.
- Never run the produced AppImage (or its extracted `AppRun`) on the host while debugging. Validate its filesystem contents instead.
