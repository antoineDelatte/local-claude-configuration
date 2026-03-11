# worktree-open: create a git worktree, open the IDE, and optionally launch Claude Code.
# Usage: wto [<project-path>] [--branch <name>] [--claude]
#
# Options:
#   <project-path>   Path to the git project root (default: current directory)
#   --branch <name>  Branch/worktree name (prompted if omitted)
#   --claude         Also open a Claude Code session in the new worktree

# Source helpers relative to this file's location
source "${0:A:h}/detect-project-type.zsh"
source "${0:A:h}/open-in-ide.zsh"

worktree-open() {
  local project_path=""
  local branch_name=""
  local launch_claude=false

  # --- Argument parsing ---
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --branch)
        shift
        branch_name="$1"
        ;;
      --claude)
        launch_claude=true
        ;;
      -*)
        print "Unknown option: $1" >&2
        print "Usage: wto [<project-path>] [--branch <name>] [--claude]" >&2
        return 1
        ;;
      *)
        if [[ -z "$project_path" ]]; then
          project_path="$1"
        else
          print "Unexpected argument: $1" >&2
          return 1
        fi
        ;;
    esac
    shift
  done

  # --- Resolve git root ---
  local start_dir="${project_path:-$PWD}"
  start_dir="$(cd "$start_dir" 2>/dev/null && pwd)" || {
    print "Path not found: $start_dir" >&2
    return 1
  }

  local git_root
  git_root="$(git -C "$start_dir" rev-parse --show-toplevel 2>/dev/null)" || {
    print "Not a git repository: $start_dir" >&2
    return 1
  }

  # --- Branch name ---
  if [[ -z "$branch_name" ]]; then
    print -n "Branch name: "
    read branch_name
  fi

  if [[ -z "$branch_name" ]]; then
    print "Branch name cannot be empty." >&2
    return 1
  fi

  # Sanitize for directory name: lowercase, spaces → hyphens, strip leading slashes
  local dir_name="${branch_name:l}"         # lowercase
  dir_name="${dir_name// /-}"               # spaces to hyphens
  dir_name="${dir_name#/}"                  # strip leading slash

  # --- Worktree path ---
  local worktree_path="$git_root/.worktrees/$dir_name"

  if [[ -d "$worktree_path" ]]; then
    print "Worktree already exists at: $worktree_path" >&2
    return 1
  fi

  # --- Detect project type ---
  local project_type
  project_type="$(_wto_detect_project_type "$git_root")"

  # --- Create the worktree ---
  print "Creating worktree '$branch_name' at $worktree_path..."

  if git -C "$git_root" worktree add "$worktree_path" -b "$branch_name" 2>/dev/null; then
    print "Worktree created."
  else
    # Branch already exists: offer to check it out instead
    print -n "Branch '$branch_name' already exists. Check it out in a new worktree? [y/N] "
    local answer
    read answer
    if [[ "${answer:l}" == "y" ]]; then
      git -C "$git_root" worktree add "$worktree_path" "$branch_name" || return 1
      print "Worktree created."
    else
      return 1
    fi
  fi

  # --- Open IDE ---
  print "Opening $project_type project in IDE..."
  _wto_open_ide "$project_type" "$worktree_path"

  # --- Optionally launch Claude Code ---
  if [[ "$launch_claude" == true ]]; then
    print "Launching Claude Code in $worktree_path..."
    osascript -e "tell application \"Terminal\" to do script \"cd '$worktree_path' && claude\""
  fi

  print "Done. Worktree: $worktree_path"
}

alias wto='worktree-open'
