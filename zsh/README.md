# zsh

XDG-compliant zsh setup with a strict separation between the version-controlled
"kernel" rc and a per-machine sandbox file.

## Layout

| File | Tracked | Purpose |
|---|---|---|
| `~/.zshenv` (← `home/dot-zshenv`) | yes | Set `ZDOTDIR` and other XDG paths. Runs for every zsh, login or not. |
| `~/.config/zsh/.zshrc` (← `zsh/dot-zshrc`) | yes | The kernel rc. Oh My Zsh, plugins, prompt, aliases, function autoload. Reviewed and committed. |
| `~/.zshrc` | **no** (mode 600) | Per-machine sandbox: tool-installer dumps + secrets + local overrides. Sourced last by the kernel. |

Because `ZDOTDIR=$XDG_CONFIG_HOME/zsh` is set in `.zshenv`, zsh reads
`$ZDOTDIR/.zshrc`, **not** `~/.zshrc`, as its rc file. So `~/.zshrc` is
unused by zsh itself; it only runs because the kernel ends with:

```zsh
[[ -f ~/.zshrc ]] && source ~/.zshrc
```

## Why `~/.zshrc` (not `~/.zshrc.local`) for the sandbox

Tool installers (nvm, pyenv, rustup, conda, gcloud SDK, atuin curl-installer,
Powerlevel10k wizard, iTerm2 shell integration, ...) hardcode `~/.zshrc` and
**append** to it. They don't know about `ZDOTDIR`.

Two design options:

1. **Fight installers.** Use `~/.zshrc.local` as overrides, leave `~/.zshrc`
   alone. Every installer dumps into a file you'd then ignore. Manual cleanup
   forever.
2. **Embrace it.** Let `~/.zshrc` be the dumping ground *and* the override
   file. Installers land where they expect; you also stash secrets and
   per-machine tweaks there. Single sink, single source line.

This repo chose option 2. The kernel stays minimal and portable; everything
machine-specific concentrates in one untracked file.

## Why mode 600

`~/.zshrc` carries credentials (API keys, tokens). `.zshenv` enforces:

```bash
if [[ ! -e ~/.zshrc ]]; then
  touch ~/.zshrc
  chmod 600 ~/.zshrc
fi
```

Set explicitly because some installers `touch ~/.zshrc` with the umask default
(usually 644) before this guard runs on a fresh machine. Re-tighten manually
if an installer ever loosens it: `chmod 600 ~/.zshrc`.

## Migrating an old machine

If an older machine still uses `~/.zshrc.local`:

```bash
mv ~/.zshrc.local ~/.zshrc
chmod 600 ~/.zshrc
exec zsh
```

## Pitfalls to avoid

- **Do not symlink `~/.zshrc` → `$ZDOTDIR/.zshrc`.** That makes the kernel
  source itself = infinite recursion until zsh aborts.
- **Do not commit `~/.zshrc`.** It contains secrets and machine-specific
  installer junk. The dotfiles repo intentionally has no `dot-zshrc` package.
- **Do not move tool init lines into the kernel** unless they're cross-machine
  identical and non-secret. Keep installer-managed lines in `~/.zshrc` so the
  installer's own update logic (e.g. `nvm install` rewriting its block) keeps
  working.
- **Backups.** `~/.zshrc` is not in git. Ensure it's covered by Time Machine,
  rsync, or another out-of-band backup if you care about its contents.

## Files in this package

- `dot-zshrc` — the kernel rc (stowed to `$ZDOTDIR/.zshrc`).
- `functions/` — autoloaded zsh functions (e.g. `gclone`).
- `hooks/` — autoloaded chpwd/preexec hooks (e.g. `auto_git_sync`).
