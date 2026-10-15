# Claude Context: local-claude-configuration

## Purpose
This repository stores shell tooling to streamline mobile and general development workflows on macOS.
The primary tool is `worktree-open` (`wto`): a zsh command that creates a git worktree for a feature branch and opens the appropriate IDE.

## Developer Profile
- **OS**: macOS, zsh + oh-my-zsh
- **Terminal**: Terminal.app
- **IDEs**: Android Studio (via JetBrains Toolbox), Xcode, Cursor (primary), VS Code (fallback)
- **Projects**: Android apps, iOS apps, Kotlin Multiplatform (KMP), React Native, other

## Repository Structure

```
local-claude-configuration/
├── CLAUDE.md                       ← this file
├── README.md                       ← user-facing docs
├── install.sh                      ← idempotent installer (oh-my-zsh symlink or .zshrc append)
└── zsh/
    ├── worktree-open.zsh           ← main command: argument parsing, worktree creation, orchestration
    ├── detect-project-type.zsh     ← project type detection logic
    ├── open-in-ide.zsh             ← IDE opening logic
    ├── copy-worktree-files.zsh     ← auto-copy gitignored files into new worktrees
    └── run-worktree-setup.zsh      ← run per-repo `.wto/setup` inside new worktrees
```

## Key Conventions

- **Worktree path**: `<git-root-parent>/<repo-name>-worktrees/<branch-name>` — sibling to the repo, outside it to prevent accidental inclusion in git pushes
- **Branch naming**: user-provided, stored as-is in git; directory name is lowercased with spaces→hyphens
- **Installation**: symlink into `~/.oh-my-zsh/custom/` if oh-my-zsh is present, else append `source` line to `~/.zshrc`
- **Claude launch**: opt-in via `--claude` flag; opens a new Terminal.app window via `osascript`
- **Per-repo config**: gitignored `.wto/` dir in the main repo (read from there, never copied into worktrees)
- **File copying**: `.wto/copy-files` (preferred), legacy `.wto-copy` / `.wto-copy.local` (deprecated, still honored with a stderr note), `~/.config/wto/<repo>.conf` (global fallback) — one path per line, `#` comments; all sources merged
- **Setup**: `.wto/setup` run as `zsh "$git_root/.wto/setup"` with cwd = worktree, after copy and before IDE; env `WTO_SOURCE_ROOT`, `WTO_WORKTREE`; failure warns, continues, `wto` returns 1; `--no-setup` skips; no global fallback

## Extensibility

### Add a new project type
Edit `zsh/detect-project-type.zsh`. Add a new `if` block before the final `print "other"`.

Example — adding Flutter detection:
```zsh
# Flutter: pubspec.yaml at root
if [[ -f "$dir/pubspec.yaml" ]]; then
  print "flutter"
  return
fi
```

### Add a new IDE
Edit `zsh/open-in-ide.zsh`. Add a `case` branch for the new project type, or extend the fallback chain.

### Add files to auto-copy into worktrees
Create `.wto/copy-files` in the project root (keep `.wto/` gitignored) with one path per line (relative to repo root). Lines starting with `#` are comments. For repos you don't own, `~/.config/wto/<repo-name>.conf` (same format) also works. Legacy `.wto-copy` / `.wto-copy.local` are still merged but print a deprecation note. All sources are merged.

Example `.wto/copy-files`:
```
# Environment
.env
# Firebase
app/google-services.json
```

### Add a setup step for new worktrees
Create `.wto/setup` in the project root: a zsh script run with cwd = new worktree (e.g. `pod install`). `WTO_SOURCE_ROOT` / `WTO_WORKTREE` are exported. Logic lives in `zsh/run-worktree-setup.zsh`.

### Add a new flag or behavior
Edit `zsh/worktree-open.zsh`. Add a new `case` entry in the argument parser and the corresponding logic below.

## IDE CLI Notes
- **Android Studio**: `studio` CLI is installed by JetBrains Toolbox at `~/Library/Application Support/JetBrains/Toolbox/scripts/studio`
- **Xcode**: `xed` at `/usr/bin/xed` — auto-selects `.xcworkspace` over `.xcodeproj`
- **Cursor**: CLI not on PATH by default; binary at `/Applications/Cursor.app/Contents/Resources/app/bin/cursor`
- **VS Code**: `code` (install via VS Code's "Install 'code' command in PATH")

## Project Type Detection Rules
Detection is first-match; order matters for multi-platform projects.

| Priority | Type    | Indicator files                                                    |
|----------|---------|--------------------------------------------------------------------|
| 1        | android | `gradlew`, `build.gradle`, `build.gradle.kts`, `settings.gradle*` |
| 2        | ios     | `*.xcworkspace`, `*.xcodeproj`, `Podfile`                          |
| 3        | other   | (default)                                                          |

React Native projects have `android/` and `ios/` subdirectories but no root `gradlew`, so they correctly fall to `other` (Cursor).
KMP projects have a root `build.gradle.kts`, so they correctly open in Android Studio.
