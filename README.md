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
```

The worktree is created at `<project-parent>/<repo-name>-worktrees/<branch-name>`, as a sibling to the repository — keeping it completely outside the repo to prevent accidental commits or pushes.

### Extending

| To add...          | File to edit                      |
|--------------------|-----------------------------------|
| New project type   | `zsh/detect-project-type.zsh`     |
| New IDE            | `zsh/open-in-ide.zsh`             |
| New flag/behavior  | `zsh/worktree-open.zsh`           |

See `CLAUDE.md` for detailed extension instructions and architecture notes.
