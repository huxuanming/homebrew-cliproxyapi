# homebrew-cliproxyapi

Homebrew tap for `cliproxyapi`, with automated sync to the latest GitHub release.

## Install

```bash
brew tap hu/cliproxyapi
brew install cliproxyapi
```

## Upgrade

```bash
brew update
brew upgrade cliproxyapi
```

## Local sync script

```bash
./scripts/sync_cliproxyapi.sh
```

The script:
- fetches latest release from `router-for-me/CLIProxyAPI`
- recalculates source tarball `sha256`
- updates `Formula/cliproxyapi.rb` when needed

## GitHub auto sync

Workflow file:
- `.github/workflows/sync.yml`

Behavior:
- runs every 6 hours and on manual trigger
- updates formula via script
- automatically opens/updates PR when there is a change

## Repository setup checklist

1. Create GitHub repo named `homebrew-cliproxyapi`.
2. Push this project to `main`.
3. Enable GitHub Actions.
4. (Optional) Protect `main` and require PR review.
5. Merge PRs created by workflow to publish updates.
