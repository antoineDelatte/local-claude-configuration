# run-worktree-setup: run the repo's .wto/setup script inside a new worktree.
# Called by worktree-open after copying files, before opening the IDE.
# The script is read from the main repo (not copied) and runs with cwd = worktree.
# Env: WTO_SOURCE_ROOT (main repo root), WTO_WORKTREE (new worktree path).

_wto_run_setup() {
  local src="$1" wt="$2"
  local script="$src/.wto/setup"
  [[ -f "$script" ]] || return 0

  print "Running setup (.wto/setup)..."
  ( cd "$wt" && WTO_SOURCE_ROOT="$src" WTO_WORKTREE="$wt" zsh "$script" )
  local rc=$?
  if (( rc != 0 )); then
    print "  warn: setup failed (exit $rc)" >&2
  fi
  return $rc
}
