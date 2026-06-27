# Tests

Shell-level tests for the parts of ai-toolkit that execute and mutate `~/.claude`.

## Run locally

```bash
brew install bats-core jq shellcheck   # macOS
bats tests/                            # all tests
shellcheck install.sh uninstall.sh doctor.sh hooks/*.sh
```

- `install.bats` — runs `install.sh` / `uninstall.sh` / `doctor.sh` against a throwaway
  `$HOME` (a tmp dir), asserting symlinks, hook wiring, idempotency, `--dry-run` no-op, and
  clean uninstall. Never touches your real `~/.claude`.
- `guard.bats` — feeds tool-call JSON to `hooks/pretooluse-guard.sh` and checks it blocks
  destructive commands and secrets while allowing ordinary calls.

CI runs both plus shellcheck on every push (`.github/workflows/ci.yml`).
