# atuin

Shell history with encrypted cross-machine sync, fuzzy search, and
session/host filtering. Installed via the `Brewfile`; shell init line
lives in the stowed `.zshrc`.

## What's stowed

| File | Purpose |
|---|---|
| `config.toml` | Diverged from upstream defaults (`max_preview_height`, `enter_accept`, `records`). Tracked. |
| `~/.local/share/atuin/key` | Encryption key, per-machine. **Not stowed, not in git.** Back up out-of-band. |
| `~/.local/share/atuin/history.db` | SQLite history, per-machine. Synced via the server, not via stow. |
| `~/.local/share/atuin/session` | Auth session token. Per-machine. |

Only `config.toml` belongs in this repo. Database, key, and session
are runtime state.

## First-time setup (single machine)

```bash
# atuin is already installed via Brewfile; setup.sh stows config.toml.
# .zshrc has `eval "$(atuin init zsh)"` so Ctrl+R is wired up after
# the next shell start.

# Optional — register an account if you want sync. Skip if you only
# want local history on one machine.
atuin register -u <username> -e <email>
atuin import auto    # pull existing zsh/bash history into atuin
atuin sync           # push to server
```

Without `register` / `login`, atuin still works locally — you just
don't get cross-machine sync.

## Migrating history to a new machine

Order matters. The encryption key must be set **before** sync, otherwise
downloaded history stays as ciphertext that can't be decrypted.

### On the source machine (history already there)

```bash
atuin key
```

Outputs a 12-word BIP39 mnemonic. Copy it; treat it like a password.
Don't paste into untrusted channels — anyone with the key can decrypt
your synced history.

### On the destination machine

```bash
# 1. Login and set the encryption key in one shot.
atuin login -u <username> -p <password> -k "word1 word2 ... word12"

# 2. Force a full pull from the server (decrypted using the key above).
atuin sync -f

# 3. Bring this machine's local zsh/bash history into atuin (one time).
atuin import auto

# 4. Push the freshly imported local history up so other machines see it.
atuin sync
```

Two-step alternative if you prefer not to pass the key on the login
command line:

```bash
atuin login -u <username> -p <password>
atuin key set "word1 word2 ... word12"
atuin sync -f
atuin import auto
atuin sync
```

### Verify

```bash
atuin status   # last sync time, record count
atuin search   # interactive — should now see history from both machines
```

## Backup the encryption key

`~/.local/share/atuin/key` is **not** synced anywhere. Lose it and any
history already pushed to the server is unrecoverable (server can't
decrypt; that's the point of client-side encryption).

Recommended:

- Store the BIP39 mnemonic from `atuin key` in a password manager.
- OR copy `~/.local/share/atuin/key` (binary file) into encrypted
  storage (e.g., a 1Password attachment).

Restore on a new machine via `atuin key set "<mnemonic>"`.

## Common gotchas

- **Synced but search returns nothing.** Almost always missing key.
  `atuin key set "<mnemonic>" && atuin sync -f`.
- **`atuin import auto` re-runs.** Idempotent — atuin deduplicates,
  so re-running on the same machine is safe but pointless.
- **Different shells across machines.** `import auto` detects the
  current shell. Run on each machine for its own local history.
- **Self-hosted server.** Set `sync_address` in `config.toml`.
  Default is `https://api.atuin.sh`.
- **`enter_accept = true`** in `config.toml` — pressing Enter on a
  search result executes immediately. Use `Tab` to select without
  executing if you want to edit first.

## Related

- Upstream docs: <https://docs.atuin.sh>
- Repo: <https://github.com/atuinsh/atuin>
