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

- Build and test only in Docker. Never install, never `curl … | sh`, never write outside the working tree.
- Never run the AppImage (or extracted `AppRun`) on the host while debugging.
