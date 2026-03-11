# copy-worktree-files: copy listed files/directories from source repo to new worktree.
# Called by worktree-open after creating the worktree.

_wto_copy_files() {
  local src="$1" dst="$2"
  shift 2
  for entry in "$@"; do
    [[ -z "$entry" || "$entry" == \#* ]] && continue
    local src_path="$src/$entry" dst_path="$dst/$entry"
    if [[ ! -e "$src_path" ]]; then
      print "  warn: '$entry' not found, skipping" >&2
      continue
    fi
    mkdir -p "${dst_path:h}"
    if [[ -d "$src_path" ]]; then
      cp -R "$src_path" "$dst_path"
    else
      cp "$src_path" "$dst_path"
    fi
    print "  copied: $entry"
  done
}
