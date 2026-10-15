# local-claude-configuration

Local configuration to optimise use of Claude in code projects.

## worktree-open (`wto`)

A zsh command that creates a git worktree for a new feature branch and opens the appropriate IDE automatically.

**Detected project types:**
- **Android** (Android Studio) — projects with `gradlew`, `build.gradle*`, or `settings.gradle*` at root
- **iOS** (Xcode) — projects with `*.xcworkspace`, `*.xcodeproj`, or `Podfile` at root
- **Other** (Cursor → VS Code) — everything else, including React Native

### Installation

```zsh
git clone git@github.com:antoineDelatte/local-claude-configuration.git
cd local-claude-configuration
bash install.sh
source ~/.zshrc
```

### Updating

```zsh
bash update.sh
```

Pulls the latest changes and re-runs the installer if needed.

### Usage

```zsh
# In a project directory — prompts for branch name
wto

# Provide branch name directly
wto --branch feature/my-new-feature

# From anywhere, targeting a specific project
wto ~/Projects/my-android-app --branch fix/crash-on-login

# Also open a Claude Code session in the new worktree
wto --branch feature/auth --claude

# Skip the repo's .wto/setup script
wto --branch feature/quick-fix --no-setup
```

The worktree is created at `<project-parent>/<repo-name>-worktrees/<branch-name>`, as a sibling to the repository — keeping it completely outside the repo to prevent accidental commits or pushes.

### Per-repo config (`.wto/`)

Per-repo `wto` config lives in a `.wto/` directory at the repo root:

```
.wto/
├── copy-files   # gitignored files to copy into each new worktree
└── setup        # bootstrap script run inside each new worktree
```

`.wto/` is read from the main repo and is not copied into worktrees. Keep it out of git — either globally (`echo '.wto/' >> ~/.config/git/ignore`) or per repo (`echo '.wto/' >> .git/info/exclude`).

#### Auto-copying files (`.wto/copy-files`)

Gitignored files like `.env` or `google-services.json` aren't included in worktrees. List them in `.wto/copy-files`:

```
# one path per line, relative to repo root
.env
app/google-services.json
```

Files are copied from the main repo into each new worktree at creation time.

**Config sources** (all merged):
| File | Scope | Notes |
|------|-------|-------|
| `.wto/copy-files` | Project (gitignored) | Preferred |
| `.wto-copy` | Project | Deprecated — prints a note; move to `.wto/copy-files` |
| `.wto-copy.local` | Personal (gitignored) | Deprecated — prints a note; move to `.wto/copy-files` |
| `~/.config/wto/<repo-name>.conf` | Global (for repos you don't own) | |

#### Setup script (`.wto/setup`)

Bootstrap commands (e.g. `pod install`, `npm install`) go in `.wto/setup`:

```zsh
pod install
```

- Runs after file copy, before the IDE opens.
- Executed as `zsh .wto/setup` (no exec bit needed) with the **new worktree as cwd**.
- Env vars: `WTO_SOURCE_ROOT` (main repo root), `WTO_WORKTREE` (new worktree path).
- On failure: prints `warn: setup failed (exit N)`, still opens the IDE / Claude, and `wto` returns 1.
- Skip with `--no-setup`. No global fallback — setup is per repo only.

### Extending

| To add...          | File to edit                      |
|--------------------|-----------------------------------|
| New project type   | `zsh/detect-project-type.zsh`     |
| New IDE            | `zsh/open-in-ide.zsh`             |
| New flag/behavior  | `zsh/worktree-open.zsh`           |

See `CLAUDE.md` for detailed extension instructions and architecture notes.
